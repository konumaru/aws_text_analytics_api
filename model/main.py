import pathlib
import pickle
from typing import Any

from sklearn.datasets import fetch_20newsgroups
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

from lib.preprocessing import Text2VecTransformer


def save_model(model: Any, path: str | pathlib.Path) -> None:
    with open(path, "wb") as f:
        pickle.dump(model, f)


def main() -> None:
    # Load and split data
    newsgroups = fetch_20newsgroups(subset="all")
    X, y = newsgroups["data"], newsgroups["target"]  # type: ignore
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # Train model
    tokenizer_path = "data/tokenizers/punkt/english.pickle"
    glove_path = (
        "data/wv_models/gensim/glove.twitter.27B/glove.twitter.27B.25d.txt"
    )
    pipeline = make_pipeline(
        Text2VecTransformer(tokenizer_path, glove_path),
        StandardScaler(),
        LogisticRegression(solver="liblinear", C=0.1, random_state=42),
    )
    model = pipeline.fit(X_train, y_train)

    # Evaluate model
    y_pred = model.predict(X_test)
    print("Accuracy: {:.2f}".format(accuracy_score(y_test, y_pred)))

    # Save model
    save_dir = pathlib.Path(__file__).parent / "../data/model"
    save_dir.mkdir(exist_ok=True, parents=True)
    save_model(model, save_dir / "20newsgroups.pkl")


if __name__ == "__main__":
    main()
