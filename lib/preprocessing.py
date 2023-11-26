from typing import List

import nltk
import numpy as np
from gensim.models import KeyedVectors
from nltk.tokenize import word_tokenize


class TextToVec:
    def __init__(
        self,
        tokenizer_path: str,
        glove_model_path: str,
    ) -> None:
        nltk.data.path.append(tokenizer_path)
        nltk.data.load(tokenizer_path)

        self.model = KeyedVectors.load_word2vec_format(
            glove_model_path, binary=False, no_header=True
        )

    def preprocess(self, text) -> List[str]:
        return word_tokenize(text, language="english")

    def get_word_vector(self, word: str) -> List[float] | None:
        # 単語のベクトルを取得する。モデルに存在しない単語の場合はNoneを返す
        return self.model[word] if word in self.model else None

    def text_to_vec(self, text) -> np.ndarray:
        words = self.preprocess(text)
        vectors = [self.get_word_vector(word) for word in words]

        # Noneの要素を除去
        vectors = [vec for vec in vectors if vec is not None]

        # ベクトルの平均を計算
        if vectors:
            return np.mean(vectors, axis=0)  # type: ignore
        else:
            return np.zeros(self.model.vector_size)
