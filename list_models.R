library(httr)
library(jsonlite)

api_key <- "YOUR GEMINI API KEY"
url <- paste0("https://generativelanguage.googleapis.com/v1beta/models?key=", api_key)

response <- GET(url)
content <- content(response, "parsed")

if (status_code(response) == 200) {
  print("Available Models:")
  for (model in content$models) {
    print(paste("Name:", model$name))
    print(paste("Supported Generation Methods:", paste(model$supportedGenerationMethods, collapse = ", ")))
    print("---")
  }
} else {
  print(paste("Error:", content$error$message))
}
