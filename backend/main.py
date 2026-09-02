from fastapi import FastAPI, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from sqlalchemy import text
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime, timedelta
import random
import bcrypt

import models, schemas
from database import engine, get_db
import email_service

# Ensure tables are created
models.Base.metadata.create_all(bind=engine)

# Auto-migrate database schema columns if they don't exist
with engine.connect() as conn:
    try:
        conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE;"))
        conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS otp_code VARCHAR;"))
        conn.execute(text("ALTER TABLE users ADD COLUMN IF NOT EXISTS otp_expiry TIMESTAMP;"))
        conn.commit()
    except Exception as e:
        print(f"Migration note: {e}")

app = FastAPI(title="Login App API")

# Add CORS middleware to allow requests from Flutter (web/mobile)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Welcome to the Login App API. Go to /docs for the API documentation."}

def get_password_hash(password: str) -> str:
    pwd_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password=pwd_bytes, salt=salt)
    return hashed_password.decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    password_byte_enc = plain_password.encode('utf-8')
    hashed_password_byte_enc = hashed_password.encode('utf-8')
    return bcrypt.checkpw(password=password_byte_enc, hashed_password=hashed_password_byte_enc)

def generate_otp() -> str:
    return f"{random.randint(100000, 999999)}"

@app.post("/register")
def register(user: schemas.UserCreate, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    clean_email = user.email.strip().lower()
    
    db_user = db.query(models.User).filter(models.User.email == clean_email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    otp = generate_otp()
    hashed_pwd = get_password_hash(user.password)
    new_user = models.User(
        name=user.name.strip(), 
        email=clean_email, 
        mobile=user.mobile.strip(),
        hashed_password=hashed_pwd,
        is_verified=False,
        otp_code=otp,
        otp_expiry=datetime.utcnow() + timedelta(minutes=10)
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # Send OTP email directly to user's Gmail
    background_tasks.add_task(
        email_service.send_login_otp, 
        clean_email, 
        new_user.name,
        otp
    )

    return {
        "status": "otp_sent",
        "message": "An OTP has been sent to your email address. Please check your Gmail and enter the OTP to verify your account.",
        "email": clean_email,
        "name": new_user.name
    }


@app.post("/login")
def login(user: schemas.UserLogin, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    clean_identifier = user.email.strip().lower()
    
    db_user = db.query(models.User).filter(
        (models.User.email == clean_identifier) | (models.User.mobile == user.email.strip())
    ).first()
    
    if not db_user:
        raise HTTPException(status_code=400, detail="Invalid email or password")
    
    if not verify_password(user.password, db_user.hashed_password):
        raise HTTPException(status_code=400, detail="Invalid email or password")
    
    # Check if first-time login verification is required
    if not db_user.is_verified:
        otp = generate_otp()
        db_user.otp_code = otp
        db_user.otp_expiry = datetime.utcnow() + timedelta(minutes=10)
        db.commit()

        # Send OTP email for first-time login
        background_tasks.add_task(
            email_service.send_login_otp, 
            db_user.email, 
            db_user.name, 
            otp
        )

        return {
            "status": "otp_required",
            "message": "First-time login requires OTP verification. An OTP has been sent to your registered email.",
            "email": db_user.email
        }
    
    return {
        "status": "success",
        "message": "Login successful", 
        "user": {
            "id": db_user.id, 
            "name": db_user.name, 
            "email": db_user.email,
            "mobile": db_user.mobile,
            "is_verified": db_user.is_verified
        }
    }

@app.post("/verify-otp")
def verify_otp(payload: schemas.OTPVerifyRequest, db: Session = Depends(get_db)):
    clean_email = payload.email.strip().lower()
    user = db.query(models.User).filter(models.User.email == clean_email).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if not user.otp_code or user.otp_code != payload.otp.strip():
        raise HTTPException(status_code=400, detail="Invalid verification code. Please check and try again.")
    
    if user.otp_expiry and user.otp_expiry < datetime.utcnow():
        raise HTTPException(status_code=400, detail="Verification code has expired. Please request a new code.")
    
    # OTP is valid: verify user and clear OTP
    user.is_verified = True
    user.otp_code = None
    user.otp_expiry = None
    db.commit()
    db.refresh(user)

    return {
        "status": "success",
        "message": "Email verified successfully! Login complete.",
        "user": {
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "mobile": user.mobile,
            "is_verified": user.is_verified
        }
    }

@app.post("/resend-otp")
def resend_otp(payload: schemas.OTPResendRequest, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    clean_email = payload.email.strip().lower()
    user = db.query(models.User).filter(models.User.email == clean_email).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    otp = generate_otp()
    user.otp_code = otp
    user.otp_expiry = datetime.utcnow() + timedelta(minutes=10)
    db.commit()

    background_tasks.add_task(
        email_service.send_login_otp, 
        user.email, 
        user.name, 
        otp
    )

    return {
        "status": "success",
        "message": "A new verification code has been sent to your email."
    }

