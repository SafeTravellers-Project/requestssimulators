# requests simulators for Interpol SLTD, SIS II, EES

Python-based application that creates servers simumaltors for requests to Interpol SLTD, SIS II, EES servers.  
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
* **health** (/api/v1/health)
* **version** (/api/v1/version)
* **documentCheck** (/api/v1/documentCheck)
* **nextResultKO** (/api/v1/nextResultKO)

you can see in jenkins/tests/func_test.sh how to make the calls.  
Server IDs are managed automatically on the server side.  
**session id** are genrated and send to the user in the response hearder of a request (**documentCheck** or **nextResultKO**)

### 2.1 health request
The **health** request is to check if the server is running. (no **session id** involved)

### 2.2 version request
The **version** request is to check the version. (no **session id** involved)

### 2.3 documentCheck request
The **documentCheck** is to check a document.  
The input data are described in SourceCode/schemas/inputdata.py.  
There is a test on the data structure as describe in inputdata.py.  
No field is mandatory but the provided field must be strings.  
A **session id** is mandatory in the request header.  
It always return the same **session id** in the response header than the one in the request header.  
It always return **{"status": "OK"}** until the **nextResultKO** request has been send then it will return **{"status": "KO"}** one time.  

### 2.4 nextResultKO request
The **nextResultKO** request is to make the next **documentCheck** request return **{"status": "KO"}** one time. (no **session id** involved)  
Each time you need the next **documentCheck** request to return **{"status": "KO"}** you have to send the **nextResultKO** request before.  
It always return a **session id** in the response header, this **session id** is a new one if none was provided in the request header.  
A **nextResultKO** request made on a server will not impact another server (Interpol SLTD, EES, SIS II).  

## 3 session id
Unlike a standard server where the **session id** is there to avoid multi-users problems, here the session ID is managed by the client.  
The use of a **session id** is mandatory only for the **documentCheck** request.
the **session id** is provided by the client in the request header and the server response contains the **session id** in the response header.  
If using curl, don't forget the option "**-i**" to be able to see the response header and not only its body.  

## 4 example:

### 4.1 first "documentCheck" request

at first request, the user has no **session id**, so the request is done without **session id** in the request header.  

* curl -i -X POST https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-sis/api/v1/documentCheck -H "Content-Type: application/json" -d "{\"transactionId\" : \"transactionid\", \"docType\" : \"doctype\", \"issuingCountry\" : \"issuingcountry\", \"lastName\" : \"lastname\", \"firstNames\" : \"firstnames\", \"docNumber\" : \"docnumber\", \"nationality\" : \"nationality\", \"birthDate\" : \"1990-01-01\", \"gender\" : \"M\", \"expirationDate\" : \"2030-01-01\", \"personalNumber\": \"\"}" <mark>-H "X-Session-Id:44f71bb1-c20b-45ab-8035-3a0965edb638"</mark>  

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

The **session id** present in the curl request header, is also present in the response header.  

### 4.2 second "documentCheck" request

* curl -i -X POST https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-sis/api/v1/documentCheck -H "Content-Type: application/json" -d "{\"transactionId\" : \"transactionid\", \"docType\" : \"doctype\", \"issuingCountry\" : \"issuingcountry\", \"lastName\" : \"lastname\", \"firstNames\" : \"firstnames\", \"docNumber\" : \"docnumber\", \"nationality\" : \"nationality\", \"birthDate\" : \"1990-01-01\", \"gender\" : \"M\", \"expirationDate\" : \"2030-01-01\", \"personalNumber\": \"\"}" <mark>-H "X-Session-Id:59883558-e6c1-4c76-8b40-f1a40bf98abe"</mark>  

response header:  
HTTP/1.1 200 OK  
Content-Type: application/json  
Content-Length: 15  
Connection: keep-alive  
date: Tue, 03 Mar 2026 13:50:26 GMT  
server: uvicorn  
<mark>x-session-id: 59883558-e6c1-4c76-8b40-f1a40bf98abe</mark>  
X-Kong-Upstream-Latency: 3  
X-Kong-Proxy-Latency: 0  
Via: 1.1 kong/3.8.0.0-enterprise-edition  
X-Kong-Request-Id: fd2eae68e946d23cfe9ef22c6b888e77  

