from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from .. import crud, models, schemas, database, dependencies

router = APIRouter(
    prefix="/transactions",
    tags=["transactions"],
    dependencies=[Depends(dependencies.get_current_user)]
)

@router.post("/", response_model=schemas.Transaction)
def create_transaction(txn: schemas.TransactionCreate, db: Session = Depends(database.get_db), current_user: dict = Depends(dependencies.get_current_user)):
    return crud.create_transaction(db=db, transaction=txn, user_id=current_user['uid'])

@router.get("/", response_model=List[schemas.Transaction])
def read_transactions(skip: int = 0, limit: int = 1000, db: Session = Depends(database.get_db), user_context: dict = Depends(dependencies.get_user_context)):
    """
    Get transactions based on user role:
    - Admin: Returns all transactions
    - Kaccha/Pakka Muneem: Returns only transactions created by this user
    """
    txns = crud.get_transactions_for_user(db, user_context['user_id'], user_context['role'], skip=skip, limit=limit)
    return txns


@router.get("/{txn_id}", response_model=schemas.Transaction)
def read_transaction(txn_id: str, db: Session = Depends(database.get_db)):
    db_txn = crud.get_transaction(db, transaction_id=txn_id)
    if db_txn is None:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return db_txn
