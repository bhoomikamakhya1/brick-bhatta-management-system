from sqlalchemy.orm import Session
from . import models, schemas
import uuid
from typing import List, Optional
from datetime import datetime, timedelta
import secrets
import hashlib

# --- Name CRUD ---
def get_name(db: Session, server_id: str):
    return db.query(models.Name).filter(models.Name.server_id == server_id).first()

def get_names(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Name).offset(skip).limit(limit).all()

def create_name(db: Session, name: schemas.NameCreate):
    # Map display_name to name if needed
    name_value = name.name if name.name else (name.display_name if name.display_name else "")
    
    # Ensure name_value is not empty
    if not name_value or not name_value.strip():
        raise ValueError("Name or display_name must be provided and cannot be empty")
    
    # Generate server_id if not provided
    server_id = str(uuid.uuid4())
    
    db_name = models.Name(
        server_id=server_id,
        name=name_value.strip(),
        value=name.value,
        group=name.group,
        phone=name.phone,
        gstin=name.gstin,
        commission_percent=name.commission_percent
    )
    db.add(db_name)
    try:
        db.commit()
        db.refresh(db_name)
    except Exception as e:
        db.rollback()
        # Log the error for debugging
        import traceback
        print(f"Error creating name: {str(e)}")
        print(traceback.format_exc())
        raise e
    return db_name


# Work
def get_work(db: Session, work_id: str):
    return db.query(models.Work).filter(models.Work.id == work_id).first()

def get_works(db: Session, skip: int = 0, limit: int = 1000): # Increased limit for sync
    return db.query(models.Work).order_by(models.Work.date.desc()).offset(skip).limit(limit).all()

def create_work(db: Session, work: schemas.WorkCreate, user_id: str):
    # Use provided ID or generate DB logic one (though UUID is preferred for sync)
    # Since existing logic uses string IDs from Flutter, use that if provided
    
    # Check if user exists in database (user_id might be Firebase UID)
    # If user doesn't exist with that ID, set created_by to None (foreign key allows null)
    db_user = get_user(db, user_id)
    created_by_id = db_user.id if db_user else None
    
    db_work = models.Work(
        id=work.id if work.id else str(uuid.uuid4()), # Fallback if no ID
        labour_name=work.labour_name,
        labour_category=work.labour_category,
        quantity=work.quantity,
        percentage=work.percentage,
        rate=work.rate,
        total_amount=work.total_amount,
        date=work.date,
        created_by=created_by_id  # Use backend user ID or None if user doesn't exist
    )
    db.add(db_work)
    try:
        db.commit()
        db.refresh(db_work)
    except Exception as e:
        db.rollback()
        raise e
    return db_work

# Transactions
def get_transaction(db: Session, transaction_id: str):
    return db.query(models.Transaction).filter(models.Transaction.id == transaction_id).first()

def get_transactions(db: Session, skip: int = 0, limit: int = 1000):
    return db.query(models.Transaction).order_by(models.Transaction.date.desc()).offset(skip).limit(limit).all()

def create_transaction(db: Session, transaction: schemas.TransactionCreate, user_id: str):
    # Check if user exists in database (user_id might be Firebase UID)
    # If user doesn't exist with that ID, set created_by to None (foreign key allows null)
    db_user = get_user(db, user_id)
    created_by_id = db_user.id if db_user else None
    
    db_txn = models.Transaction(
        id=transaction.id if transaction.id else str(uuid.uuid4()),
        party_name=transaction.party_name,
        party_id=transaction.party_id,
        amount=transaction.amount,
        type=transaction.type,
        category=transaction.category,
        date=transaction.date,
        description=transaction.description,
        created_by=created_by_id  # Use backend user ID or None if user doesn't exist
    )
    db.add(db_txn)
    try:
        db.commit()
        db.refresh(db_txn)
    except Exception as e:
        db.rollback()
        raise e
    return db_txn


def update_name(db: Session, server_id: str, name: schemas.NameCreate):
    db_name = get_name(db, server_id)
    if db_name:
        # Map display_name to name if needed
        name_value = name.name if name.name else (name.display_name if name.display_name else db_name.name)
        db_name.name = name_value
        db_name.value = name.value
        db_name.group = name.group
        db_name.phone = name.phone
        db_name.gstin = name.gstin
        db_name.commission_percent = name.commission_percent
        db.commit()
        db.refresh(db_name)
    return db_name

def delete_name(db: Session, server_id: str):
    db_name = get_name(db, server_id)
    if db_name:
        db.delete(db_name)
        db.commit()
        return True
    return False

# --- User CRUD ---
def get_user(db: Session, user_id: str):
    return db.query(models.User).filter(models.User.id == user_id).first()

def get_user_by_phone(db: Session, phone_number: str):
    """
    Get user by phone number, tolerant to formatting differences.
    """
    import logging
    logger = logging.getLogger(__name__)

    # Normalize input
    normalized = (
        phone_number
        .replace(" ", "")
        .replace("-", "")
        .replace("(", "")
        .replace(")", "")
    )

    # Generate possible variants
    candidates = {
        normalized,
        normalized.lstrip("+"),
        f"+{normalized.lstrip('+')}",
    }

    logger.error(f"[DEBUG] get_user_by_phone input: '{phone_number}'")
    logger.error(f"[DEBUG] normalized candidates: {candidates}")

    user = db.query(models.User).filter(
        models.User.phone_number.in_(candidates)
    ).first()

    if not user:
        all_users = db.query(models.User).all()
        logger.error(f"[DEBUG] No match. Users in DB:")
        for u in all_users:
            logger.error(f"  id={u.id}, phone='{u.phone_number}'")

    return user


