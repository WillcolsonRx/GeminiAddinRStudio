#' Get the default Gemini model
#'
#' Uses `GEMINI_MODEL` when set, otherwise falls back to the current stable
#' text model used by this addin.
#'
#' @return A Gemini model name.
get_default_gemini_model <- function() {
  model <- trimws(Sys.getenv("GEMINI_MODEL", unset = ""))

  if (!nzchar(model)) {
    return("gemini-2.5-flash-lite")
  }

  model
}

#' Call Gemini API
#'
#' @param prompt The text prompt to send to Gemini.
#' @param api_key The API key for Gemini.
#' @param model The model to use (default: `GEMINI_MODEL` or `gemini-2.5-flash-lite`).
#' @return The generated text response.
#' @import httr
#' @import jsonlite
#' @export
call_gemini <- function(prompt, api_key, model = get_default_gemini_model()) {
  if (is.null(model) || !nzchar(trimws(model))) {
    model <- get_default_gemini_model()
  } else {
    model <- trimws(model)
  }

  url <- paste0("https://generativelanguage.googleapis.com/v1beta/models/", model, ":generateContent?key=", api_key)
  
  body <- list(
    contents = list(
      list(
        parts = list(
          list(text = prompt)
        )
      )
    )
  )
  
  response <- httr::POST(
    url,
    httr::add_headers("Content-Type" = "application/json"),
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    encode = "json"
  )
  
  if (httr::status_code(response) != 200) {
    response_text <- httr::content(response, "text", encoding = "UTF-8")

    if (httr::status_code(response) == 429) {
      stop(
        paste0(
          "Gemini quota exceeded for model '", model, "'. ",
          "Set GEMINI_MODEL to a lower-cost model such as 'gemini-2.5-flash' or 'gemini-2.5-flash-lite', ",
          "or wait for quota reset. API response: ",
          response_text
        )
      )
    }

    stop(paste0("Error calling Gemini API for model '", model, "': ", response_text))
  }
  
  content <- httr::content(response, "parsed")
  tryCatch({
    text <- content$candidates[[1]]$content$parts[[1]]$text
    return(text)
  }, error = function(e) {
    return(paste("Error parsing response:", e$message))
  })
}
