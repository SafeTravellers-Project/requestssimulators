import pytest
from app import create_app
from fastapi.testclient import TestClient

@pytest.fixture()
def app():
    app = create_app()
    app.state.TESTING = True
    yield app

@pytest.fixture()
def client(app):
    with TestClient(app) as c:
        yield c

