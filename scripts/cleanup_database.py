#!/usr/bin/env python3
"""
Database Cleanup Script
Deletes all entries from the database tables.
WARNING: This action is irreversible!
"""

import sys
import os

# Add parent directory to path to import from backend
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'backend'))

from app.database import get_db
from sqlalchemy.orm import Session

def cleanup_database():
    """Delete all entries from all tables."""
    db: Session = next(get_db())
    
    try:
        print("🗑️  Starting database cleanup...")
        
        # Delete all work entries
        result = db.execute("DELETE FROM work_entries")
        work_count = result.rowcount
        print(f"✅ Deleted {work_count} work entries")
        
        # Delete all sales
        result = db.execute("DELETE FROM sales")
        sales_count = result.rowcount
        print(f"✅ Deleted {sales_count} sales entries")
        
        # Delete all transactions
        result = db.execute("DELETE FROM transactions")
        trans_count = result.rowcount
        print(f"✅ Deleted {trans_count} transactions")
        
        # Delete all names/parties (users)
        result = db.execute("DELETE FROM names")
        names_count = result.rowcount
        print(f"✅ Deleted {names_count} user/party entries")
        
        # Commit the changes
        db.commit()
        
        print("\n✅ Database cleanup completed successfully!")
        print(f"📊 Summary:")
        print(f"   - Work entries: {work_count}")
        print(f"   - Sales: {sales_count}")
        print(f"   - Transactions: {trans_count}")
        print(f"   - Users/Parties: {names_count}")
        print(f"   - Total deleted: {work_count + sales_count + trans_count + names_count}")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error during cleanup: {e}")
        raise
    finally:
        db.close()

if __name__ == "__main__":
    print("⚠️  WARNING: This will delete ALL data from the database!")
    print("⚠️  This action cannot be undone!")
    
    response = input("\nAre you sure you want to continue? (type 'YES' to confirm): ")
    
    if response == "YES":
        cleanup_database()
    else:
        print("❌ Cleanup cancelled.")
