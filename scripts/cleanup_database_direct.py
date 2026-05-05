#!/usr/bin/env python3
"""
Database Cleanup Script - Direct Execution
Deletes all entries from the database tables.
"""

import sys
import os

# Add parent directory to path to import from backend
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'backend'))

from app.database import get_db
from app.models import WorkEntry, Sale, Transaction, Name
from sqlalchemy.orm import Session

def cleanup_database():
    """Delete all entries from all tables."""
    db: Session = next(get_db())
    
    try:
        print("🗑️  Starting database cleanup...")
        
        # Delete all work entries
        work_count = db.query(WorkEntry).delete()
        print(f"✅ Deleted {work_count} work entries")
        
        # Delete all sales
        sales_count = db.query(Sale).delete()
        print(f"✅ Deleted {sales_count} sales entries")
        
        # Delete all transactions
        trans_count = db.query(Transaction).delete()
        print(f"✅ Deleted {trans_count} transactions")
        
        # Delete all names/parties (users)
        names_count = db.query(Name).delete()
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
        import traceback
        traceback.print_exc()
        raise
    finally:
        db.close()

if __name__ == "__main__":
    print("⚠️  Executing database cleanup...")
    cleanup_database()
