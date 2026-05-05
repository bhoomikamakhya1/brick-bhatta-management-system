"""
Script to create an Admin user in the database
Phone: 9999999999
"""
import sys
import os

# Add parent directory to path to import backend modules
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'backend'))

from app.database import SessionLocal, engine
from app import models
from datetime import datetime

def create_admin_user():
    db = SessionLocal()
    try:
        # Check if user already exists
        existing_user = db.query(models.User).filter(
            models.User.phone_number == "+919999999999"
        ).first()
        
        if existing_user:
            print(f"❌ User with phone +919999999999 already exists:")
            print(f"   ID: {existing_user.id}")
            print(f"   Name: {existing_user.name}")
            print(f"   Role: {existing_user.role}")
            return
        
        # Create new admin user
        admin_user = models.User(
            id="admin_9999999999",  # Custom ID
            name="Admin User",
            name_hindi="एडमिन उपयोगकर्ता",
            role="Admin",
            role_hindi="व्यवस्थापक",
            phone_number="+919999999999",
            initials="AU",  # Required field
            is_active=True
        )
        
        db.add(admin_user)
        db.commit()
        db.refresh(admin_user)
        
        print("✅ Admin user created successfully!")
        print(f"   ID: {admin_user.id}")
        print(f"   Name: {admin_user.name}")
        print(f"   Role: {admin_user.role}")
        print(f"   Phone: {admin_user.phone_number}")
        print("\n📱 You can now login with:")
        print("   Phone: +919999999999 (or 9999999999)")
        print("   OTP: Use Firebase test OTP or real SMS")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error creating admin user: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    print("🔧 Creating Admin user in database...")
    create_admin_user()
