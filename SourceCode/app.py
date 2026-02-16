from fastapi import FastAPI
from contextlib import asynccontextmanager
from api.v1.health import router as health
from api.v1.version import router as version
from api.v1.api import documentCheck_router
from api.v1.api import nextResultKO_router
from redis.asyncio import Redis
import os

def create_app():
    @asynccontextmanager
    async def lifespan(app: FastAPI):
        # Create a single async Redis client for the app lifetime
        app.state.redis = Redis.from_url(
            os.getenv("REDIS_URL", "redis://redis:6379/0"),
            decode_responses=True,
        )
        try:
            yield
        finally:
            # Gracefully close the connection pool
            await app.state.redis.aclose()

    # Attach lifespan here
    app = FastAPI(lifespan=lifespan)

    app.include_router(health, prefix="/api/v1")
    app.include_router(version, prefix="/api/v1")
    app.include_router(documentCheck_router, prefix="/api/v1")
    app.include_router(nextResultKO_router, prefix="/api/v1")

    return app

app = create_app()

