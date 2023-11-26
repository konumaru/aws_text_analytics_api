import json

from lambda_function.hello_world.app import handler


def test_hello_world() -> None:
    event = {"text": ""}
    context = None
    response = handler(event, context)

    assert response["statusCode"] == 200
    assert json.loads(response["body"]) == {"message": "Hello world!"}
