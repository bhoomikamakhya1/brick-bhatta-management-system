from app.database import SessionLocal
from app import models

db = SessionLocal()

# Check for the specific phone number
target_phone = "+911234567891"
print(f"Searching for: {target_phone}")

users = db.query(models.User).all()
print(f"\n=== ALL USERS ({len(users)}) ===")
for u in users:
    print(f"  User {u.id}: {u.name} - {u.phone_number} ({u.role})")
    if u.phone_number == target_phone:
        print(f"    ✅ MATCH FOUND!")

names = db.query(models.Name).filter(models.Name.phone.isnot(None)).all()
print(f"\n=== ALL NAMES WITH PHONE ({len(names)}) ===")
for n in names:
    print(f"  Name {n.server_id}: {n.name} - {n.phone} ({n.group})")
    if n.phone == target_phone:
        print(f"    ✅ MATCH FOUND!")

db.close()
