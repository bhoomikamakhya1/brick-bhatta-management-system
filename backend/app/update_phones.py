from app.database import SessionLocal
from app import models

db = SessionLocal()

# Update all users without country code
users = db.query(models.User).all()
for u in users:
    if u.phone_number and not u.phone_number.startswith('+'):
        old = u.phone_number
        u.phone_number = f"+91{u.phone_number}"
        print(f"Updated user {u.id}: {old} -> {u.phone_number}")

# Update all names without country code
names = db.query(models.Name).filter(models.Name.phone.isnot(None)).all()
for n in names:
    if n.phone and not n.phone.startswith('+'):
        old = n.phone
        n.phone = f"+91{n.phone}"
        print(f"Updated name {n.server_id}: {old} -> {n.phone}")

db.commit()
print("Done!")
db.close()
