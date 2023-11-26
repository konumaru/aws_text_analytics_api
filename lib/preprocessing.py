from typing import List, Optional

import nltk
import numpy as np
from gensim.models import KeyedVectors
from nltk.tokenize import word_tokenize
from sklearn.base import BaseEstimator, TransformerMixin


class Text2VecTransformer(BaseEstimator, TransformerMixin):
    def __init__(self, tokenizer_path: str, glove_model_path: str) -> None:
        nltk.data.path.append(tokenizer_path)
        nltk.data.load(tokenizer_path)
        self.model = KeyedVectors.load_word2vec_format(
            glove_model_path, binary=False, no_header=True
        )
        # For normalize vectors.
        self.model.init_sims(replace=True)

    def fit(self, X, y=None) -> "Text2VecTransformer":
        return self

    def transform(self, X) -> np.ndarray:
        # テキストデータをベクトルに変換する
        return np.array([self.text_to_vec(text) for text in X])

    def preprocess(self, text) -> List[str]:
        return word_tokenize(text, language="english")

    def get_word_vector(self, word: str) -> Optional[np.ndarray]:
        return self.model[word] if word in self.model else None

    def text_to_vec(self, text) -> np.ndarray:
        words = self.preprocess(text)
        vectors = [self.get_word_vector(word) for word in words]
        vectors = [vec for vec in vectors if vec is not None]
        if vectors:
            return np.mean(vectors, axis=0)
        else:
            return np.zeros(self.model.vector_size)
