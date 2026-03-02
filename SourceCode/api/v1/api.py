from fastapi import APIRouter, Response, Request
from schemas.inputdata import InputData
import redis
import os
from uuid import uuid4

documentCheck_router = APIRouter()
nextResultKO_router = APIRouter()

def get_or_create_session_id(request: Request, response: Response) -> str:
    # get session ID from header X-Session-Id.
    session_id = request.headers.get("X-Session-Id")

    if not session_id:
        session_id = str(uuid4())

    # put the session id in the response so client pour qu'il puisse le réutiliser
    response.headers["X-Session-Id"] = session_id

    return session_id

@documentCheck_router.post("/documentCheck")
async def documentCheck(data: InputData, request: Request, response: Response):
    # get service id
    service_id = os.getenv("SERVICE_ID")

    # get session id
    session_id = get_or_create_session_id(request, response)

    key = f"{service_id}:session:{session_id}:next_result"

    # Use the Redis client from app state (async)
    r = request.app.state.redis

    # Atomically get and delete the key
    res = await r.getdel(key)

    if res == "KO":    # ← FIXED
        return {"status": "KO"}

    return {"status": "OK"}

@nextResultKO_router.get("/nextResultKO")
async def nextToggleResult(request: Request, response: Response):
    # get service id
    service_id = os.getenv("SERVICE_ID")

    # get session id
    session_id = get_or_create_session_id(request, response)

    key = f"{service_id}:session:{session_id}:next_result"
    r = request.app.state.redis
    # Set flag for this session for 5 minutes
    await r.set(key, "KO", ex=300)

    return {"status": "OK"}


