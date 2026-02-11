#!/bin/bash

# ****************************
# *** Run Functional tests ***
# ****************************

HOST_URL=$1
echo "HOST_URL: " $HOST_URL

# *** Test #1: Check the health API call
curlCommand = \"curl -s -o /dev/null -I -w \" + \"%{http_code}\" + \" \" + ${HOST_URL} + \"/api/v1/health\"
responseCode=$(curl -s -o /dev/null -I -w "%{http_code}"  ${HOST_URL}/api/v1/health)
if [[ ${responseCode} != 200 ]]; then
    echo "curlCommand: $curlCommand"
    echo "Response code: $responseCode"
    echo "*** health API is not running"
    exit 1
fi

# *** Test #2: Check the version API call
responseCode=$(curl -s -o /dev/null -I -w "%{http_code}"  ${HOST_URL}/api/v1/version)
if [[ ${responseCode} != 200 ]]; then
    curlCommand = "curl -s -o /dev/null -I -w " + "%{http_code}" + "  " + ${HOST_URL} + "/api/v1/version"
    echo "curlCommand: $curlCommand"
    echo "Response code: $responseCode"
    echo "*** version API was not found"
    exit 1
fi

# *** Test #3: Check the documentCheck POST API
#INPUT_DATA='{"project": "TERMINET", "wp": 7}'
INPUT_DATA='{"transactionId" : "transactionid", "docType" : "doctype", "issuingCountry" : "issuingcountry", "lastName" : "lastname", "firstNames" : "firstnames", "docNumber" : "docnumber", "nationality" : "nationality", "birthDate" : "1990-01-01", "gender" : "M", "expirationDate" : "2030-01-01", "personalNumber": ""}'
RESPONSE_OK='{"status": "OK"}'
RECIEVED_DATA=$(curl -XPOST -H "Content-type:Application/json" -d "${INPUT_DATA}"  ${HOST_URL}/api/v1/documentCheck)
if [[ ${RECIEVED_DATA} != ${RESPONSE_OK} ]]; then
    echo 'curl -XPOST -H "Content-type:Application/json" -d "${INPUT_DATA}"  ${HOST_URL}/api/v1/documentCheck'
    echo "RECIEVED_DATA: $RECIEVED_DATA"
    echo "*** documentCheck POST API is not working properly"
    exit 1
fi

# *** Test #4: Check the nextResultKO API call
responseCode=$(curl -s -o /dev/null -I -w "%{http_code}"  ${HOST_URL}/api/v1/nextResultKO)
if [[ ${responseCode} != 200 ]]; then
    echo 'curl -s -o /dev/null -I -w "%{http_code}"  ${HOST_URL}/api/v1/nextResultKO'
    echo "Response code: $responseCode"
    echo "*** nextResultKO API was not found"
    exit 1
fi

# *** Test #3: Check the documentCheck POST API
RESPONSE_KO='{"status": "KO"}'
RECIEVED_DATA=$(curl -XPOST -H "Content-type:Application/json" -d "${INPUT_DATA}"  ${HOST_URL}/api/v1/documentCheck)
if [[ ${RECIEVED_DATA} != ${RESPONSE_KO} ]]; then
    echo "*** documentCheck POST API is not working properly after a nextResultKO API call"
    exit 1
fi


echo "*** Functional tests were successful ***"
