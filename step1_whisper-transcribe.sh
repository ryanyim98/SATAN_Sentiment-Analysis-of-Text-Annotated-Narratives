
#conda create -n whisperenv python=3.10
# conda activate whisperenv
# conda install numpy torch whisper
export KMP_DUPLICATE_LIB_OK=TRUE

for file in videos/*.mp4; do
    whisper "$file" --language en --word_timestamps True --max_words_per_line 30 --hallucination_silence_threshold 0.3 --initial_prompt 'Break sentences at periods ONLY.'
done
# optional model specs: --model large
