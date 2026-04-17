#' Get Shared Context File Path
#' @return Path to the temporary JSON file
getContextFile <- function() {
  file.path(tempdir(), "gemini_context.json")
}

#' Write Context to File
#' @param type Type of context ("selection" or "error")
#' @param content The text content
#' @import jsonlite
writeContext <- function(type, content) {
  data <- list(
    type = type,
    content = content,
    timestamp = as.numeric(Sys.time())
  )
  jsonlite::write_json(data, getContextFile(), auto_unbox = TRUE)
}

#' Send Selected Code to Gemini
#' 
#' Captures the currently selected text in the source editor and sends it to the Gemini background job.
#' @import rstudioapi
#' @export
sendSelectionToGemini <- function() {
  context <- rstudioapi::getSourceEditorContext()
  selection <- context$selection[[1]]$text
  
  if (nchar(selection) == 0) {
    message("No text selected.")
    return(NULL)
  }
  
  writeContext("selection", selection)
  message("Selection sent to Gemini.")
}

#' Send Last Error to Gemini
#' 
#' Captures the last error message and sends it to the Gemini background job.
#' @export
sendErrorToGemini <- function() {
  error_msg <- geterrmessage()
  
  if (nchar(error_msg) == 0) {
    message("No error message found.")
    return(NULL)
  }
  
  writeContext("error", error_msg)
  message("Error sent to Gemini.")
}

#' Auto-Fix Selection
#' 
#' Sends the selected code to Gemini and replaces it with the fixed version.
#' @import rstudioapi
#' @export
autoFixSelection <- function() {
  api_key <- Sys.getenv("GEMINI_API_KEY")
  if (nchar(api_key) == 0) {
    stop("GEMINI_API_KEY environment variable not found. Please set it using Sys.setenv(GEMINI_API_KEY='your_key').")
  }

  context <- rstudioapi::getSourceEditorContext()
  selection <- context$selection[[1]]$text
  
  if (nchar(selection) == 0) {
    message("No text selected.")
    return(NULL)
  }
  
  message("Asking Gemini to fix the code...")
  
  prompt <- paste("Fix the following R code. Return ONLY the fixed code, no markdown formatting, no explanations.\n\nCode:\n", selection)
  
  fixed_code <- tryCatch({
    call_gemini(prompt, api_key)
  }, error = function(e) {
    message("Error calling Gemini: ", e$message)
    return(NULL)
  })
  
  if (!is.null(fixed_code)) {
    # Clean up markdown if Gemini adds it despite instructions
    fixed_code <- gsub("^```r\\s*", "", fixed_code)
    fixed_code <- gsub("^```\\s*", "", fixed_code)
    fixed_code <- gsub("\\s*```$", "", fixed_code)
    
    rstudioapi::modifyRange(context$selection[[1]]$range, fixed_code)
    message("Code fixed!")
  }
}

#' Suggest Fix for Last Error (Console)
#' 
#' Prints a suggestion for the last error to the console.
#' @export
suggestFixForError <- function() {
  api_key <- Sys.getenv("GEMINI_API_KEY")
  if (nchar(api_key) == 0) {
    stop("GEMINI_API_KEY environment variable not found. Please set it using Sys.setenv(GEMINI_API_KEY='your_key').")
  }

  error_msg <- geterrmessage()
  
  if (nchar(error_msg) == 0) {
    message("No error message found.")
    return(NULL)
  }
  
  message("Asking Gemini for a fix...")
  
  prompt <- paste("The following R error occurred:\n", error_msg, "\n\nSuggest a fix or explain what went wrong. Be concise.")
  
  suggestion <- tryCatch({
    call_gemini(prompt, api_key)
  }, error = function(e) {
    message("Error calling Gemini: ", e$message)
    return(NULL)
  })
  
  if (!is.null(suggestion)) {
    cat("\n--- Gemini Suggestion ---\n")
    cat(suggestion)
    cat("\n-------------------------\n")
  }
}

#' Smart Fix (File & Error)
#' 
#' Reads the entire active file and the last error, then rewrites the file with the fix.
#' @import rstudioapi
#' @export
smartFixFile <- function() {
  api_key <- Sys.getenv("GEMINI_API_KEY")
  if (nchar(api_key) == 0) {
    stop("GEMINI_API_KEY environment variable not found. Please set it using Sys.setenv(GEMINI_API_KEY='your_key').")
  }
  
  # Get active document
  context <- rstudioapi::getActiveDocumentContext()
  content <- paste(context$contents, collapse = "\n")
  
  if (nchar(content) == 0) {
    message("Active document is empty.")
    return(NULL)
  }
  
  # Get last error
  error_msg <- geterrmessage()
  
  message("Analyzing file and error...")
  
  prompt <- paste0(
    "You are an expert R programmer. I have an R script that is producing an error.\n",
    "Error Message: ", error_msg, "\n\n",
    "Script Content:\n", content, "\n\n",
    "Task: Fix the script to resolve the error. Return ONLY the full fixed script content. ",
    "Do not include markdown formatting (like ```r). Do not include explanations. Just the code."
  )
  
  fixed_code <- tryCatch({
    call_gemini(prompt, api_key)
  }, error = function(e) {
    message("Error calling Gemini: ", e$message)
    return(NULL)
  })
  
  if (!is.null(fixed_code)) {
    # Clean up markdown if Gemini adds it
    fixed_code <- gsub("^```r\\s*", "", fixed_code)
    fixed_code <- gsub("^```\\s*", "", fixed_code)
    fixed_code <- gsub("\\s*```$", "", fixed_code)
    
    # Update the file
    rstudioapi::setDocumentContents(fixed_code, id = context$id)
    message("File updated with Smart Fix!")
  }
}
