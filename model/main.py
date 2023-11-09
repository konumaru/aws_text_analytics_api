import joblib
from sklearn.datasets import fetch_20newsgroups
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline

# データの読み込み
categories = ["alt.atheism", "soc.religion.christian"]
newsgroups = fetch_20newsgroups(subset="train", categories=categories)
X, y = newsgroups["data"], newsgroups["target"]

# データの分割
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# モデルの学習
pipeline = make_pipeline(TfidfVectorizer(), LogisticRegression())
model = pipeline.fit(X_train, y_train)

# モデルの評価
y_pred = model.predict(X_test)
print("Accuracy: {:.2f}".format(accuracy_score(y_test, y_pred)))

# モデルの保存
joblib.dump(model, "text_classification_model.joblib")
