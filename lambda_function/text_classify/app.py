import json
import pickle
from typing import Any, Dict, List

import nltk


def load_model(path: str) -> Any:
    with open(path, "rb") as f:
        model = pickle.load(f)
    return model


nltk.data.path.append(".")
nltk.data.load("tokenizers/punkt/PY3/english.pickle")
model = load_model("data/20newsgroups.pkl")


def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    result = model.predict([event["input_text"]])[0]
    return {"statusCode": 200, "body": json.dumps({"result": str(result)})}
