#!/usr/bin/env python3
"""
Create test users for RBAC testing
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import uuid

# Import models
import sys
sys.path.insert(0, '/code')
from app.models import User, Base
from app.database import SQLALCHEMY_DATABASE_URL

# Create engine
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def create_test_users():
    db = SessionLocal()
    try:
        # Create Kaccha Muneem
        kaccha_phone = "+911234567890"
        existing = db.query(User).filter(User.phone_number == kaccha_phone).first()
        if not existing:
            user_id = str(uuid.uuid4())
            kaccha_user = User(
                id=user_id,
                name="Kaccha Muneem Test",
                name_hindi="कच्चा मुनीम टेस्ट",
                role="Kaccha Muneem",
                role_hindi="कच्चा मुनीम",
                initials="KM",
                phone_number=kaccha_phone,
                is_active=True
            )
            db.add(kaccha_user)
            print(f"✅ Created Kaccha Muneem: {kaccha_phone}")
        else:
            print(f"ℹ️  Kaccha Muneem already exists: {kaccha_phone}")
        
        # Create Pakka Muneem
        pakka_phone = "+910987654321"
        existing = db.query(User).filter(User.phone_number == pakka_phone).first()
        if not existing:
            user_id = str(uuid.uuid4())
            pakka_user = User(
                id=user_id,
                name="Pakka Muneem Test",
                name_hindi="पक्का मुनीम टेस्ट",
                role="Pakka Muneem",
                role_hindi="पक्का मुनीम",
                initials="PM",
                phone_number=pakka_phone,
                is_active=True
            )
            db.add(pakka_user)
            print(f"✅ Created Pakka Muneem: {pakka_phone}")
        else:
            print(f"ℹ️  Pakka Muneem already exists: {pakka_phone}")
        
        db.commit()
        
        # List all users
        print("\n📋 All users in database:")
        all_users = db.query(User).all()
        for u in all_users:
            print(f"   - {u.name} ({u.role}) - {u.phone_number}")
        
    except Exception as e:
        print(f"❌ ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_test_users()
