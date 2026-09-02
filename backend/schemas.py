from pydantic import BaseModel, EmailStr
from typing import Optional

class UserCreate(BaseModel):
    name: str
    email: EmailStr
    mobile: str
    password: str

class UserResponse(BaseModel):
    id: int
    name: str
    email: EmailStr
    mobile: str | None = None
    is_verified: bool = False

    class Config:
        from_attributes = True

class UserLogin(BaseModel):
    email: str
    password: str

class OTPVerifyRequest(BaseModel):
    email: EmailStr
    otp: str

class OTPResendRequest(BaseModel):
    email: EmailStr

