"""
Fix user role for bhoomi pakka - should be Pakka Muneem not General
"""
from app.database import SessionLocal
from app import models

db = SessionLocal()

# Update the user role
user = db.query(models.User).filter(models.User.id == "1767660735026").first()
if user:
    print(f"Found user: {user.name}")
    print(f"  Current role: {user.role}")
    print(f"  Current role_hindi: {user.role_hindi}")
    
    user.role = "Pakka Muneem"
    user.role_hindi = "पक्का मुनीम"
    
    db.commit()
    print(f"\n✅ Updated role to: {user.role}")
    print(f"✅ Updated role_hindi to: {user.role_hindi}")
else:
    print("❌ User not found")

db.close()
