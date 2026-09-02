from sqlalchemy import Column, Integer, String, Boolean, DateTime
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    mobile = Column(String, index=True)
    hashed_password = Column(String)
    is_verified = Column(Boolean, default=False, nullable=False)
    otp_code = Column(String, nullable=True)
    otp_expiry = Column(DateTime, nullable=True)

