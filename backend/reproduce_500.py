from fastapi.testclient import TestClient
from app.main import app
import json

client = TestClient(app)

payload = {
    "display_name": "Amit Singh",
    "group": "Worker",
    "phone": None,
    "gstin": None,
    "commission_percent": None
}

try:
    response = client.post("/names/", json=payload)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.json()}")
except Exception as e:
    print(f"Exception: {e}")
