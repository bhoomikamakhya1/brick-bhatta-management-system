"""
Fix phone numbers in database to include country code +91
"""
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database import SessionLocal
from app import models

def fix_phone_numbers():
    db = SessionLocal()
    try:
        # Fix User table phone numbers
        users = db.query(models.User).all()
        print(f"Found {len(users)} users")
        
        for user in users:
            if user.phone_number and not user.phone_number.startswith('+'):
                old_phone = user.phone_number
                # Add +91 country code if not present
                user.phone_number = f"+91{user.phone_number}"
                print(f"Updated user {user.id}: {old_phone} -> {user.phone_number}")
        
        # Fix Name table phone numbers (for Kaccha/Pakka Muneem)
        names = db.query(models.Name).filter(models.Name.phone.isnot(None)).all()
        print(f"\nFound {len(names)} names with phone numbers")
        
        for name in names:
            if name.phone and not name.phone.startswith('+'):
                old_phone = name.phone
                # Add +91 country code if not present
                name.phone = f"+91{name.phone}"
                print(f"Updated name {name.server_id} ({name.name}): {old_phone} -> {name.phone}")
        
        db.commit()
        print("\n✅ Phone numbers updated successfully!")
        
        # Show updated records
        print("\n=== Updated Users ===")
        users = db.query(models.User).all()
        for user in users:
            print(f"  {user.id}: {user.name} - {user.phone_number} ({user.role})")
        
        print("\n=== Updated Names with Phone ===")
        names = db.query(models.Name).filter(models.Name.phone.isnot(None)).all()
        for name in names:
            print(f"  {name.server_id}: {name.name} - {name.phone} ({name.group})")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        db.rollback()
        raise
    finally:
        db.close()

if __name__ == "__main__":
    fix_phone_numbers()
