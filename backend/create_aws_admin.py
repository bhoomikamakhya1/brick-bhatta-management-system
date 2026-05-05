#!/usr/bin/env python3
"""
Script to create an Admin user on AWS backend
"""
import requests
import json

# AWS Backend URL
BASE_URL = "http://54.221.131.247:8000"

def create_admin_user():
    url = f"{BASE_URL}/users/"
    
    user_data = {
        "phoneNumber": "+919999999999",
        "displayName": "Admin User",
        "role": "Admin"
    }
    
    print(f"Creating admin user on AWS backend...")
    print(f"URL: {url}")
    print(f"Data: {json.dumps(user_data, indent=2)}")
    print()
    
    try:
        response = requests.post(url, json=user_data)
        
        if response.status_code == 200 or response.status_code == 201:
            print("✅ SUCCESS! Admin user created:")
            print(json.dumps(response.json(), indent=2))
            print()
            print("You can now login with phone number: +919999999999")
        else:
            print(f"❌ ERROR: Status code {response.status_code}")
            print(f"Response: {response.text}")
    
    except requests.exceptions.ConnectionError:
        print("❌ ERROR: Could not connect to AWS backend.")
        print("Make sure the backend is running at http://54.221.131.247:8000")
    except Exception as e:
        print(f"❌ ERROR: {str(e)}")

if __name__ == "__main__":
    create_admin_user()
