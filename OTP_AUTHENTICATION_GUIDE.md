# OTP-Based Authentication System

## Overview

This document describes the OTP (One-Time Password) based authentication system implemented for the Brick Bhatta Management System. The system ensures that only users created by admin can log in using their registered phone numbers.

## Architecture

### Backend (FastAPI)

#### Database Schema

**Users Table** (`users`)
- `id`: Primary key (String)
- `phone_number`: Indexed field for OTP lookup (String, nullable)
- `name`, `name_hindi`: User name in English and Hindi
- `role`, `role_hindi`: User role
- `is_active`: Boolean flag to enable/disable accounts

**OTP Table** (`otps`)
- `id`: Primary key (Integer, auto-increment)
- `phone_number`: Indexed field (String)
- `otp_code`: 6-digit OTP code (String)
- `created_at`: Timestamp when OTP was created
- `expires_at`: Timestamp when OTP expires (default: 5 minutes)
- `verified`: Boolean flag indicating if OTP was verified
- `attempts`: Number of verification attempts (max: 5)

#### API Endpoints

1. **POST `/otp/check-phone`**
   - **Purpose**: Check if a phone number exists in the database
   - **Request Body**: `{ "phone_number": "+919876543210" }`
   - **Response**: 
     ```json
     {
       "exists": true,
       "message": "Phone number found",
       "user_id": "user123",
       "name": "John Doe",
       "role": "worker"
     }
     ```
   - **Error Responses**:
     - `404`: Phone number not registered
     - `403`: Account is inactive

2. **POST `/otp/send`**
   - **Purpose**: Send OTP to a registered phone number
   - **Request Body**: `{ "phone_number": "+919876543210" }`
   - **Response**:
     ```json
     {
       "success": true,
       "message": "OTP sent successfully",
       "expires_in": 300
     }
     ```
   - **Rate Limiting**: Maximum 3 OTP requests per phone number per 10 minutes
   - **Error Responses**:
     - `404`: Phone number not registered
     - `403`: Account is inactive
     - `429`: Too many OTP requests

3. **POST `/otp/verify`**
   - **Purpose**: Verify OTP code and authenticate user
   - **Request Body**: 
     ```json
     {
       "phone_number": "+919876543210",
       "otp_code": "123456"
     }
     ```
   - **Response**:
     ```json
     {
       "success": true,
       "message": "OTP verified successfully",
       "user": {
         "id": "user123",
         "name": "John Doe",
         "role": "worker",
         ...
       },
       "token": null
     }
     ```
   - **Error Responses**:
     - `400`: Invalid or expired OTP

#### Security Features

1. **OTP Expiry**: OTPs expire after 5 minutes
2. **Rate Limiting**: Maximum 3 OTP requests per phone number per 10 minutes
3. **Attempt Limiting**: Maximum 5 verification attempts per OTP
4. **Phone Number Normalization**: Phone numbers are normalized (spaces, dashes removed) before storage and lookup
5. **Automatic Cleanup**: Expired OTPs are automatically cleaned up

### Frontend (Flutter)

#### OTP Service (`lib/services/otp_service.dart`)

The `OtpService` class provides three main methods:

1. `checkPhoneNumber(String phoneNumber)`: Checks if phone number exists
2. `sendOtp(String phoneNumber)`: Sends OTP to phone number
3. `verifyOtp(String phoneNumber, String otpCode)`: Verifies OTP and returns user data

#### Login Screen (`lib/screens/login_screen.dart`)

The login screen implements a 3-step flow:

1. **Phone Number Entry**: User enters phone number
2. **OTP Entry**: After phone verification, user enters 6-digit OTP
3. **Authentication**: On successful OTP verification, user is logged in

#### Authentication Flow

```
1. User enters phone number
   ↓
2. App calls /otp/check-phone
   ↓
3. If phone exists → App calls /otp/send
   ↓
4. User receives OTP via SMS
   ↓
5. User enters OTP
   ↓
6. App calls /otp/verify
   ↓
7. On success → User data saved to SharedPreferences
   ↓
8. User redirected to main screen
```

