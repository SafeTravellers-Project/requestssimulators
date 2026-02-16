#!/usr/bin/env bash
#
# ***********************************************
# ***        Functional Test Script           ***
# ***********************************************

HOST_URL="$1"

echo ">>> HOST_URL: ${HOST_URL}"


###############################################
# Test #1: /api/v1/health (GET)
###############################################
echo ">>> Test 1: Health API"

responseCode=$(curl -s -o /dev/null -w "%{http_code}" "${HOST_URL}/api/v1/health" -c cookiejar.txt -b cookiejar.txt)

if [[ "${responseCode}" != "200" ]]; then
    echo "curlCommand: curl -s -o /dev/null -I -w \"%{http_code}\" ${HOST_URL}/api/v1/health -c cookiejar.txt -b cookiejar.txt"
    echo "Response code: ${responseCode}"
    echo "*** Health API is NOT running"
    exit 1
fi

echo ">>> Health API OK"


###############################################
# Test #2: /api/v1/version (GET)
###############################################
echo ">>> Test 2: Version API"

responseCode=$(curl -s -o /dev/null -w "%{http_code}" "${HOST_URL}/api/v1/version" -c cookiejar.txt -b cookiejar.txt)

if [[ "${responseCode}" != "200" ]]; then
    echo "curlCommand: curl -s -o /dev/null -I -w \"%{http_code}\" ${HOST_URL}/api/v1/version -c cookiejar.txt -b cookiejar.txt"
    echo "Response code: ${responseCode}"
    echo "*** Version API was NOT found"
    exit 1
fi

echo ">>> Version API OK"


###############################################
# Test #3: documentCheck (POST)
###############################################
echo ">>> Test 3: documentCheck API"

INPUT_DATA='{
  "transactionId" : "transactionid",
  "docType"       : "doctype",
  "issuingCountry": "issuingcountry",
  "lastName"      : "lastname",
  "firstNames"    : "firstnames",
  "docNumber"     : "docnumber",
  "nationality"   : "nationality",
  "birthDate"     : "1990-01-01",
  "gender"        : "M",
  "expirationDate": "2030-01-01",
  "personalNumber": ""
}'

RESPONSE_OK='{"status":"OK"}'

received=$(curl -s -X POST \
   -H "Content-Type: application/json" \
   -d "${INPUT_DATA}" \
   "${HOST_URL}/api/v1/documentCheck" -c cookiejar.txt -b cookiejar.txt)

if [[ "${received}" != "${RESPONSE_OK}" ]]; then
    echo ">>> curl: curl -X POST -H \"Content-Type:application/json\" -d \"${INPUT_DATA}\" ${HOST_URL}/api/v1/documentCheck -c cookiejar.txt -b cookiejar.txt"
    echo "Received: ${received}"
    echo "*** documentCheck API did NOT return OK"
    exit 1
fi

echo ">>> documentCheck returned OK"


###############################################
# Test #4: nextResultKO (GET)
###############################################
echo ">>> Test 4: nextResultKO API"

responseCode=$(curl -s -o /dev/null -w "%{http_code}" "${HOST_URL}/api/v1/nextResultKO" -c cookiejar.txt -b cookiejar.txt)

if [[ "${responseCode}" != "200" ]]; then
    echo "curlCommand: curl -s -o /dev/null -I -w \"%{http_code}\" ${HOST_URL}/api/v1/nextResultKO -c cookiejar.txt -b cookiejar.txt"
    echo "Response code: ${responseCode}"
    echo "*** nextResultKO API not found"
    exit 1
fi

echo ">>> nextResultKO API OK"


###############################################
# Test #5: documentCheck after KO
###############################################
echo ">>> Test 5: documentCheck after KO"

RESPONSE_KO='{"status":"KO"}'

received=$(curl -s -X POST \
   -H "Content-Type: application/json" \
   -d "${INPUT_DATA}" \
   "${HOST_URL}/api/v1/documentCheck" -c cookiejar.txt -b cookiejar.txt)

if [[ "${received}" != "${RESPONSE_KO}" ]]; then
    echo "Received: ${received}"
    echo "*** documentCheck API did NOT return KO after nextResultKO"
    exit 1
fi

echo ">>> documentCheck returned KO as expected"


echo "***********************************************"
echo "***   All Functional Tests PASSED SUCCESS   ***"
echo "***********************************************"

exit 0