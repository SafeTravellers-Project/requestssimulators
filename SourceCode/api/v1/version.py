from fastapi import APIRouter

router = APIRouter()

@router.get("/version")
def version():
    return {"service": "fastapi-prod", "version": "1.0.0"}

