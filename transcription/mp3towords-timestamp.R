# Install necessary packages
install.packages(c("audio", "httr", "jsonlite", "reticulate", "googleAuthR"))
library(httr)
library(jsonlite)
library(base64enc)
library(googleAuthR)

# Authenticate using a service account JSON file
gar_auth_service(
  json_file = "xxx" #replace with your local json key
)

# Define the GCS URI for the audio file
gcs_uri <- "gs://justmercy_video_bucket/audio-files/user_118_testimonial_117_stimuli_407_.wav"

# Define API endpoint for long-running speech recognition
api_url <- "https://speech.googleapis.com/v1/speech:longrunningrecognize"

# Prepare the request payload
request_body <- list(
  config = list(
    encoding = "LINEAR16",                   # Audio encoding type (for WAV files)
    sampleRateHertz = 16000,                 # Sample rate (16kHz for your audio file)
    languageCode = "en-US",                  # Language code
    enableWordTimeOffsets = TRUE             # Enable word-level time offsets
  ),
  audio = list(
    uri = gcs_uri                            # Audio file URI on Google Cloud Storage
  )
)

# Send the request using POST method
response <- POST(
  url = api_url,
  body = toJSON(request_body, auto_unbox = TRUE),  # Convert request body to JSON format
  add_headers(
    "Authorization" = paste("Bearer", googleAuthR::gar_token()$access_token),  # Authorization header with token
    "Content-Type" = "application/json"           # Specify content type as JSON
  )
)

# Parse the response to get the operation name
operation <- content(response, "parsed")
operation_name <- operation$name

# Poll for completion of the long-running operation
repeat {
  Sys.sleep(5)  # Wait for 5 seconds between polls
  op_response <- GET(
    url = paste0("https://speech.googleapis.com/v1/operations/", operation_name)
  )
  op_result <- content(op_response, "parsed")
  if (!is.null(op_result$done) && op_result$done) break  # Exit when the operation is complete
}

# Process the transcription results
if (!is.null(op_result$response$results)) {
  for (res in op_result$response$results) {
    alt <- res$alternatives[[1]]  # Get the top alternative transcript
    cat("Transcript:\n", alt$transcript, "\n\n")  # Print the transcript
    
    cat("Word Timestamps:\n")  # Print word-level timestamps
    for (word_info in alt$words) {
      word <- word_info$word
      start <- word_info$startTime
      end <- word_info$endTime
      cat(sprintf("'%s': %s to %s\n", word, start, end))
    }
  }
} else {
  cat("No transcription found.\n")
}
