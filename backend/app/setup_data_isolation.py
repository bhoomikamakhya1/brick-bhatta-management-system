"""
Setup script for role-based data isolation:
1. Update phone +911234567891 group to "Pakka Muneem"
2. Assign all existing data to Admin user
"""
from app.database import SessionLocal
from app import models

def setup_data_isolation():
    db = SessionLocal()
    try:
        # Step 1: Find or create Admin user
        admin = db.query(models.User).filter(models.User.role == "Admin").first()
        
        if not admin:
            print("❌ No Admin user found! Please create an Admin user first.")
            return
        
        print(f"✅ Found Admin user: {admin.id} - {admin.name}")
        admin_id = admin.id
        
        # Step 2: Update phone +911234567891 to Pakka Muneem
        target_phone = "+911234567891"
        name_record = db.query(models.Name).filter(models.Name.phone == target_phone).first()
        
        if name_record:
            old_group = name_record.group
            name_record.group = "Pakka Muneem"
            print(f"✅ Updated {name_record.name} ({target_phone}): {old_group} -> Pakka Muneem")
        else:
            print(f"⚠️  No Name record found with phone {target_phone}")
        
        # Step 3: Assign all existing data to Admin
        
        # Update Work entries
        works = db.query(models.Work).filter(
            (models.Work.created_by == None) | (models.Work.created_by == "")
        ).all()
        for work in works:
            work.created_by = admin_id
        print(f"✅ Assigned {len(works)} work entries to Admin")
        
        # Update Sales
        sales = db.query(models.Sale).filter(
            (models.Sale.created_by == None) | (models.Sale.created_by == "")
        ).all()
        for sale in sales:
            sale.created_by = admin_id
        print(f"✅ Assigned {len(sales)} sales to Admin")
        
        # Update Transactions
        transactions = db.query(models.Transaction).filter(
            (models.Transaction.created_by == None) | (models.Transaction.created_by == "")
        ).all()
        for txn in transactions:
            txn.created_by = admin_id
        print(f"✅ Assigned {len(transactions)} transactions to Admin")
        
        # Update Names (optional - names might not have created_by)
        # Check if Name model has created_by field
        if hasattr(models.Name, 'created_by'):
            names = db.query(models.Name).filter(
                (models.Name.created_by == None) | (models.Name.created_by == "")
            ).all()
            for name in names:
                name.created_by = admin_id
            print(f"✅ Assigned {len(names)} names to Admin")
        
        db.commit()
        print("\n✅ Data isolation setup complete!")
        
        # Show summary
        print("\n=== SUMMARY ===")
        print(f"Admin ID: {admin_id}")
        print(f"Work entries owned by Admin: {db.query(models.Work).filter(models.Work.created_by == admin_id).count()}")
        print(f"Sales owned by Admin: {db.query(models.Sale).filter(models.Sale.created_by == admin_id).count()}")
        print(f"Transactions owned by Admin: {db.query(models.Transaction).filter(models.Transaction.created_by == admin_id).count()}")
        
        # Show Pakka Muneem user
        if name_record:
            print(f"\nPakka Muneem: {name_record.name} ({name_record.phone}) - ID: {name_record.server_id}")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        db.rollback()
        raise
    finally:
        db.close()

if __name__ == "__main__":
    setup_data_isolation()
