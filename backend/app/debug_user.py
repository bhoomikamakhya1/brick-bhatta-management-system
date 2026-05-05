"""
Debug script to check what user data is being returned for phone +911234567891
"""
from app.database import SessionLocal
from app import models, crud

db = SessionLocal()

phone = "+911234567891"
print(f"Searching for phone: {phone}")

# Check Users table
user = db.query(models.User).filter(models.User.phone_number == phone).first()
if user:
    print(f"\n✅ Found in Users table:")
    print(f"  ID: {user.id}")
    print(f"  Name: {user.name}")
    print(f"  Name Hindi: {user.name_hindi}")
    print(f"  Phone: {user.phone_number}")
    print(f"  Role: {user.role}")
    print(f"  Role Hindi: {user.role_hindi}")
else:
    print(f"\n❌ Not found in Users table")

# Check Names table
name = db.query(models.Name).filter(models.Name.phone == phone).first()
if name:
    print(f"\n✅ Found in Names table:")
    print(f"  Server ID: {name.server_id}")
    print(f"  Name: {name.name}")
    print(f"  Phone: {name.phone}")
    print(f"  Group: {name.group}")
else:
    print(f"\n❌ Not found in Names table")

# Test get_user_by_phone
print(f"\n=== Testing crud.get_user_by_phone ===")
result = crud.get_user_by_phone(db, phone)
if result:
    print(f"✅ Result found:")
    print(f"  ID: {result.id}")
    print(f"  Name: {result.name}")
    print(f"  Phone: {result.phone_number}")
    print(f"  Role: {result.role}")
    print(f"  Has name_hindi: {hasattr(result, 'name_hindi')}")
    print(f"  Has role_hindi: {hasattr(result, 'role_hindi')}")
else:
    print(f"❌ No result from get_user_by_phone")

db.close()
