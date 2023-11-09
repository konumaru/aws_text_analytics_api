S3_BUCKET_NAME=20newsgroups-model

# aws s3 mb s3://$S3_BUCKET_NAME
aws s3 cp ./model/text_classification_model.joblib s3://$S3_BUCKET_NAME/model.joblib
