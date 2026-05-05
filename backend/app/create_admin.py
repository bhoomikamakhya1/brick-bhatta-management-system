"""
Create Admin user
"""
from app.database import SessionLocal
from app import models

def create_admin():
    db = SessionLocal()
    try:
        # Check if Admin already exists
        admin = db.query(models.User).filter(models.User.role == "Admin").first()
        
        if admin:
            print(f"✅ Admin user already exists: {admin.id} - {admin.name}")
            return
        
        # Get all existing users to see what we have
        all_users = db.query(models.User).all()
        print(f"Found {len(all_users)} existing users:")
        for u in all_users:
            print(f"  - {u.id}: {u.name} ({u.phone_number}) - Role: {u.role}")
        
        # Create new Admin user
        admin_user = models.User(
            id="admin_001",  # Fixed ID for admin
            name="Admin",
            name_hindi="व्यवस्थापक",
            phone_number="+919999999999",  # Admin phone number
            role="Admin",
            role_hindi="व्यवस्थापक",
            initials="ADM",
            is_active=True
        )
        
        db.add(admin_user)
        db.commit()
        db.refresh(admin_user)
        
        print(f"\n✅ Created Admin user: {admin_user.id} - {admin_user.name}")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        db.rollback()
        raise
    finally:
        db.close()

if __name__ == "__main__":
    create_admin()
