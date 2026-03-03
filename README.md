# requests simulators for Interpol SLTD, SISII, EES

Python-based application that creates servers simumaltors for requests to Interpol SLTD, SISII, EES servers.
Each servers is multi-users and can be called seperately from the others.
Each server has the same capabilities.

## 1. Docker-based deployment with source code

Deployment on a Docker-based system. The repository includes:

* The **source code** of the application
* The **Dockerfile** for building the application
* The **docker-compose.yaml** file for the deployment
* The **Jenkinsfiles**
* **Unit tests**
* **Functional tests**

## 2. Description of a server
4 calls can be make to these servers:
* health (/api/v1/health)
* version (/api/v1/version)
* documentCheck (/api/v1/documentCheck)
* nextResultKO (/api/v1/nextResultKO)

you can see in jenkins/tests/func_test.sh how to make the calls
Server IDs are managed automatically on the server side.
"**session id**" are genrated and send to the user in the response hearder of a request ("documentCheck" or "nextResultKO")

### 2.1 health call
health call is to check if the server is running.

### 2.2 version call
version call is to check the version.

### 2.3 documentCheck call
documentCheck is to "check" a document.
The input data are described in SourceCode/schemas/inputdata.py.
There is a test on the data structure as describe in inputdata.py.
No field is mandatory but the provided field must be strings.
It always return {"status": "OK"} until you call nextResultKO then it will return {"status": "KO"} one time.

### 2.4 nextResultKO call
nextResultKO is to make documentCheck return {"status": "KO"} one time.
Each time you need documentCheck to return {"status": "KO"} you have to call nextResultKO before.

## 3 session id
To avoid being bothered by other users, the use of a session ID is mandatory.
The first call to "documentCheck" or "nextResultKO" provides you with a session ID in the response header.
If using curl don't forget the option "-i" to be able to see the header of the response and not only its body.

## 4 example:

### 4.1 first "documentCheck" request

at first request, the user has no "session id", so the request is done without "session id" in the request header.

* curl -i -X POST https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-sis/api/v1/documentCheck -H "Content-Type: application/json" -d "{\"transactionId\" : \"transactionid\", \"docType\" : \"doctype\", \"issuingCountry\" : \"issuingcountry\", \"lastName\" : \"lastname\", \"firstNames\" : \"firstnames\", \"docNumber\" : \"docnumber\", \"nationality\" : \"nationality\", \"birthDate\" : \"1990-01-01\", \"gender\" : \"M\", \"expirationDate\" : \"2030-01-01\", \"personalNumber\": \"\"}"

response header:
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 15
Connection: keep-alive
date: Tue, 03 Mar 2026 13:50:15 GMT
server: uvicorn
<mark>x-session-id: 44f71bb1-c20b-45ab-8035-3a0965edb638</mark>
X-Kong-Upstream-Latency: 2
X-Kong-Proxy-Latency: 0
Via: 1.1 kong/3.8.0.0-enterprise-edition
X-Kong-Request-Id: 8403f735e1b30328f3dffc75951f8c1c

response body:
{"status":"OK"}

No "session id" was in the curl request, but the server generated one and that "session id" given to the user through the response header can be used in the following commands.

This generation of the "session id" by the server could be done by a "nextResultKO" request too.

### 4.2 
* curl -i -X POST https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-sis/api/v1/documentCheck -H "Content-Type: application/json" -d "{\"transactionId\" : \"transactionid\", \"docType\" : \"doctype\", \"issuingCountry\" : \"issuingcountry\", \"lastName\" : \"lastname\", \"firstNames\" : \"firstnames\", \"docNumber\" : \"docnumber\", \"nationality\" : \"nationality\", \"birthDate\" : \"1990-01-01\", \"gender\" : \"M\", \"expirationDate\" : \"2030-01-01\", \"personalNumber\": \"\"}" -H "X-Session-Id:59883558-e6c1-4c76-8b40-f1a40bf98abe"

HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 15
Connection: keep-alive
date: Tue, 03 Mar 2026 13:50:26 GMT
server: uvicorn
x-session-id: 59883558-e6c1-4c76-8b40-f1a40bf98abe
X-Kong-Upstream-Latency: 3
X-Kong-Proxy-Latency: 0
Via: 1.1 kong/3.8.0.0-enterprise-edition
X-Kong-Request-Id: fd2eae68e946d23cfe9ef22c6b888e77

{"status":"OK"}

This time we used the session id provided by the previous command.
Once you use a session id, there is virtually no chance that another person will use the same session ID and cause inconsistencies in your requests/responses.

Both "documentCheck" and "nextResultKO" will generate a new session id if no session id is provided in the request.

* curl -i -X GET https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-sis/api/v1/nextResultKO -H "X-Session-Id:59883558-e6c1-4c76-8b40-f1a40bf98abe"

HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 15
Connection: keep-alive
date: Tue, 03 Mar 2026 14:05:16 GMT
server: uvicorn
x-session-id: 59883558-e6c1-4c76-8b40-f1a40bf98abe
X-Kong-Upstream-Latency: 3
X-Kong-Proxy-Latency: 0
Via: 1.1 kong/3.8.0.0-enterprise-edition
X-Kong-Request-Id: c927480d0f3abc1ef1adb21decdcee11

{"status":"OK"}

As the session id is provided in the command, the session id in the response header is the same.
Even if someone send other requests to the same server, there will be no interference with your requests.

* curl -i -X POST https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-sis/api/v1/documentCheck -H "Content-Type: application/json" -d "{\"transactionId\" : \"transactionid\", \"docType\" : \"doctype\", \"issuingCountry\" : \"issuingcountry\", \"lastName\" : \"lastname\", \"firstNames\" : \"firstnames\", \"docNumber\" : \"docnumber\", \"nationality\" : \"nationality\", \"birthDate\" : \"1990-01-01\", \"gender\" : \"M\", \"expirationDate\" : \"2030-01-01\", \"personalNumber\": \"\"}" -H "X-Session-Id:59883558-e6c1-4c76-8b40-f1a40bf98abe"

HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 15
Connection: keep-alive
date: Tue, 03 Mar 2026 14:06:13 GMT
server: uvicorn
x-session-id: 59883558-e6c1-4c76-8b40-f1a40bf98abe
X-Kong-Upstream-Latency: 2
X-Kong-Proxy-Latency: 1
Via: 1.1 kong/3.8.0.0-enterprise-edition
X-Kong-Request-Id: 4309193bb48b06476f89936ad48f8968

{"status":"KO"}

* curl -i -X POST https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-sis/api/v1/documentCheck -H "Content-Type: application/json" -d "{\"transactionId\" : \"transactionid\", \"docType\" : \"doctype\", \"issuingCountry\" : \"issuingcountry\", \"lastName\" : \"lastname\", \"firstNames\" : \"firstnames\", \"docNumber\" : \"docnumber\", \"nationality\" : \"nationality\", \"birthDate\" : \"1990-01-01\", \"gender\" : \"M\", \"expirationDate\" : \"2030-01-01\", \"personalNumber\": \"\"}" -H "X-Session-Id:59883558-e6c1-4c76-8b40-f1a40bf98abe"

HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 15
Connection: keep-alive
date: Tue, 03 Mar 2026 14:07:20 GMT
server: uvicorn
x-session-id: 59883558-e6c1-4c76-8b40-f1a40bf98abe
X-Kong-Upstream-Latency: 2
X-Kong-Proxy-Latency: 1
Via: 1.1 kong/3.8.0.0-enterprise-edition
X-Kong-Request-Id: 8cfce9166a0f30655a0a425c6fc5f563

{"status":"OK"}


## 5. list of servers

### 5.1 Interpol-SLTD simulator server

https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-interpol

### 5.2 EES simulator server

https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-ees

### 5.3 SIS simulator server

https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-sis

### 5.4 No interference between the servers and the users

The internal use of service id and the use of session id prevent interference between servers and between users. 
