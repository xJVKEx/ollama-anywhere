# 🦙 Ollama Anywhere

A fully automated, dynamic, and 100% portable Windows installer and restorer script for **Ollama**. This setup enables you to run Ollama from any drive or folder (e.g. `D:\AI(s)\ollama` or an external USB) and permanently routes all massive Large Language Models (LLMs) to store in the same custom directory, keeping your **C:** drive fast and clean.

Created by [xjvkex](https://github.com/xjvkex).

---

## ✨ Features

* 🚀 **100% Portable & Dynamic:** Auto-detects the active drive and directory where it is run (using `%~dp0`). You can drop this entire folder onto any drive and run the `.bat` file to install it exactly *there*.
* 💾 **Smart Model Redirect:** Automatically configures the persistent User environment variable `OLLAMA_MODELS` to point to a local `models/` folder inside this directory.
* 🌐 **Dual Installation Modes:**
  * **Offline Mode:** Uses the local `OllamaSetup.exe` (if present) to install instantly in 5 seconds.
  * **Online Mode:** If the installer is missing, it automatically fetches and runs the latest official Ollama Windows setup bootstrap online.
* 🛠️ **Auto PATH Setup:** Automatically appends the installation folder to your Windows User `PATH` environment variable so you can run the `ollama` CLI command from any new terminal.
* 🪟 **Parentheses-Safe:** Engineered using `GOTO` branching to bypass classic Windows Command Prompt parsing bugs when directories contain parentheses (like `d:\AI(s)\ollama`).

---

## 📂 Project Structure

```
ollama-anywhere/
├── install_ollama.bat  <-- The automated setup script
├── .gitignore          <-- Excludes massive binaries & models from Git
├── README.md           <-- This documentation file
├── OllamaSetup.exe     <-- (Optional) The offline installer (~2 GB)
└── models/             <-- (Generated) Stores downloaded AI models
```

---

## 🚀 How to Use

### First Time or After Wiping Windows:
1. Open this folder on your desired drive (e.g., `D:\AI(s)\ollama`).
2. Double-click **`install_ollama.bat`** (or run it from PowerShell).
3. The script will:
   * Create the local `models` directory.
   * Add the environment variables permanently.
   * Silently install Ollama.
4. **Important:** Close any open terminal windows and open a new one to reload your updated `PATH`.
5. Run your favorite local LLMs! For example:
   ```cmd
   ollama run llama3
   ```

---

## 🔄 Updates

* **Automated background updates:** Ollama has built-in auto-updates. Once running in your taskbar system tray, it will automatically notify you and update itself in place.
* **Forced fresh install:** If you ever want to force a brand-new installer download from the web, simply delete `OllamaSetup.exe` and run `install_ollama.bat`. The script will pull the latest setup directly from Ollama's official CDN!

---

## ⚖️ License

This setup utility is open-source and free to use. Ollama itself is distributed under the **MIT License**.
