from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from .. import crud, models, schemas, dependencies

router = APIRouter(
    prefix="/sales",
    tags=["sales"],
    dependencies=[Depends(dependencies.get_current_user)], # Protect all sales routes
    responses={404: {"description": "Not found"}},
)

@router.get("/", response_model=List[schemas.Sale])
def read_sales(skip: int = 0, limit: int = 100, db: Session = Depends(dependencies.get_db), user_context: dict = Depends(dependencies.get_user_context)):
    """
    Get sales based on user role:
    - Admin: Returns all sales
    - Kaccha/Pakka Muneem: Returns only sales created by this user
    """
    sales = crud.get_sales_for_user(db, user_context['user_id'], user_context['role'], skip=skip, limit=limit)
    return sales


@router.post("/", response_model=schemas.Sale, status_code=status.HTTP_201_CREATED)
def create_sale(sale: schemas.SaleCreate, db: Session = Depends(dependencies.get_db)):
    # Verify creator exists
    user = crud.get_user(db, user_id=sale.created_by)
    if not user:
        # Optionally create the user implicitly or throw error
        # Implementation choice: throw error for integrity
        raise HTTPException(status_code=400, detail=f"User {sale.created_by} does not exist. Create user first.")
        
    return crud.create_sale(db=db, sale=sale)

@router.get("/{sale_id}", response_model=schemas.Sale)
def read_sale(sale_id: str, db: Session = Depends(dependencies.get_db)):
    db_sale = crud.get_sale(db, sale_id=sale_id)
    if db_sale is None:
        raise HTTPException(status_code=404, detail="Sale not found")
    return db_sale
