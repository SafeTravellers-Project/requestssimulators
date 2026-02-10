from fastapi import FastAPI
from api.v1.health import router as health
from api.v1.version import router as version
from api.v1.api import documentCheck_router
from api.v1.api import nextResultKO_router

def create_app():
    app = FastAPI()
    app.include_router(health, prefix="/api/v1")
    app.include_router(version, prefix="/api/v1")
    app.include_router(documentCheck_router, prefix="/api/v1")
    app.include_router(nextResultKO_router, prefix="/api/v1")

    return app

app = create_app()
