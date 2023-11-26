#!/bin/bash

# Download fasttext models from https://fasttext.cc/docs/en/crawl-vectors.html#models
download_and_gunzip() {
    local url="$1"
    local output_dir="${2:-./data/wv_models/fasttext}"
    local output_file="${url##*/}"

    curl -o "$output_file" "$url"
    gunzip "$output_file"
    mv "${output_file%.gz}" "$output_dir"
}

mkdir -p ./data/fasttext_models
download_and_gunzip "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.en.300.bin.gz"
# download_and_unzip "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.ja.300.bin.gz" 

# Download tokenizer
mkdir -p ./data/tokenizer
curl -L https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/tokenizers/punkt.zip -o puckt.zip
unzip puckt.zip -d ./data/tokenizers
rm puckt.zip

# Create API Gateway
aws apigateway create-rest-api --name 'text-analytics-api' --region $AWS_DEFAULT_REGION
