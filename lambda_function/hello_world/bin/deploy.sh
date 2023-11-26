#!/bin/bash

ORIGIN_DIR_NAME=$(basename $(dirname $(dirname $(realpath $0))))
DIR_NAME="${ORIGIN_DIR_NAME//_/-}"

echo "Deploying $DIR_NAME"

export LAMBDA_FUNCTION_NAME=$DIR_NAME
export LAMBDA_EXECUTION_ROLE=$(aws iam get-role --role-name LambdaExecutionRole --query 'Role.Arn' --output text)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
export AWS_DEFAULT_REGION=$(echo $AWS_DEFAULT_REGION)

clean_existing_resources() {
    echo "Cleaning existing resources..."
    function_name="$1"
    if aws lambda get-function --function-name $function_name 2>&1 | grep -q 'Function not found'; then
        echo "Not existing Lambda function $function_name..."
    else
        # 存在する場合は削除
        echo "Deleting Lambda function $function_name..."
        aws lambda delete-function --function-name $function_name

        if [ $? -eq 0 ]; then
            echo "Complete to delete Lambda function $function_name."
        else
            echo "Failed to delete Lambda function $function_name."
        fi
    fi

    aws ecr delete-repository --repository-name $function_name --force
}


clean_existing_resources $LAMBDA_FUNCTION_NAME

# Build docker image
sudo docker build -t $LAMBDA_FUNCTION_NAME:latest .

aws ecr describe-repositories --repository-names $LAMBDA_FUNCTION_NAME || aws ecr create-repository --repository-name $LAMBDA_FUNCTION_NAME
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
sudo docker tag $LAMBDA_FUNCTION_NAME:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$LAMBDA_FUNCTION_NAME:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$LAMBDA_FUNCTION_NAME:latest

aws lambda create-function --function-name $LAMBDA_FUNCTION_NAME \
    --package-type Image \
    --code ImageUri=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$LAMBDA_FUNCTION_NAME:latest \
    --role $LAMBDA_EXECUTION_ROLE \
    --architectures arm64 \
    --memory-size 512 --timeout 10

# Local test
# docker run -p 9000:8080 hello_world:latest
# curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'

# # Create API Gateway
aws apigateway create-resource \
    --rest-api-id $AWS_API_GATEWAY_REST_API_ID \
    --parent-id $AWS_API_GATEWAY_ROOT_RESOURCE_ID \
    --path-part $LAMBDA_FUNCTION_NAME

export RESOURCE_ID=$(
    aws apigateway get-resources --rest-api-id $AWS_API_GATEWAY_REST_API_ID | \
    jq -r ".items[] | select(.path == \"/${LAMBDA_FUNCTION_NAME}\") | .id"
)

aws apigateway put-method \
    --rest-api-id $AWS_API_GATEWAY_REST_API_ID \
    --resource-id $RESOURCE_ID \
    --http-method ANY \
    --authorization-type "NONE"

export LAMBDA_ARN=$(aws lambda get-function --function-name $LAMBDA_FUNCTION_NAME | jq -r '.Configuration.FunctionArn')
aws apigateway put-integration \
    --rest-api-id $AWS_API_GATEWAY_REST_API_ID \
    --resource-id $RESOURCE_ID \
    --http-method ANY \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri "arn:aws:apigateway:${AWS_DEFAULT_REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN}/invocations"

aws lambda add-permission \
    --function-name $LAMBDA_FUNCTION_NAME \
    --statement-id 'apigateway-test' \
    --action 'lambda:InvokeFunction' \
    --principal apigateway.amazonaws.com \
    --source-arn "arn:aws:execute-api:${AWS_DEFAULT_REGION}:${AWS_ACCOUNT_ID}:${AWS_API_GATEWAY_REST_API_ID}/*/*/${LAMBDA_FUNCTION_NAME}"

aws apigateway create-deployment \
    --rest-api-id $AWS_API_GATEWAY_REST_API_ID \
    --stage-name 'prod'

# Check API Gateway endpoint
curl https://${AWS_API_GATEWAY_RESOURCE_ID}.execute-api.ap-northeast-1.amazonaws.com/prod/${LAMBDA_FUNCTION_NAME}
