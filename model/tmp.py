from lib.preprocessing import TextToVec

tokenizer_path = "data/tokenizers/punkt/english.pickle"
glove_path = (
    "data/wv_models/gensim/glove.twitter.27B/glove.twitter.27B.25d.txt"
)
text_processor = TextToVec(tokenizer_path, glove_path)

text = "This is an example sentence."
vector = text_processor.text_to_vec(text)
print(vector)
