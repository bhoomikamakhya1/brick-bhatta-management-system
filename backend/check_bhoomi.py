#!/usr/bin/env python3
"""
Check if Bhoomi Kaccha exists in AWS database
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import sys

sys.path.insert(0, '/code')
from app.models import User, Name
from app.database import SQLALCHEMY_DATABASE_URL

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def check_bhoomi():
    db = SessionLocal()
    try:
        print("🔍 Checking for Bhoomi in AWS database...\n")
        
        # Check users table
        print("📋 Users table:")
        users = db.query(User).all()
        for u in users:
            print(f"   - {u.name} ({u.role}) - {u.phone_number}")
            if 'bhoomi' in u.name.lower():
                print(f"     ✅ FOUND BHOOMI in users table!")
        
        print(f"\n📋 Names table (ledger):")
        names = db.query(Name).all()
        for n in names:
            print(f"   - {n.name} ({n.group}) - {n.phone}")
            if 'bhoomi' in n.name.lower():
                print(f"     ✅ FOUND BHOOMI in names table!")
        
        # Specific search for phone ending in 7891
        print(f"\n🔍 Searching for phone numbers ending in 7891:")
        users_with_phone = db.query(User).filter(User.phone_number.like('%7891')).all()
        names_with_phone = db.query(Name).filter(Name.phone.like('%7891')).all()
        
        if users_with_phone:
            for u in users_with_phone:
                print(f"   ✅ Found in users: {u.name} - {u.phone_number}")
        if names_with_phone:
            for n in names_with_phone:
                print(f"   ✅ Found in names: {n.name} - {n.phone}")
        
        if not users_with_phone and not names_with_phone:
            print(f"   ❌ No entries found with phone ending in 7891")
        
    except Exception as e:
        print(f"❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    check_bhoomi()
