prerequisite: install whisper (https://github.com/openai/whisper)

*step 1: whisper-transcribe.sh*

input: video/audio files (mp4 etc.); output: json, tsv, sst, rst

*step 2: vader-sentiment-analysis.Rmd*

input: tsv; output: csv

*step 3: step3_SentimentAnalysis_OpenAI_LLM_interface.ipynb*

input: csv; output: csv
