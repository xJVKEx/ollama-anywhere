@echo off
:: setlocal creates a local variable scope so temporary session variables (like OLLAMA_MODELS)
:: do not leak into the calling parent shell environment upon script completion.
:: We use enabledelayedexpansion for dynamic variable parsing in the pre-install selection.
setlocal enabledelayedexpansion

:: =====================================================================
:: Ollama Custom Dynamic Automated Installer / Restorer
:: =====================================================================
:: Dynamic Setup Utility for Ollama (Rebranded: Ollama Anywhere)
:: Developed by xjvkex (https://github.com/xJVKEx)
:: =====================================================================

title Ollama Anywhere Installer
echo =====================================================================
echo                     Ollama Anywhere Installer
echo =====================================================================
echo.

:: Initialize error message variable
set "ERR_MSG=An unknown error occurred."

:: 1. Admin Elevation Check
echo [*] Verifying administrator privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] ERROR: This script must be run as Administrator to set up system 
    echo            environment variables and register custom directory paths.
    echo.
    echo Please right-click this file and select "Run as administrator".
    goto ERROR_NO_VAR
)
echo     Privileges verified.

:: 2. Define Paths Dynamically (Based on where this script is located)
set "SCRIPT_DIR=%~dp0"
:: Strip trailing backslash from SCRIPT_DIR
if "%SCRIPT_DIR:~-1%"=="\" set "TARGET_DIR=%SCRIPT_DIR:~0,-1%"
if not defined TARGET_DIR set "TARGET_DIR=%SCRIPT_DIR%"

set "MODELS_DIR=%TARGET_DIR%\models"
set "INSTALLER_NAME=OllamaSetup.exe"

:: 3. Create target directories if they do not exist
echo [*] Creating target directories...
set "ERR_MSG=Failed to create target directories. Check folder permissions."
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%" || goto ERROR
if not exist "%MODELS_DIR%" mkdir "%MODELS_DIR%" || goto ERROR
echo     Target Location: %TARGET_DIR%
echo     Models Location: %MODELS_DIR%

:: 4. Configure the OLLAMA_MODELS Environment Variable
echo [*] Setting OLLAMA_MODELS environment variable...
set "ERR_MSG=Failed to write OLLAMA_MODELS to system registry."
:: NOTE: Using the /M switch to write permanently to the System-wide (HKLM) registry.
:: Since the script is running elevated, this guarantees the setting applies to ALL users
:: on the system, preventing the "Admin-only" registry leak typical of elevated User setx.
setx OLLAMA_MODELS "%MODELS_DIR%" /M > nul || goto ERROR
:: Set locally for the current script session
set "OLLAMA_MODELS=%MODELS_DIR%"
echo     OLLAMA_MODELS is set system-wide to: %MODELS_DIR%

:: 5. Add Ollama directory to User PATH
echo [*] Adding Ollama to your User PATH...
set "ERR_MSG=Failed to append Ollama install directory to User PATH."
powershell -Command "$p=[Environment]::GetEnvironmentVariable('Path','User'); if($p -split ';' -notcontains '%TARGET_DIR%'){$newPath = ($p + ';%TARGET_DIR%') -replace ';;',';'; [Environment]::SetEnvironmentVariable('Path',$newPath,'User'); Write-Host '    Successfully added to PATH.'} else {Write-Host '    Already in PATH.'}" || goto ERROR

:: 6. Check if Ollama is already installed in this directory
if exist "%TARGET_DIR%\ollama.exe" (
    echo.
    echo [*] Ollama is already installed in this folder:
    echo ---------------------------------------------------------------------
    "%TARGET_DIR%\ollama.exe" --version
    echo ---------------------------------------------------------------------
    echo.
    set "REINSTALL_CHOICE=n"
    set /p REINSTALL_CHOICE="Do you want to reinstall/upgrade the binaries? [y/N]: "
    if /i "!REINSTALL_CHOICE!"=="y" (
        echo [*] Proceeding with binary reinstall...
        goto RUN_INSTALLER
    )
    echo [*] Skipping binary installation. Environment variables successfully updated!
    goto END_INSTALL
)

:RUN_INSTALLER
:: 7. Install Ollama using GOTO branching to avoid parentheses bugs
echo [*] Checking for installer...
if exist "%TARGET_DIR%\%INSTALLER_NAME%" goto RUN_LOCAL
goto RUN_ONLINE

:RUN_LOCAL
echo     Found local installer. Launching offline installation...
echo     Installing to: %TARGET_DIR%
set "ERR_MSG=Silent local installation failed. The installer exited with an error."
:: NOTE: The "/DIR=" argument assumes the installer uses Inno Setup.
:: While stable and tested, this is technically undocumented and could change
:: in future Ollama releases.
start /wait "" "%TARGET_DIR%\%INSTALLER_NAME%" /DIR="%TARGET_DIR%" /VERYSILENT /NORESTART /SUPPRESSMSGBOXES
if %errorlevel% neq 0 (
    echo [!] Local installer exited with error code: %errorlevel%
    goto ERROR
)
goto END_INSTALL

:RUN_ONLINE
echo     Local installer not found. Running online bootstrap...
echo     Installing to: %TARGET_DIR%
set "ERR_MSG=Online bootstrap installation failed."
:: Set the OLLAMA_INSTALL_DIR env variable for the session.
:: The official Ollama install.ps1 reads this to pass to the installer.
set "OLLAMA_INSTALL_DIR=%TARGET_DIR%"
powershell -Command "$env:OLLAMA_INSTALL_DIR='%TARGET_DIR%'; $ProgressPreference='SilentlyContinue'; irm https://ollama.com/install.ps1 | iex"
if %errorlevel% neq 0 (
    echo [!] Online bootstrap exited with error code: %errorlevel%
    goto ERROR
)
goto END_INSTALL

:END_INSTALL
echo.
echo =====================================================================
echo [*] Success! Installation/Configuration complete.
echo.
echo     Installed Binaries:  %TARGET_DIR%
echo     AI Models Directory: %MODELS_DIR%
echo =====================================================================
echo.
echo Press any key to exit...
pause > nul
exit /b 0

:ERROR
echo.
echo =====================================================================
echo [!] FAILURE: !ERR_MSG!
echo =====================================================================
echo.
echo Press any key to exit...
pause > nul
exit /b 1

:ERROR_NO_VAR
echo.
echo =====================================================================
echo [!] FAILURE: Privileges check failed.
echo =====================================================================
echo.
echo Press any key to exit...
pause > nul
exit /b 1
