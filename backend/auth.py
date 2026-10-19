"""Small, dependency-free authentication helpers for the admin area."""

import base64
import hashlib
import hmac
import json
import os
import secrets
import time

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from database import SessionLocal
from models import AdminUser


TOKEN_TTL_SECONDS = 60 * 60 * 8
PASSWORD_ITERATIONS = 310_000
bearer_scheme = HTTPBearer(auto_error=False)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def _token_secret() -> bytes:
    secret = os.environ.get("HOTPOT_TOKEN_SECRET")
    if not secret:
        raise RuntimeError("HOTPOT_TOKEN_SECRET must be set before starting the backend.")
    return secret.encode("utf-8")


def hash_password(password: str) -> str:
    salt = secrets.token_bytes(16)
    digest = hashlib.pbkdf2_hmac(
        "sha256", password.encode("utf-8"), salt, PASSWORD_ITERATIONS
    )
    return "pbkdf2_sha256${}${}${}".format(
        PASSWORD_ITERATIONS,
        base64.urlsafe_b64encode(salt).decode("ascii"),
        base64.urlsafe_b64encode(digest).decode("ascii"),
    )


def verify_password(password: str, stored_hash: str) -> bool:
    try:
        algorithm, iterations, encoded_salt, encoded_digest = stored_hash.split("$")
        if algorithm != "pbkdf2_sha256":
            return False
        candidate = hashlib.pbkdf2_hmac(
            "sha256",
            password.encode("utf-8"),
            base64.urlsafe_b64decode(encoded_salt.encode("ascii")),
            int(iterations),
        )
        return hmac.compare_digest(
            candidate,
            base64.urlsafe_b64decode(encoded_digest.encode("ascii")),
        )
    except (ValueError, TypeError):
        return False


def _encode_part(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")


def _decode_part(value: str) -> bytes:
    return base64.urlsafe_b64decode(value + "=" * (-len(value) % 4))


def create_access_token(username: str) -> str:
    payload = {
        "sub": username,
        "role": "admin",
        "exp": int(time.time()) + TOKEN_TTL_SECONDS,
    }
    encoded_payload = _encode_part(
        json.dumps(payload, separators=(",", ":")).encode("utf-8")
    )
    signature = hmac.new(
        _token_secret(), encoded_payload.encode("ascii"), hashlib.sha256
    ).digest()
    return f"{encoded_payload}.{_encode_part(signature)}"


def require_admin(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: Session = Depends(get_db),
) -> AdminUser:
    unauthorized = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Authentication required",
        headers={"WWW-Authenticate": "Bearer"},
    )
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise unauthorized
    try:
        encoded_payload, encoded_signature = credentials.credentials.split(".")
        expected_signature = hmac.new(
            _token_secret(), encoded_payload.encode("ascii"), hashlib.sha256
        ).digest()
        if not hmac.compare_digest(expected_signature, _decode_part(encoded_signature)):
            raise unauthorized
        payload = json.loads(_decode_part(encoded_payload))
        if payload.get("role") != "admin" or payload.get("exp", 0) < time.time():
            raise unauthorized
        username = payload.get("sub")
        if not isinstance(username, str):
            raise unauthorized
    except (ValueError, UnicodeDecodeError, json.JSONDecodeError):
        raise unauthorized

    admin = db.query(AdminUser).filter(AdminUser.username == username).first()
    if admin is None:
        raise unauthorized
    return admin


def create_initial_admin() -> None:
    """Create the first admin once; secrets come only from the environment."""
    _token_secret()

    db = SessionLocal()
    try:
        if db.query(AdminUser).first() is not None:
            return

        username = os.environ.get("HOTPOT_ADMIN_USERNAME")
        password = os.environ.get("HOTPOT_ADMIN_PASSWORD")
        if not username or not password:
            raise RuntimeError(
                "Set HOTPOT_ADMIN_USERNAME and HOTPOT_ADMIN_PASSWORD before the first startup."
            )

        db.add(AdminUser(username=username, password_hash=hash_password(password)))
        db.commit()
    finally:
        db.close()
