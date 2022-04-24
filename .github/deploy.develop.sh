#!/bin/bash

# lambda name
alias_name="dev"
function_name="lambda-authorizer-${alias_name}"

# serverless deploy
result=$(sls deploy --stage ${alias_name})
echo "${result}"

# # find newest published version
# latest_version=$(aws lambda list-versions-by-function --function-name ${function_name} | grep "FunctionArn" | tail -1 | cut -d':' -f 9 | cut -d'"' -f 1)
# echo "Latest version: ${latest_version}"

# result_alias=$(aws lambda get-alias --function-name lambda-authorizer --name ${alias_name} | grep "Name" | cut -d':' -f 2 | cut -d'"' -f 2)
# if [[ ${result_alias} ]]; then
# 	echo "Updating alias..."
# 	# update alias to published version
# 	result=$(aws lambda update-alias --function-name ${function_name} --name ${alias_name} --function-version ${latest_version})
# 	echo "${result}"
# else
# 	echo "Creating alias..."
# 	# create alias to published version
# 	result=$(aws lambda create-alias --function-name ${function_name} --name ${alias_name} --function-version ${latest_version})
# 	echo "${result}"
# fi