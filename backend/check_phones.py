from app.database import SessionLocal
from app import models

db = SessionLocal()
users = db.query(models.User).all()
print("=== USERS ===")
for u in users:
    print(f"User {u.id}: name={u.name}, phone=\"{u.phone_number}\", role={u.role}")

names = db.query(models.Name).filter(models.Name.phone.isnot(None)).all()
print("\n=== NAMES WITH PHONE ===")
for n in names:
    print(f"Name {n.server_id}: name={n.name}, phone=\"{n.phone}\", group={n.group}")

db.close()
