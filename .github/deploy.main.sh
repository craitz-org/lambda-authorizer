#!/bin/bash

set -e

# lambda name
function_name="lambda-authorizer"

# serverless deploy
result=$(sls deploy)
echo "${result}"

# find newest published version
latest_version=$(aws lambda list-versions-by-function --function-name ${function_name} | grep "FunctionArn" | tail -1 | cut -d':' -f 9 | cut -d'"' -f 1)
echo "Latest version: ${latest_version}"

# update alias to published version
result=$(aws lambda update-alias --function-name ${function_name} --name prod --function-version ${latest_version})
echo "${result}"
