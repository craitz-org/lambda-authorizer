#!/bin/bash

set -e

# lambda name
function_name="lambda-authorizer"

# serverless deploy
result=$(sls deploy --stage=prod)
echo "${result}"

# find newest published version
latest_version=$(aws lambda list-versions-by-function --function-name ${function_name} | grep "FunctionArn" | tail -1 | cut -d':' -f 9 | cut -d'"' -f 1)
echo "Latest version: ${latest_version}"

alias_name=$(aws lambda get-alias --function-name lambda-authorizer --name prod | grep "Name" | cut -d':' -f 2 | cut -d'"' -f 2)
if [[ ${alias_name} ]]; then
	echo "Updating alias..."
	# update alias to published version
	result=$(aws lambda update-alias --function-name ${function_name} --name prod --function-version ${latest_version})
	echo "${result}"
else
	echo "Creating alias..."
	# create alias to published version
	result=$(aws lambda create-alias --function-name ${function_name} --name prod --function-version ${latest_version})
	echo "${result}"
fi
