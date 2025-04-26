!!!#please download FFMPEG. https://ffmpeg.org/download.html#build-windows
!!!#Also, setting  Google Cloud API Key

install.packages(c("audio", "httr", "jsonlite", "reticulate"))
library(httr)
library(jsonlite)
library(base64enc) 

mp3_file <- "D:/download/exp_video.mp3"

wav_file <- "D:/download/exp_video.wav"

system(sprintf("ffmpeg -i %s -ar 16000 -ac 1 %s", shQuote(mp3_file), shQuote(wav_file)))

audio_content <- base64enc::base64encode(wav_file)

request <- list(
  config = list(
    encoding = "LINEAR16",
    sampleRateHertz = 16000,
    languageCode = "en-US" # Set desired language
  ),
  audio = list(
    content = audio_content
  )
)

api_url <- "https://speech.googleapis.com/v1/speech:recognize"
api_key <- "xxx" # Replace with Google API Key
response <- POST(
  url = paste0(api_url, "?key=", api_key),
  body = toJSON(request, auto_unbox = TRUE),
  encode = "json",
  content_type_json()
)

result <- content(response, "parsed")

if (!is.null(result$results)) {
  transcript <- sapply(result$results, function(x) x$alternatives[[1]]$transcript)
  print(transcript)
} else {
  print("No transcript available.")
}

