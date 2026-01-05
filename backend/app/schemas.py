from pydantic import BaseModel, Field, computed_field
from typing import List, Optional
from datetime import datetime

# --- Name Schemas ---
class NameBase(BaseModel):
    name: str
    value: Optional[str] = None
    group: Optional[str] = None
    phone: Optional[str] = None
    gstin: Optional[str] = None
    commission_percent: Optional[float] = None

class NameCreate(BaseModel):
    # Accept display_name from Flutter and map it to name
    display_name: Optional[str] = None
    name: Optional[str] = None  # Allow direct name field too
    value: Optional[str] = None
    group: Optional[str] = None
    phone: Optional[str] = None
    gstin: Optional[str] = None
    commission_percent: Optional[float] = None

class Name(BaseModel):
    server_id: str
    name: str
    value: Optional[str] = None
    group: Optional[str] = None
    phone: Optional[str] = None
    gstin: Optional[str] = None
    commission_percent: Optional[float] = None
    
    # Add display_name as computed field for Flutter compatibility
    @computed_field
    @property
    def display_name(self) -> str:
        return self.name

    class Config:
        from_attributes = True

# Work Schemas
class WorkBase(BaseModel):
    labour_name: str
    labour_category: str
    quantity: float
    percentage: Optional[float] = None
    rate: float
    total_amount: float
    date: datetime

class WorkCreate(WorkBase):
    id: Optional[str] = None # Allow client to provide ID if syncing offline data

class Work(WorkBase):
    id: str
    created_by: Optional[str] = None

    class Config:
        from_attributes = True

# Transaction Schemas
class TransactionBase(BaseModel):
    party_name: str
    amount: float
    type: str # 'credit' or 'debit'
    category: str
    date: datetime
    description: Optional[str] = None
    party_id: Optional[str] = None # Optional link to User ID

class TransactionCreate(TransactionBase):
    id: Optional[str] = None

class Transaction(TransactionBase):
    id: str
    created_by: Optional[str] = None

    class Config:
        from_attributes = True


# --- User Schemas ---
class UserBase(BaseModel):
    name: str
    name_hindi: str
    role: str
    role_hindi: str
    is_active: bool = True
    initials: str
    contact_person: Optional[str] = None
    phone_number: Optional[str] = None
    address: Optional[str] = None
    party_type: Optional[str] = None
    gst_number: Optional[str] = None
    opening_balance: Optional[float] = None
    opening_balance_type: Optional[str] = None
    credit_limit: Optional[float] = None

class UserCreate(UserBase):
    id: str # Allow setting ID manually (Firebase UID)

class User(UserBase):
    id: str

    class Config:
        from_attributes = True

# --- OTP Schemas ---
class OTPRequest(BaseModel):
    phone_number: str = Field(..., description="Phone number in E.164 format (e.g., +919876543210)")

class OTPSendResponse(BaseModel):
    success: bool
    message: str
    expires_in: int = Field(default=300, description="OTP expiry time in seconds")

class OTPVerifyRequest(BaseModel):
    phone_number: str
    otp_code: str

class OTPVerifyResponse(BaseModel):
    success: bool
    message: str
    user: Optional[User] = None
    token: Optional[str] = None  # For future JWT token implementation

# --- Sale Schemas ---
class BrickEntryBase(BaseModel):
    brick_type: str
    quantity: float
    price: float

class BrickEntryCreate(BrickEntryBase):
    id: Optional[str] = None

class BrickEntry(BrickEntryBase):
    id: str
    sale_id: str

    class Config:
        from_attributes = True

class FreightDetailsBase(BaseModel):
    type: str
    vehicle_number: Optional[str] = None
    vehicle_name: Optional[str] = None
    driver_name: Optional[str] = None
    driver_phone: Optional[str] = None
    rate_per_1000: float = 0.0

class FreightDetailsCreate(FreightDetailsBase):
    pass

class FreightDetails(FreightDetailsBase):
    id: int
    sale_id: str

    class Config:
        from_attributes = True

class SaleBase(BaseModel):
    customer_name: str
    customer_name_hindi: str
    customer_address: Optional[str] = None
    customer_phone: Optional[str] = None
    date: datetime
    time: datetime
    advance_payment: float = 0.0
    total_amount: float
    final_amount: float
    remarks: Optional[str] = None
    otp: Optional[str] = None

class SaleCreate(SaleBase):
    id: Optional[str] = None
    brick_entries: List[BrickEntryCreate]
    freight_details: Optional[FreightDetailsCreate] = None
    created_by: str

class Sale(SaleBase):
    id: str
    created_by: str
    brick_entries: List[BrickEntry] = []
    freight_details: Optional[FreightDetails] = None

    class Config:
        from_attributes = True
