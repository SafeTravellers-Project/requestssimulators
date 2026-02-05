def test_home(client):
    response = client.get("/api/v1/health")
    assert "ok" in response.json()

def test_dummy_url(client):
    response = client.get("/api/v1/version")
    assert "fastapi-prod" in response.json()