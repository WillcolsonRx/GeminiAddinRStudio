# 🚀 Gemini RStudio Addin

<!-- badges: start -->
[![R](https://img.shields.io/badge/R-%3E%3D%204.0-blue.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Gemini API](https://img.shields.io/badge/Powered%20by-Google%20Gemini-orange)](https://deepmind.google/technologies/gemini/)
<!-- badges: end -->

> **Your AI Pair Programmer, directly inside RStudio.**

Integrate the power of Google's **Gemini API** directly into your R coding workflow. No more switching tabs to ChatGPT or Google. Get explanations, fix bugs, and write code without ever leaving the IDE.

---

## ✨ Features

### 🧠 Smart Context Awareness
*   **Explain Selection**: Highlight any confusing code, click a button, and get an instant explanation.
*   **Explain Error**: Stuck on a cryptic R error? Send it to Gemini with one click for a plain-English solution.

### ⚡ Autonomous Coding
*   **Auto-Fix Selection**: Highlight broken code, click "Auto-Fix", and watch as Gemini **rewrites it in place** for you.
*   **Smart Fix (File & Error)**: The "Antigravity" feature. It analyzes your **entire script** and the **last error** to autonomously find and fix bugs across the file.

### 🛠️ Non-Blocking Workflow
*   **Background Mode**: The chat interface runs in a background job, so your R console remains **completely free** for you to keep coding while you chat.

---

## 📦 Installation

You can install `GeminiAddin` directly from GitHub or via a manual download.

### Option 1: From GitHub (Recommended)

```r
# 1. Install devtools if you haven't already
if (!require("devtools")) install.packages("devtools")

# 2. Install the package
devtools::install_github("WillcolsonRx/GeminiAddinRstudio", subdir = "GeminiAddin")
```

### Option 2: Offline / Manual Installation

If you have downloaded the `GeminiAddin_0.1.2.tar.gz` file:

1.  Open RStudio.
2.  Run:
    ```r
    install.packages("path/to/GeminiAddin_0.1.2.tar.gz", repos = NULL, type = "source")
    ```

---

## 🔑 Setup

You need a Google Gemini API Key to use this addin.
[**Get your free API Key here**](https://aistudio.google.com/)

### Secure Configuration
Run this command in your R console to set your key (persists for the session):

```r
Sys.setenv(GEMINI_API_KEY = "AIzaSy...")
```

By default, the addin now uses `gemini-2.5-flash-lite`, which is the most quota-friendly stable Gemini 2.5 text model for free-tier usage. If you want to override that, you can also set:

```r
Sys.setenv(GEMINI_MODEL = "gemini-2.5-flash-lite")
```

If you want slightly stronger quality and your quota allows it, switch to `gemini-2.5-flash`. If you have paid quota and want the strongest reasoning model, use `gemini-2.5-pro`.

**Recommended:** To make it permanent, add it to your `.Renviron` file:
1.  Run `usethis::edit_r_environ()`
2.  Add the line: `GEMINI_API_KEY=AIzaSy...`
3.  Restart RStudio.

---

## 🚀 Usage

### 1. Start the Assistant
Go to **Addins** -> **Launch Gemini (Background)**.
*   The chat window will open in your **Viewer** pane.
*   You can now chat with Gemini while running code in the console!

### 2. Fix Bugs Instantly
Encounter an error?
*   **Don't panic.**
*   Click **Addins** -> **Gemini: Smart Fix (File & Error)**.
*   Gemini will analyze your script and the error, then **automatically apply the fix** to your file.

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit Pull Requests.

## 📄 License

This project is licensed under the [MIT License](LICENSE).
