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
* version (/api/v1/health)
* documentCheck (/api/v1/health)
* nextResultKO (/api/v1/health)

you can see in jenkins/tests/func_test.sh how to make the calls
Service and session IDs are managed automatically on the server side.
This is transparent to the client except for the presence of a cookie for the session id. 

### 2.1 health call
health call is to check if the server is running.

### 2.2 version call
version call is to check the version.

### 2.3 documentCheck call
documentCheck is to "check" a document.
The input data are described in SourceCode/schemas/inputdata.py.
It always return {"status": "OK"} until you call nextResultKO then it will return {"status": "KO"} one time.

### 2.4 nextResultKO call
nextResultKO is to make documentCheck return {"status": "KO"} one time.
Each time you need documentCheck to return {"status": "KO"} you have to call nextResultKO before.
