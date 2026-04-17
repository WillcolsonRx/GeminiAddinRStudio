#' Gemini Assistant UI
#' @export
gemini_ui <- function() {
  miniUI::miniPage(
    miniUI::gadgetTitleBar("Gemini Assistant", right = miniUI::miniTitleBarButton("done", "Close", primary = TRUE)),
    miniUI::miniContentPanel(
      shiny::tags$head(
        shiny::tags$style(shiny::HTML("
          #response_container { 
            background-color: #f5f5f5; 
            border: 1px solid #ddd; 
            padding: 10px; 
            border-radius: 5px; 
            overflow-y: auto; 
            height: 100%; 
            white-space: pre-wrap;
            font-family: monospace;
          }
          .shiny-input-container { width: 100% !important; }
        "))
      ),
      shiny::fillCol(
        flex = c(NA, NA, 1, NA, 3),
        shiny::textInput("model", "Model:", value = get_default_gemini_model(), width = "100%"),
        shiny::textAreaInput("prompt", "Ask Gemini:", width = "100%", rows = 3),
        shiny::actionButton("send", "Send to Gemini", icon = shiny::icon("paper-plane"), class = "btn-primary", width = "100%"),
        shiny::h4("Response:"),
        shiny::div(id = "response_container", shiny::uiOutput("response_content"))
      )
    )
  )
}

#' Gemini Assistant Server
#' @export
gemini_server <- function(input, output, session) {
  # Get API Key from environment variable
  api_key <- Sys.getenv("GEMINI_API_KEY")
  
  if (nchar(api_key) == 0) {
    shiny::showNotification("Error: GEMINI_API_KEY environment variable not found. Please set it using Sys.setenv(GEMINI_API_KEY='your_key').", type = "error", duration = NULL)
  }
  
  response_val <- shiny::reactiveVal("Ready to help! Ask me anything about R or code.")
  
  # Watch for context file updates
  context_file <- file.path(tempdir(), "gemini_context.json")
  
  # Create file if it doesn't exist to avoid errors
  if (!file.exists(context_file)) {
    jsonlite::write_json(list(timestamp = 0), context_file, auto_unbox = TRUE)
  }
  
  context_data <- shiny::reactiveFileReader(1000, session, context_file, jsonlite::read_json)
  
  shiny::observeEvent(context_data(), {
    data <- context_data()
    req(data$timestamp)
    
    # Simple check to avoid re-processing old data on startup
    # In a real app, we'd compare timestamps more robustly
    if (as.numeric(Sys.time()) - data$timestamp < 5) {
      if (data$type == "selection") {
        shiny::updateTextAreaInput(session, "prompt", value = paste("Explain this code:\n\n", data$content))
        response_val("I received your code selection. Click 'Send' to explain it.")
      } else if (data$type == "error") {
        shiny::updateTextAreaInput(session, "prompt", value = paste("Fix this R error:\n\n", data$content))
        response_val("I received the error message. Click 'Send' to fix it.")
      }
    }
  })
  
  shiny::observeEvent(input$send, {
    req(input$prompt)
    response_val("Thinking...")
    
    # Call API asynchronously or directly (Shiny is single threaded usually, but this is simple)
    res <- tryCatch({
      call_gemini(input$prompt, api_key, model = input$model)
    }, error = function(e) {
      paste("Error:", e$message)
    })
    
    response_val(res)
  })
  
  output$response_content <- shiny::renderUI({
    # Render Markdown if possible, but simple text for now
    shiny::HTML(markdown::markdownToHTML(text = response_val(), fragment.only = TRUE))
  })
  
  shiny::observeEvent(input$done, {
    shiny::stopApp()
  })
}

#' Launch Gemini Assistant Addin
#'
#' Opens a Shiny Gadget to interact with Gemini.
#' @import shiny
#' @import miniUI
#' @export
launchGeminiAddin <- function() {
  ui <- gemini_ui()
  server <- gemini_server
  viewer <- shiny::paneViewer(minHeight = 300)
  shiny::runGadget(ui, server, viewer = viewer)
}