def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()

def create_user(db: Session, user: schemas.UserCreate):
    db_user = models.User(**user.model_dump())
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def update_user(db: Session, user_id: str, user: schemas.UserCreate):
    db_user = get_user(db, user_id)
    if db_user:
        user_data = user.model_dump(exclude_unset=True)
        for key, value in user_data.items():
            if key != 'id': # Prevent ID change
                 setattr(db_user, key, value)
        db.commit()
        db.refresh(db_user)
    return db_user

# --- OTP CRUD ---
def generate_otp() -> str:
    """Generate a 6-digit OTP"""
    return f"{secrets.randbelow(900000) + 100000:06d}"

def create_otp(db: Session, phone_number: str, expiry_minutes: int = 5) -> models.OTP:
    """Create a new OTP for a phone number"""
    # Normalize phone number
    normalized_phone = phone_number.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    
    # Invalidate any existing unverified OTPs for this phone
    existing_otps = db.query(models.OTP).filter(
        models.OTP.phone_number == normalized_phone,
        models.OTP.verified == False
    ).all()
    for otp in existing_otps:
        db.delete(otp)
    
    # Create new OTP
    otp_code = generate_otp()
    expires_at = datetime.utcnow() + timedelta(minutes=expiry_minutes)
    
    db_otp = models.OTP(
        phone_number=normalized_phone,
        otp_code=otp_code,
        created_at=datetime.utcnow(),
        expires_at=expires_at,
        verified=False,
        attempts=0
    )
    db.add(db_otp)
    try:
        db.commit()
        db.refresh(db_otp)
    except Exception as e:
        db.rollback()
        raise e
    return db_otp

def get_latest_otp(db: Session, phone_number: str) -> Optional[models.OTP]:
    """Get the latest unverified OTP for a phone number"""
    normalized_phone = phone_number.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    return db.query(models.OTP).filter(
        models.OTP.phone_number == normalized_phone,
        models.OTP.verified == False
    ).order_by(models.OTP.created_at.desc()).first()

def verify_otp(db: Session, phone_number: str, otp_code: str) -> Optional[models.OTP]:
    """Verify OTP code"""
    normalized_phone = phone_number.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    
    otp = get_latest_otp(db, normalized_phone)
    if not otp:
        return None
    
    # Check if expired
    if datetime.utcnow() > otp.expires_at:
        return None
    
    # Check if already verified
    if otp.verified:
        return None
    
    # Check if max attempts exceeded (5 attempts)
    if otp.attempts >= 5:
        return None
    
    # Increment attempts
    otp.attempts += 1
    
    # Verify OTP
    if otp.otp_code == otp_code:
        otp.verified = True
        db.commit()
        db.refresh(otp)
        return otp
    else:
        db.commit()
        return None

def get_recent_otp_count(db: Session, phone_number: str, minutes: int = 10) -> int:
    """Count OTPs sent to a phone number in the last N minutes (for rate limiting)"""
    normalized_phone = phone_number.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
    cutoff_time = datetime.utcnow() - timedelta(minutes=minutes)
    return db.query(models.OTP).filter(
        models.OTP.phone_number == normalized_phone,
        models.OTP.created_at >= cutoff_time
    ).count()

def cleanup_expired_otps(db: Session):
    """Clean up expired OTPs (can be called periodically)"""
    expired_otps = db.query(models.OTP).filter(
        models.OTP.expires_at < datetime.utcnow()
    ).all()
    for otp in expired_otps:
        db.delete(otp)
    db.commit()

# --- Sale CRUD ---
def get_sale(db: Session, sale_id: str):
    return db.query(models.Sale).filter(models.Sale.id == sale_id).first()

def get_sales(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Sale).offset(skip).limit(limit).all()

def create_sale(db: Session, sale: schemas.SaleCreate):
    # Generate ID if not provided
    sale_id = sale.id if sale.id else str(uuid.uuid4())
    
    # 1. Create Sale
    db_sale = models.Sale(
        id=sale_id,
        customer_name=sale.customer_name,
        customer_name_hindi=sale.customer_name_hindi,
        customer_address=sale.customer_address,
        customer_phone=sale.customer_phone,
        date=sale.date,
        time=sale.time,
        advance_payment=sale.advance_payment,
        total_amount=sale.total_amount,
        final_amount=sale.final_amount,
        remarks=sale.remarks,
        otp=sale.otp,
        created_by=sale.created_by
    )
    db.add(db_sale)
    db.flush() # Flush to get the ID ready for relations

    # 2. Create Brick Entries
    for entry in sale.brick_entries:
        entry_id = entry.id if entry.id else str(uuid.uuid4())
        db_entry = models.BrickEntry(
            id=entry_id,
            sale_id=sale_id,
            brick_type=entry.brick_type,
            quantity=entry.quantity,
            price=entry.price
        )
        db.add(db_entry)

    # 3. Create Freight Details (if any)
    if sale.freight_details:
        db_freight = models.FreightDetails(
            sale_id=sale_id,
            type=sale.freight_details.type,
            vehicle_number=sale.freight_details.vehicle_number,
            vehicle_name=sale.freight_details.vehicle_name,
            driver_name=sale.freight_details.driver_name,
            driver_phone=sale.freight_details.driver_phone,
            rate_per_1000=sale.freight_details.rate_per_1000
        )
        db.add(db_freight)

    db.commit()
    db.refresh(db_sale)
    return db_sale
