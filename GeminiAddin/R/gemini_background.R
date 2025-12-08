#' Launch Gemini Assistant in Background
#'
#' Opens the Gemini Assistant in a background job so it doesn't block the console.
#' @import rstudioapi
#' @export
#' Launch Gemini Assistant in Background (Viewer)
#'
#' Opens the Gemini Assistant in a background job and displays it in the Viewer pane.
#' This allows you to use the R console while the assistant is running.
#' @import rstudioapi
#' @export
launchGeminiBackground <- function(port = NULL) {
  if (is.null(port)) {
    # Random port between 3000 and 9000 to avoid conflicts
    port <- floor(stats::runif(1, 3000, 9000))
  }
  
  # Create a temporary script to run the app
  app_script <- tempfile(fileext = ".R")
  
  # We use shinyApp directly instead of runGadget for the background service
  script_content <- sprintf('
library(GeminiAddin)
library(shiny)

# Define UI and Server
ui <- gemini_ui()
server <- gemini_server

# Run as a standard Shiny app on localhost
# host="127.0.0.1" is crucial for rstudioapi::viewer to work securely
shiny::runApp(shiny::shinyApp(ui, server), port = %d, launch.browser = FALSE, host = "127.0.0.1")
', port)
  
  writeLines(script_content, app_script)
  
  # Run as a background job
  if (rstudioapi::isAvailable()) {
    rstudioapi::jobRunScript(
      path = app_script,
      name = "Gemini Backend",
      workingDir = getwd(),
      importEnv = FALSE
    )
    
    message("Starting Gemini backend...")
    # Give the background job a moment to start listening
    Sys.sleep(2) 
    
    # Open in RStudio Viewer
    # This points the internal browser to the background job's port
    rstudioapi::viewer(sprintf("http://127.0.0.1:%d", port))
    
    message("Gemini Assistant is running in the Viewer pane. Your console is free!")
  } else {
    warning("RStudio API not available. Cannot start background job.")
  }
}
