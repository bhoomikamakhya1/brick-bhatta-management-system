#!/usr/bin/env python3
"""
Add a new Kaccha Muneem or Pakka Muneem user
Usage: python add_muneem.py <phone> <name> <role>
Example: python add_muneem.py "+911234567890" "Ram Kumar" "Kaccha Muneem"
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import uuid
import sys

sys.path.insert(0, '/code')
from app.models import User
from app.database import SQLALCHEMY_DATABASE_URL

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def add_muneem(phone, name, role_type):
    """Add a new Muneem user"""
    db = SessionLocal()
    try:
        # Validate role
        if role_type not in ["Kaccha Muneem", "Pakka Muneem"]:
            print(f"❌ Invalid role: {role_type}")
            print("   Must be 'Kaccha Muneem' or 'Pakka Muneem'")
            return
        
        # Check if exists
        existing = db.query(User).filter(User.phone_number == phone).first()
        if existing:
            print(f"⚠️  User already exists:")
            print(f"   Name: {existing.name}")
            print(f"   Role: {existing.role}")
            print(f"   Phone: {existing.phone_number}")
            return
        
        # Create user
        user_id = str(uuid.uuid4())
        role_hindi = "कच्चा मुनीम" if role_type == "Kaccha Muneem" else "पक्का मुनीम"
        
        user = User(
            id=user_id,
            name=name,
            name_hindi=name,  # Can be updated with Hindi translation
            role=role_type,
            role_hindi=role_hindi,
            initials=name[0:2].upper() if len(name) >= 2 else name[0].upper(),
            phone_number=phone,
            is_active=True
        )
        
        db.add(user)
        db.commit()
        db.refresh(user)
        
        print(f"✅ Successfully created {role_type}:")
        print(f"   ID: {user.id}")
        print(f"   Name: {user.name}")
        print(f"   Phone: {user.phone_number}")
        print(f"   Role: {user.role}")
        print()
        print("   They can now login with this phone number!")
        
    except Exception as e:
        print(f"❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python add_muneem.py <phone> <name> <role>")
        print()
        print("Arguments:")
        print("  phone  : Phone number with country code (e.g., +911234567890)")
        print("  name   : Full name of the user")
        print("  role   : 'Kaccha Muneem' or 'Pakka Muneem'")
        print()
        print("Example:")
        print('  python add_muneem.py "+911234567890" "Ram Kumar" "Kaccha Muneem"')
        sys.exit(1)
    
    phone = sys.argv[1]
    name = sys.argv[2]
    role = sys.argv[3]
    
    add_muneem(phone, name, role)
