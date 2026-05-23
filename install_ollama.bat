@echo off
:: =====================================================================
:: Ollama Custom Automated Installer / Restorer (Dynamic Edition)
:: =====================================================================
:: This script automatically installs Ollama exactly where this script
:: is run from (on any drive or folder). It sets the model folder 
:: locally to save space on your C: drive.
:: =====================================================================

title Ollama Anywhere Installer
echo =====================================================================
echo                     Ollama Anywhere Installer
echo =====================================================================
echo.

:: 1. Define Paths Dynamically (Based on where this script is located)
set "SCRIPT_DIR=%~dp0"
:: Strip trailing backslash from SCRIPT_DIR
if "%SCRIPT_DIR:~-1%"=="\" set "TARGET_DIR=%SCRIPT_DIR:~0,-1%"
if not defined TARGET_DIR set "TARGET_DIR=%SCRIPT_DIR%"

set "MODELS_DIR=%TARGET_DIR%\models"
set "INSTALLER_NAME=OllamaSetup.exe"

:: 2. Create directories if they do not exist (Avoiding parenthesis blocks)
echo [*] Creating target directories...
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
if not exist "%MODELS_DIR%" mkdir "%MODELS_DIR%"
echo     Target Location: %TARGET_DIR%
echo     Models Location: %MODELS_DIR%

:: 3. Configure the OLLAMA_MODELS Environment Variable
echo [*] Setting OLLAMA_MODELS environment variable...
:: Set permanently in the User registry (for future CMD/PowerShell windows)
setx OLLAMA_MODELS "%MODELS_DIR%" > nul
:: Set in the current active session
set "OLLAMA_MODELS=%MODELS_DIR%"
echo     OLLAMA_MODELS is set to: %MODELS_DIR%

:: 4. Add Ollama directory to User PATH
echo [*] Adding Ollama to your User PATH...
powershell -Command "$p=[Environment]::GetEnvironmentVariable('Path','User'); if($p -split ';' -notcontains '%TARGET_DIR%'){$newPath = ($p + ';%TARGET_DIR%') -replace ';;',';'; [Environment]::SetEnvironmentVariable('Path',$newPath,'User'); Write-Host '    Successfully added to PATH.'} else {Write-Host '    Already in PATH.'}"

:: 5. Install Ollama using GOTO branching to avoid parentheses bugs
echo [*] Checking for installer...
if exist "%TARGET_DIR%\%INSTALLER_NAME%" goto RUN_LOCAL
goto RUN_ONLINE

:RUN_LOCAL
echo     Found local installer. Launching offline installation...
echo     Installing to: %TARGET_DIR%
:: Run installer silently with custom directory
start /wait "" "%TARGET_DIR%\%INSTALLER_NAME%" /DIR="%TARGET_DIR%" /VERYSILENT /NORESTART /SUPPRESSMSGBOXES
goto END_INSTALL

:RUN_ONLINE
echo     Local installer not found. Running online bootstrap...
echo     Installing to: %TARGET_DIR%
:: Set the OLLAMA_INSTALL_DIR env variable for the session
set "OLLAMA_INSTALL_DIR=%TARGET_DIR%"
:: Call the official PowerShell installer script
powershell -Command "$env:OLLAMA_INSTALL_DIR='%TARGET_DIR%'; $ProgressPreference='SilentlyContinue'; irm https://ollama.com/install.ps1 | iex"
goto END_INSTALL

:END_INSTALL
echo.
echo =====================================================================
echo [*] Installation complete!
echo.
echo     Installed Binaries:  %TARGET_DIR%
echo     AI Models Directory: %MODELS_DIR%
echo =====================================================================
echo.
echo Press any key to exit...
pause > nul
