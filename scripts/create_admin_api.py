"""
Create Admin user via Backend API
Phone: 9999999999
"""
import requests
import json

# Backend URL (update if different)
BASE_URL = "http://192.168.1.196:8000"

def create_admin_user():
    try:
        # Admin user data
        user_data = {
            "id": "admin_9999999999",
            "name": "Admin User",
            "name_hindi": "एडमिन उपयोगकर्ता",
            "role": "Admin",
            "role_hindi": "व्यवस्थापक",
            "phone_number": "+919999999999",
            "initials": "AU",
            "is_active": True
        }
        
        # Headers
        headers = {
            "Content-Type": "application/json",
            "X-API-KEY": "brick_bhatta_123",
            "X-Tenant-ID": "kiln-001"
        }
        
        print("🔧 Creating Admin user via API...")
        print(f"📡 Backend: {BASE_URL}")
        
        # Create user
        response = requests.post(
            f"{BASE_URL}/users/",
            headers=headers,
            json=user_data,
            timeout=10
        )
        
        if response.status_code == 200:
            created_user = response.json()
            print("✅ Admin user created successfully!")
            print(f"   ID: {created_user.get('id')}")
            print(f"   Name: {created_user.get('name')}")
            print(f"   Role: {created_user.get('role')}")
            print(f"   Phone: {created_user.get('phone_number')}")
            print("\n📱 You can now login with:")
            print("   Phone: +919999999999 (or 9999999999)")
            print("   OTP: Use Firebase test OTP or real SMS")
        elif response.status_code == 400:
            print(f"❌ User might already exist or validation failed:")
            print(f"   {response.text}")
        else:
            print(f"❌ Error: HTTP {response.status_code}")
            print(f"   {response.text}")
            
    except requests.exceptions.ConnectionError:
        print("❌ Could not connect to backend server")
        print(f"   Make sure the backend is running at {BASE_URL}")
        print("   Run: cd backend && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000")
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    create_admin_user()
