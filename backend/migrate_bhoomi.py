#!/usr/bin/env python3
"""
Check if Bhoomi Pakka exists and migrate to users table if needed
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import uuid
import sys

sys.path.insert(0, '/code')
from app.models import User, Name
from app.database import SQLALCHEMY_DATABASE_URL

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def check_and_migrate():
    db = SessionLocal()
    try:
        # Check names table for Bhoomi
        print("🔍 Searching for 'Bhoomi' in names table...")
        names = db.query(Name).filter(Name.name.ilike('%bhoomi%')).all()
        
        if not names:
            print("❌ No entries found with 'Bhoomi' in names table")
            return
        
        for name in names:
            print(f"\n📋 Found in names table:")
            print(f"   Name: {name.name}")
            print(f"   Phone: {name.phone}")
            print(f"   Group: {name.group}")
            print(f"   Server ID: {name.server_id}")
            
            # Check if already exists in users table
            if name.phone:
                existing_user = db.query(User).filter(User.phone_number == name.phone).first()
                if existing_user:
                    print(f"   ✅ Already exists in users table as: {existing_user.name}")
                    continue
                
                # Migrate to users table
                print(f"\n🔄 Migrating to users table...")
                user_id = str(uuid.uuid4())
                role = name.group if name.group else "Pakka Muneem"
                role_hindi = "पक्का मुनीम"
                
                user = User(
                    id=user_id,
                    name=name.name,
                    name_hindi=name.name,
                    role=role,
                    role_hindi=role_hindi,
                    initials=name.name[0:2].upper() if len(name.name) >= 2 else name.name[0].upper(),
                    phone_number=name.phone,
                    is_active=True
                )
                
                db.add(user)
                db.commit()
                print(f"   ✅ Successfully migrated to users table!")
                print(f"   User ID: {user.id}")
                print(f"   Can now login with: {user.phone_number}")
            else:
                print(f"   ⚠️  No phone number - cannot migrate to users table")
        
    except Exception as e:
        print(f"❌ ERROR: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    check_and_migrate()
