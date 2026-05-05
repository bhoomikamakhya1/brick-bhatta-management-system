"""
Direct SQL script to create Admin user
Phone: 9999999999
"""
import sqlite3
import os

# Database path
db_path = os.path.join(os.path.dirname(__file__), '..', 'backend', 'brick_bhatta.db')

def create_admin_user():
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Check if user exists
        cursor.execute("SELECT id, name, role FROM users WHERE phone_number = ?", ("+919999999999",))
        existing = cursor.fetchone()
        
        if existing:
            print(f"❌ User with phone +919999999999 already exists:")
            print(f"   ID: {existing[0]}")
            print(f"   Name: {existing[1]}")
            print(f"   Role: {existing[2]}")
            conn.close()
            return
        
        # Insert new admin user
        cursor.execute("""
            INSERT INTO users (
                id, name, name_hindi, role, role_hindi, 
                phone_number, initials, is_active
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            "admin_9999999999",
            "Admin User",
            "एडमिन उपयोगकर्ता",
            "Admin",
            "व्यवस्थापक",
            "+919999999999",
            "AU",
            1  # True
        ))
        
        conn.commit()
        
        print("✅ Admin user created successfully!")
        print(f"   ID: admin_9999999999")
        print(f"   Name: Admin User")
        print(f"   Role: Admin")
        print(f"   Phone: +919999999999")
        print("\n📱 You can now login with:")
        print("   Phone: +919999999999 (or 9999999999)")
        print("   OTP: Use Firebase test OTP or real SMS")
        
        conn.close()
        
    except Exception as e:
        print(f"❌ Error creating admin user: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    print("🔧 Creating Admin user in database...")
    print(f"📁 Database: {db_path}")
    create_admin_user()