## User Management

### Admin Creates Users

Only admin users can create new user accounts. When creating a user:

1. Admin provides:
   - Name (English and Hindi)
   - Phone number (required for OTP login)
   - Role (worker, supervisor, manager, etc.)
   - Other optional details

2. User is saved to database with `is_active = true`

3. User can now log in using OTP on their registered phone number

### Non-Admin Users

- **Cannot self-register**
- Must be created by admin
- Can only log in using OTP sent to their registered phone number

## SMS Integration

Currently, the SMS sending is implemented as a placeholder. To integrate with a real SMS service:

1. **Option 1: Twilio**
   ```python
   from twilio.rest import Client
   
   def _send_sms(phone_number: str, message: str) -> bool:
       client = Client(account_sid, auth_token)
       message = client.messages.create(
           body=message,
           from_=twilio_phone_number,
           to=phone_number
       )
       return message.sid is not None
   ```

2. **Option 2: AWS SNS**
   ```python
   import boto3
   
   def _send_sms(phone_number: str, message: str) -> bool:
       sns = boto3.client('sns')
       response = sns.publish(
           PhoneNumber=phone_number,
           Message=message
       )
       return response['ResponseMetadata']['HTTPStatusCode'] == 200
   ```

3. **Option 2: Firebase Cloud Messaging** (for app notifications)
   - Can be used for in-app notifications instead of SMS
   - Requires Firebase setup

4. **Option 4: Custom SMS Gateway**
   - Integrate with your local SMS gateway provider

## Security Best Practices

1. **Rate Limiting**: Prevents OTP spam and abuse
2. **OTP Expiry**: OTPs expire after 5 minutes
3. **Attempt Limiting**: Maximum 5 verification attempts per OTP
4. **Phone Number Validation**: Phone numbers are normalized and validated
5. **Account Status Check**: Inactive accounts cannot receive OTPs
6. **Automatic Cleanup**: Expired OTPs are automatically removed

## Configuration

### Backend Configuration

In `backend/app/routers/otp.py`:
- `MAX_OTP_REQUESTS_PER_WINDOW = 3`: Maximum OTP requests per time window
- `OTP_RATE_LIMIT_WINDOW_MINUTES = 10`: Time window for rate limiting
- `OTP_EXPIRY_MINUTES = 5`: OTP expiry time

### Frontend Configuration

In `lib/config/api_config.dart`:
- Update `baseUrl` to point to your backend server
- Configure API keys and headers as needed

## Testing

### Development Mode

For development/testing, the SMS sending is currently logged to console. You can:

1. Check backend logs for OTP codes
2. Use the OTP code from logs to test verification
3. Implement mock SMS service for testing

### Production Mode

1. Integrate with real SMS service
2. Set up proper error handling
3. Monitor OTP generation and verification rates
4. Set up alerts for suspicious activity

## Troubleshooting

### Common Issues

1. **"Phone number not registered"**
   - Ensure user is created by admin with correct phone number
   - Check phone number format (should include country code)

2. **"Too many OTP requests"**
   - Wait 10 minutes before requesting new OTP
   - Check rate limiting configuration

3. **"Invalid or expired OTP"**
   - OTP expires after 5 minutes
   - Maximum 5 verification attempts allowed
   - Request a new OTP if expired

4. **SMS not received**
   - Check SMS service integration
   - Verify phone number format
   - Check backend logs for errors

## Future Enhancements

1. **JWT Token Generation**: Generate JWT tokens after OTP verification
2. **Biometric Authentication**: Add fingerprint/face recognition
3. **Multi-Factor Authentication**: Add additional security layers
4. **OTP Resend Timer**: Show countdown timer for OTP resend
5. **SMS Delivery Status**: Track SMS delivery status
6. **Admin Dashboard**: View OTP statistics and user login history

## Database Migrations

When deploying to production, use Alembic for database migrations:

```bash
# Create migration
alembic revision --autogenerate -m "Add OTP table"

# Apply migration
alembic upgrade head
```

For development, tables are automatically created on startup (see `backend/app/main.py`).

