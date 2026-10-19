import os
import requests
import json
import time
import base64
import hmac
import hashlib

def _encode_part(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")

# The exact secret from the running uvicorn process
secret = b"QU2UbtnQFprwuK/NsN08b5UdnB8POC9g/0wlSLBbu+mW3uy9x6rKNmh9tPqkZwLj"
payload = {
    "sub": "jeeva1003",
    "role": "admin",
    "exp": int(time.time()) + 86400,
}
encoded_payload = _encode_part(
    json.dumps(payload, separators=(",", ":")).encode("utf-8")
)
signature = hmac.new(secret, encoded_payload.encode("ascii"), hashlib.sha256).digest()
token = f"{encoded_payload}.{_encode_part(signature)}"

headers = {"Authorization": f"Bearer {token}"}
r = requests.get("http://127.0.0.1:8000/admin/foods", headers=headers)
print("Status:", r.status_code)
print("Response items count:", len(r.json()) if r.status_code == 200 else r.text)
