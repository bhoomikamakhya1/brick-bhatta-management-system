from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import names, users, sales, work, transactions, otp
from .database import engine, Base

# Create tables on startup (for simple verified stability as requested)
# In production, use Alembic for migrations
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Brick Bhatta Management System API",
    description="Backend for Brick Bhatta Management System Flutter App",
    version="1.0.0",
)

# CORS Configuration
origins = ["*"] # Allow all for development. Restrict in production.

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(names.router)
app.include_router(users.router)
app.include_router(sales.router)
app.include_router(work.router)
app.include_router(transactions.router)
app.include_router(otp.router)

@app.get("/health")
def read_health():
    return {"status": "ok", "message": "Service is running"}

@app.get("/")
def read_root():
    return {"message": "Welcome to Brick Bhatta Management System API"}
