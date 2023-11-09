#!/bin/bash

ORIGIN_DIR_NAME=$(basename $(dirname $(dirname $(realpath $0))))
DIR_NAME="${ORIGIN_DIR_NAME//_/-}"

echo "Deploying $DIR_NAME"

export LAMBDA_FUNCTION_NAME=$DIR_NAME
export LAMBDA_EXECUTION_ROLE=$(aws iam get-role --role-name LambdaExecutionRole --query 'Role.Arn' --output text)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
export AWS_DEFAULT_REGION=$(echo $AWS_DEFAULT_REGION)

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

# Create API Gateway
aws apigateway create-rest-api --name 'text-analytics-api' --region $AWS_DEFAULT_REGION
# rest-api-id zwx7by9xre
# root-resource-id chvutaiixb

# NOTE: Lambda関数名とpath-partは同じにするとわかりやすい
aws apigateway create-resource --rest-api-id zwx7by9xre --parent-id chvutaiixb --path-part 'hello-world'
# resource-id 1mxmgh

aws apigateway put-method --rest-api-id zwx7by9xre --resource-id 1mxmgh --http-method ANY --authorization-type "NONE" 

aws apigateway put-integration \
    --rest-api-id zwx7by9xre \
    --resource-id 1mxmgh \
    --http-method ANY \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri 'arn:aws:apigateway:ap-northeast-1:lambda:path/2015-03-31/functions/arn:aws:lambda:ap-northeast-1:381519389246:function:hello-world/invocations'

aws lambda add-permission \
    --function-name $LAMBDA_FUNCTION_NAME \
    --statement-id 'apigateway-test-3' \
    --action 'lambda:InvokeFunction' \
    --principal apigateway.amazonaws.com \
    --source-arn 'arn:aws:execute-api:ap-northeast-1:381519389246:zwx7by9xre/*/*/hello-world'

aws apigateway create-deployment \
    --rest-api-id zwx7by9xre \
    --stage-name 'prod'
