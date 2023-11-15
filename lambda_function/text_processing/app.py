# import fasttext
import pickle
from typing import Any, Dict, List

from fastapi import FastAPI
from mangum import Mangum
from pydantic import BaseModel

app = FastAPI()


def load_model(path: str) -> Any:
    with open(path, "rb") as f:
        model = pickle.load(f)
    return model


model = load_model("data/model/20newsgroups.pkl")
# ft = fasttext.load_model("data/fasttext_models/cc.en.300.bin")


def text_classify(text: str) -> int:
    embedding = model.predict([text])[0]
    return embedding


def text2embedding(text: str) -> List[float]:
    vectors = [0.0] * 300
    # vectors = ft.get_sentence_vector(text).tolist()
    return vectors


class TextInputs(BaseModel):
    text: str


@app.post("/classification")
def classification(text_inputs: TextInputs) -> Dict[str, str]:
    result = text_classify(text_inputs.text)
    return {"classification": str(result)}


@app.post("/embeddings")
def embeddings(text_inputs: TextInputs) -> Dict[str, List[float]]:
    return {"embedding": text2embedding(text_inputs.text)}


@app.get("/")
def root() -> Dict[str, str]:
    return {"message": "Hello World!"}


handler = Mangum(app)
