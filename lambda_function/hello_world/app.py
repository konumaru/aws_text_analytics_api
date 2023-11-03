import json
from io import BytesIO
from typing import Any, Dict

# import boto3
# import joblib
# from sklearn.feature_extraction.text import TfidfVectorizer


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    # S3からモデルを読み込み
    # s3 = boto3.client("s3")
    # response = s3.get_object(
    #     Bucket="my-text-classification-model",
    #     Key="text_classification_model.joblib",
    # )
    # model = joblib.load(BytesIO(response["Body"].read()))

    # リクエストからテキストデータを取得
    text = event["text"]

    # テキストデータの分類
    # label = model.predict([text])[0]
    label = "Hello world!"

    # 結果を返す
    return {"statusCode": 200, "body": json.dumps({"message": label})}
