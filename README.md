# 🦙 Ollama Anywhere

A fully automated, dynamic, and 100% portable Windows installer and restorer script for **Ollama**. This setup enables you to run Ollama from any drive or folder (e.g. `D:\AI(s)\ollama` or an external USB) and permanently routes all massive Large Language Models (LLMs) to store in the same custom directory, keeping your **C:** drive fast and clean.

Created by [xjvkex](https://github.com/xjvkex).

---

## ✨ Features

* 🚀 **100% Portable & Dynamic:** Auto-detects the active drive and directory where it is run (using `%~dp0`). You can drop this entire folder onto any drive and run the `.bat` file to install it exactly *there*.
* 🛡️ **Admin Privilege Verification:** Built-in validation to ensure registry edits and PATH configurations succeed without silent permissions failures.
* 💾 **System-Wide Model Redirect:** Configures the permanent system-wide `OLLAMA_MODELS` environment variable (`setx /M`) to point to a local `models/` folder inside this directory. This guarantees that all users on the computer utilize the secondary drive models directory, avoiding the typical elevated admin user setx registry isolation.
* 🔄 **Smart Reinstall / Restore Check:** If you run the script and Ollama is already present (e.g., after a fresh Windows wipe but keeping secondary drives intact), the script automatically detects it, shows the installed version, and offers to **skip binary installation** while instantly restoring your environment variables and PATH configs.
* 🌐 **Dual Installation Modes:**
  * **Offline Mode:** Uses the local `OllamaSetup.exe` (if present) to install in about 15-30 seconds depending on system specs.
  * **Online Mode:** If the installer is missing, it automatically fetches and runs the latest official Ollama Windows setup bootstrap online.
* 🛠️ **System-Wide Auto PATH Setup:** Automatically appends the installation folder to your Windows system-wide **Machine `PATH`** environment variable. This ensures the `ollama` CLI command is globally recognized by all system users, preventing the elevated-admin UAC profile isolation bug that typical user PATH additions cause on Windows.
* 🪟 **Diagnostics & Error Handling:** Explicit diagnostic messages print exactly which step (directory creation, environment writing, or installer execution) failed. Uses safe non-delayed expansions to avoid block-jumping parsing quirks.
* 🪟 **Parentheses-Safe:** Engineered using `GOTO` branching to bypass classic Windows Command Prompt parsing bugs when directories contain parentheses (like `d:\AI(s)\ollama`).

---

## 📂 Project Structure

```
ollama-anywhere/
├── install_ollama.bat  <-- The automated setup script (Run as Admin)
├── .gitignore          <-- Excludes massive binaries & models from Git
├── README.md           <-- This documentation file
├── OllamaSetup.exe     <-- (Optional) The offline installer (~2 GB)
└── models/             <-- (Generated) Stores downloaded AI models
```

---

## 🚀 How to Use

### First Time or After Wiping Windows:
1. Open this folder on your desired drive (e.g., `D:\AI(s)\ollama`).
2. Right-click **`install_ollama.bat`** and select **Run as Administrator**.
3. The script will:
   * Setup target folders.
   * Add environment variables system-wide.
   * Silently install or restore Ollama.
4. **Important:** Close any open terminal windows and open a new one to reload your updated `PATH`.
5. Run your favorite local LLMs! For example:
   ```cmd
   ollama run llama3
   ```

---

## 🔄 Updates & Technical Assumptions

* **Automated background updates:** Ollama has built-in auto-updates. Once running in your taskbar system tray, it will automatically notify you and update itself in place.
* **Forced fresh install:** If you ever want to force a brand-new installer download from the web, simply delete `OllamaSetup.exe` and run `install_ollama.bat`. The script will pull the latest setup directly from Ollama's official CDN!
* **Installer Architecture Assumption:** Offline silent installation relies on `/DIR=` arguments which assume the installer uses Inno Setup. While stable, this is an undocumented installer switch and could shift if Ollama changes installer compilers in the future.

---

## ⚖️ License

This setup utility is open-source and free to use. Ollama itself is distributed under the **MIT License**.
