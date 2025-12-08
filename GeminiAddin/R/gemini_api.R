#' Call Gemini API
#'
#' @param prompt The text prompt to send to Gemini.
#' @param api_key The API key for Gemini.
#' @param model The model to use (default: gemini-2.0-flash).
#' @return The generated text response.
#' @import httr
#' @import jsonlite
#' @export
call_gemini <- function(prompt, api_key, model = "gemini-2.0-flash") {
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
    stop(paste("Error calling Gemini API:", httr::content(response, "text", encoding = "UTF-8")))
  }
  
  content <- httr::content(response, "parsed")
  tryCatch({
    text <- content$candidates[[1]]$content$parts[[1]]$text
    return(text)
  }, error = function(e) {
    return(paste("Error parsing response:", e$message))
  })
}
