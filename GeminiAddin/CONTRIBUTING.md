# Contributing to GeminiAddin

We welcome contributions! This addin is designed to be the fastest, most autonomous AI assistant for RStudio. We are specifically looking for contributions that improve **performance**, **autonomy**, and **user experience**.

## 🚀 Areas for Performance Improvement

If you want to make this addin faster and smarter, here are the key areas to focus on:

### 1. Context Management (Critical)
Currently, the "Smart Fix" feature sends the *entire* active file to the API.
*   **The Problem**: For large scripts (1000+ lines), this is slow and consumes huge token quotas.
*   **The Solution**: Implement "Smart Chunking".
    *   Analyze the error line number.
    *   Extract only the relevant function or code block surrounding the error.
    *   Send only that chunk to Gemini.
    *   *Contribution Goal*: Write a function in `gemini_context.R` that intelligently slices the `document_context` before sending it.

### 2. Prompt Engineering
The speed and quality of the fix depend heavily on the prompt.
*   **Current State**: We use a generic "Fix this code" prompt.
*   **Optimization**: Experiment with "Chain of Thought" or specific system instructions that reduce hallucination and force concise code-only responses.
*   *Contribution Goal*: Optimize `call_gemini` prompts to reduce "Time to First Token" and improve fix accuracy.

### 3. Asynchronous "Auto-Fix"
Currently, `autoFixSelection` runs in the main R session and blocks the console while waiting for the API.
*   **The Problem**: The user cannot type while the fix is being generated.
*   **The Solution**: Move the API call to a background job or `promises` pipeline, then use `rstudioapi` to update the editor once the promise resolves.
*   *Contribution Goal*: Refactor `gemini_context.R` to use the `promises` package for non-blocking API calls.

## 🛠️ Development Setup

1.  **Clone the repo**:
    ```bash
    git clone https://github.com/YOUR_USERNAME/GeminiAddin.git
    ```
2.  **Open in RStudio**: Open the `GeminiAddin.Rproj` file.
3.  **Install Dependencies**:
    ```r
    devtools::install_deps()
    ```
4.  **Load All**:
    ```r
    devtools::load_all()
    ```
5.  **Test Changes**:
    Run `launchGeminiBackground()` or invoke the addins from the Addins menu.

## 📦 Pull Request Process

1.  Fork the repository.
2.  Create a feature branch (`git checkout -b feature/smart-chunking`).
3.  Commit your changes.
4.  Push to the branch.
5.  Open a Pull Request.

**Please include a description of how your change improves performance or functionality.**