response body:  
{"status":"OK"}  

Same thing than previous command. The **session id** provided in the request header can be found in the response header.  

### 4.3 "nextResultKO" request

* curl -i -X GET https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-sis/api/v1/nextResultKO  

response header:  
HTTP/1.1 200 OK  
Content-Type: application/json  
Content-Length: 15  
Connection: keep-alive  
date: Tue, 03 Mar 2026 14:05:16 GMT  
server: uvicorn  
X-Kong-Upstream-Latency: 3  
X-Kong-Proxy-Latency: 0  
Via: 1.1 kong/3.8.0.0-enterprise-edition  
X-Kong-Request-Id: c927480d0f3abc1ef1adb21decdcee11  

response body:  
{"status":"OK"}  

This request is not related to any **session id**, so the next **documentCheck** request with any **session id** will return **{"status":"KO"}**.  

### 4.3 "documentCheck" request after a "nextResultKO" request

* curl -i -X POST https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-sis/api/v1/documentCheck -H "Content-Type: application/json" -d "{\"transactionId\" : \"transactionid\", \"docType\" : \"doctype\", \"issuingCountry\" : \"issuingcountry\", \"lastName\" : \"lastname\", \"firstNames\" : \"firstnames\", \"docNumber\" : \"docnumber\", \"nationality\" : \"nationality\", \"birthDate\" : \"1990-01-01\", \"gender\" : \"M\", \"expirationDate\" : \"2030-01-01\", \"personalNumber\": \"\"}" <mark>-H "X-Session-Id:cde5fb65-9d28-722b-0b7a-eb51d45aa350"</mark>  

response header:  
HTTP/1.1 200 OK  
Content-Type: application/json  
Content-Length: 15  
Connection: keep-alive  
date: Tue, 03 Mar 2026 14:06:13 GMT  
server: uvicorn  
<mark>x-session-id: cde5fb65-9d28-722b-0b7a-eb51d45aa350</mark>  
X-Kong-Upstream-Latency: 2  
X-Kong-Proxy-Latency: 1  
Via: 1.1 kong/3.8.0.0-enterprise-edition  
X-Kong-Request-Id: 4309193bb48b06476f89936ad48f8968  

response body:  
{"status":"KO"}  

**{"status":"KO"}** is the response when a **documentCheck** request is made after a **nextResultKO** request.  

### 4.3 "documentCheck" request after a "documentCheck" request

* curl -i -X POST https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-sis/api/v1/documentCheck -H "Content-Type: application/json" -d "{\"transactionId\" : \"transactionid\", \"docType\" : \"doctype\", \"issuingCountry\" : \"issuingcountry\", \"lastName\" : \"lastname\", \"firstNames\" : \"firstnames\", \"docNumber\" : \"docnumber\", \"nationality\" : \"nationality\", \"birthDate\" : \"1990-01-01\", \"gender\" : \"M\", \"expirationDate\" : \"2030-01-01\", \"personalNumber\": \"\"}" <mark>-H "X-Session-Id:63251947-d31b-dc55-2c1d-2a30bf185d4"</mark>  

response header:  
HTTP/1.1 200 OK  
Content-Type: application/json  
Content-Length: 15  
Connection: keep-alive  
date: Tue, 03 Mar 2026 14:07:20 GMT  
server: uvicorn  
<mark>x-session-id: 63251947-d31b-dc55-2c1d-2a30bf185d4</mark>  
X-Kong-Upstream-Latency: 2  
X-Kong-Proxy-Latency: 1  
Via: 1.1 kong/3.8.0.0-enterprise-edition  
X-Kong-Request-Id: 8cfce9166a0f30655a0a425c6fc5f563  

response body:  
{"status":"OK"}  


## 5. list of servers

### 5.1 Interpol SLTD simulator server

https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-interpol

### 5.2 EES simulator server

https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-ees

### 5.3 SIS II simulator server

https://platform.safetravellers.rid-intrasoft.eu/requestssimulators-sis

### 5.4 No interference between the servers

The internal use of service id prevent interference between servers.  
