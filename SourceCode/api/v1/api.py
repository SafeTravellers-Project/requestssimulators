from fastapi import APIRouter
from requestssimulators.schemas.inputdata import InputData

documentCheck_router = APIRouter()
nextResultKO_router = APIRouter()

nextResultKO = False

@documentCheck_router.post("/documentCheck")
def documentCheck(data: InputData):
    global nextResultKO
    if nextResultKO == False:
        return {"status": "OK"}
    else:
        nextResultKO = False
        return {"status": "KO"}

@nextResultKO_router.get("/nextResultKO")
def nextToggleResult():
    global nextResultKO
    nextResultKO = True
    return {"status": "OK"}


