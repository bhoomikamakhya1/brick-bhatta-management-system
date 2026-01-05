from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .. import crud, schemas, dependencies, models
from datetime import datetime
import os
import logging

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/otp",
    tags=["otp"],
    responses={404: {"description": "Not found"}},
)

# Rate limiting: Max 3 OTP requests per phone number per 10 minutes
MAX_OTP_REQUESTS_PER_WINDOW = 3
OTP_RATE_LIMIT_WINDOW_MINUTES = 10

@router.post("/check-phone", response_model=dict)
def check_phone_number(
    request: schemas.OTPRequest,
    db: Session = Depends(dependencies.get_db)
):
    """
    Check if a phone number exists in the database.
    Only registered users (created by admin) can log in.
    This is called before sending OTP via Firebase.
    """
    # Normalize phone number
    normalized_phone = request.phone_number.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    
    # Debug logging
    logger.error(f"[DEBUG] check_phone_number called with phone: {request.phone_number}")
    logger.error(f"[DEBUG] normalized_phone: '{normalized_phone}' (length: {len(normalized_phone)})")
    
    user = crud.get_user_by_phone(db, normalized_phone)
    
    if not user:
        # Debug: Check what users exist
        all_users = db.query(models.User).all()
        logger.error(f"[DEBUG] No user found. Total users in DB: {len(all_users)}")
        for u in all_users:
            logger.error(f"[DEBUG] User: id={u.id}, phone='{u.phone_number}' (length: {len(u.phone_number) if u.phone_number else 0})")
        
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Phone number not registered. Please contact admin to create your account."
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Your account is inactive. Please contact admin."
        )
    
    return {
        "exists": True,
        "message": "Phone number found",
        "user_id": user.id,
        "name": user.name,
        "role": user.role
    }

@router.post("/get-user-by-phone", response_model=schemas.User)
def get_user_by_phone(
    request: schemas.OTPRequest,
    db: Session = Depends(dependencies.get_db)
):
    """
    Get user details by phone number.
    Called after Firebase OTP verification to get user data from database.
    """
    # Normalize phone number
    normalized_phone = request.phone_number.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    
    user = crud.get_user_by_phone(db, normalized_phone)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Your account is inactive. Please contact admin."
        )
    
    return schemas.User.model_validate(user)

# Legacy endpoints (kept for backward compatibility, but Firebase handles OTP now)
@router.post("/send", response_model=schemas.OTPSendResponse)
def send_otp_legacy(
    request: schemas.OTPRequest,
    db: Session = Depends(dependencies.get_db)
):
    """
    Legacy endpoint - OTP is now sent via Firebase Phone Auth.
    This endpoint is kept for backward compatibility.
    """
    # Just check if phone exists
    normalized_phone = request.phone_number.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    user = crud.get_user_by_phone(db, normalized_phone)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Phone number not registered. Please contact admin to create your account."
        )
    
    return schemas.OTPSendResponse(
        success=True,
        message="Use Firebase Phone Auth for OTP. This endpoint is for compatibility only.",
        expires_in=60
    )

@router.post("/verify", response_model=schemas.OTPVerifyResponse)
def verify_otp_legacy(
    request: schemas.OTPVerifyRequest,
    db: Session = Depends(dependencies.get_db)
):
    """
    Legacy endpoint - OTP verification is now handled by Firebase.
    This endpoint is kept for backward compatibility.
    """
    # Get user by phone (Firebase already verified the OTP)
    normalized_phone = request.phone_number.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    user = crud.get_user_by_phone(db, normalized_phone)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return schemas.OTPVerifyResponse(
        success=True,
        message="Use Firebase Phone Auth for OTP verification. This endpoint is for compatibility only.",
        user=schemas.User.model_validate(user),
        token=None
    )
