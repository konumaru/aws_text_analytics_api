from typing import Dict, List

import fasttext
import joblib
from fastapi import FastAPI
from mangum import Mangum
from pydantic import BaseModel

app = FastAPI()

model = joblib.load("model.joblib")
ft = fasttext.load_model("cc.en.300.bin")


def text_classify(text: str) -> int:
    embedding = model.predict([text])[0]
    return embedding


def text2embedding(text: str) -> List[float]:
    vectors = ft.get_sentence_vector(text).tolist()
    return vectors


class TextInputs(BaseModel):
    text: str


@app.post("/classification")
async def classification(text_inputs: TextInputs) -> Dict[str, str]:
    result = text_classify(text_inputs.text)
    return {"classification": str(result)}


@app.post("/embeddings")
async def embeddings(text_inputs: TextInputs) -> Dict[str, List[float]]:
    return {"embedding": text2embedding(text_inputs.text)}


@app.get("/")
async def root() -> Dict[str, str]:
    return {"message": "Hello World!"}


handler = Mangum(app)
