from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from .. import crud, models, schemas, dependencies

router = APIRouter(
    prefix="/names",
    tags=["names"],
    responses={404: {"description": "Not found"}},
)

@router.get("/", response_model=List[schemas.Name])
def read_names(skip: int = 0, limit: int = 100, db: Session = Depends(dependencies.get_db)):
    names = crud.get_names(db, skip=skip, limit=limit)
    return names

@router.post("/", response_model=schemas.Name, status_code=status.HTTP_201_CREATED)
def create_name(name: schemas.NameCreate, db: Session = Depends(dependencies.get_db)):
    try:
        return crud.create_name(db=db, name=name)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        # Log the error for debugging
        import traceback
        error_detail = f"Internal server error: {str(e)}"
        print(f"Error in create_name endpoint: {error_detail}")
        print(traceback.format_exc())
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_detail)

@router.put("/{server_id}", response_model=schemas.Name)
def update_name(server_id: str, name: schemas.NameCreate, db: Session = Depends(dependencies.get_db)):
    db_name = crud.update_name(db, server_id=server_id, name=name)
    if db_name is None:
        raise HTTPException(status_code=404, detail="Name not found")
    return db_name

@router.delete("/{server_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_name(server_id: str, db: Session = Depends(dependencies.get_db)):
    success = crud.delete_name(db, server_id=server_id)
    if not success:
        raise HTTPException(status_code=404, detail="Name not found")
    return None
