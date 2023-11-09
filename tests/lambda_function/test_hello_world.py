import json

from lambda_function.text_processing.app import lambda_handler


def test_hello_world() -> None:
    event = {"text": ""}
    context = None
    response = lambda_handler(event, context)

    assert response["statusCode"] == 200
    assert json.loads(response["body"]) == {"message": "Hello world!"}
