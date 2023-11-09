import json
from typing import Any, Dict


def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    message = "Hello world!"

    return {"statusCode": 200, "body": json.dumps({"message": message})}
