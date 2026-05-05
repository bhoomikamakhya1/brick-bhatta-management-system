#!/usr/bin/env python3
"""
Create admin user directly in PostgreSQL database
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

def create_admin():
    db = SessionLocal()
    try:
        # Check if user already exists by phone number
        existing = db.query(User).filter(User.phone_number == "+919999999999").first()
        if existing:
            print("User already exists:")
            print(f"   ID: {existing.id}")
            print(f"   Name: {existing.name}")
            print(f"   Role: {existing.role}")
            print(f"   Phone: {existing.phone_number}")
            return
        
        # Create new admin user with all required fields
        user_id = str(uuid.uuid4())
        user = User(
            id=user_id,
            name="Admin User",
            name_hindi="एडमिन उपयोगकर्ता",
            role="Admin",
            role_hindi="व्यवस्थापक",
            initials="AU",
            phone_number="+919999999999",
            is_active=True
        )
        
        db.add(user)
        db.commit()
        db.refresh(user)
        
        print("SUCCESS! Admin user created:")
        print(f"   ID: {user.id}")
        print(f"   Name: {user.name}")
        print(f"   Role: {user.role}")
        print(f"   Phone: {user.phone_number}")
        print()
        print("You can now login with phone number: +919999999999")
        
    except Exception as e:
        print(f"ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_admin()
