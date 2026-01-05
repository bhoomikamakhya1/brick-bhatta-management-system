from typing import Generator
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from .database import SessionLocal
import firebase_admin
from firebase_admin import auth, credentials
import os
import json

# Database Dependency
def get_db() -> Generator:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Firebase Init (SAFE + SIMPLE) - Optional for development
BASE_DIR = os.path.dirname(os.path.dirname(__file__))
firebase_key_path = os.path.join(BASE_DIR, "firebase-key.json")

if not firebase_admin._apps:
    if os.path.exists(firebase_key_path):
        cred = credentials.Certificate(firebase_key_path)
        firebase_admin.initialize_app(cred)
        print("✅ Firebase initialized successfully")
    else:
        # Don't block startup - Firebase is only needed for token verification
        # OTP check endpoint doesn't need Firebase
        print("⚠️  Firebase key not found at backend/firebase-key.json")
        print("⚠️  Backend will start, but Firebase token verification will fail")
        print("⚠️  This is OK for development if you're using Firebase Phone Auth on the client")


security = HTTPBearer()

def get_current_user(creds: HTTPAuthorizationCredentials = Depends(security)):
    """
    Verifies the Firebase ID token in the Authorization header.
    Returns the decoded token dict (uid, email, etc) if valid.
    For development: If Firebase is not initialized, accepts any token.
    """
    token = creds.credentials
    
    # Check if Firebase is initialized
    if not firebase_admin._apps:
        # Firebase not initialized - allow in development
        print("⚠️  Firebase not initialized - accepting token for development")
        print(f"⚠️  Token received: {token[:20]}...")
        return {"uid": "dev_user", "phone_number": "dev_phone"}
    
    try:
        # In a real deployed env with valid creds:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        print(f"Auth Error: {e}")
        # For development, if Firebase is initialized but verification fails,
        # we still reject (this means there's a real auth issue)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
