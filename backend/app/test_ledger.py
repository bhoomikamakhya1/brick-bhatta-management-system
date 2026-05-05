"""
Test ledger filtering for Pakka Muneem user
"""
from app.database import SessionLocal
from app import models, crud

db = SessionLocal()

user_id = "1767660735026"  # bhoomi pakka
role = "Pakka Muneem"

print(f"Testing ledger filtering for user: {user_id}, role: {role}")

# Test get_names_for_user
names = crud.get_names_for_user(db, user_id, role, skip=0, limit=100)

print(f"\n✅ get_names_for_user returned {len(names)} names")

if len(names) > 0:
    print("\n❌ ERROR: Pakka Muneem should see EMPTY ledger!")
    print("Names returned:")
    for name in names:
        print(f"  - {name.name} ({name.phone}) - group: {name.group}")
else:
    print("\n✅ SUCCESS: Ledger is empty for Pakka Muneem (as expected)")

# Test for Admin
print(f"\n\n=== Testing for Admin ===")
admin_names = crud.get_names_for_user(db, "admin_001", "Admin", skip=0, limit=100)
print(f"Admin sees {len(admin_names)} names")

# Check if Admin is in the list
admin_in_list = any(n.phone == "+919999999999" for n in admin_names if n.phone)
if admin_in_list:
    print("❌ ERROR: Admin should NOT appear in ledger!")
else:
    print("✅ SUCCESS: Admin is hidden from ledger")

db.close()
