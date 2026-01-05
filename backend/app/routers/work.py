from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from .. import crud, models, schemas, database, dependencies

router = APIRouter(
    prefix="/work",
    tags=["work"],
    dependencies=[Depends(dependencies.get_current_user)]
)

@router.post("/", response_model=schemas.Work)
def create_work(work: schemas.WorkCreate, db: Session = Depends(database.get_db), current_user: dict = Depends(dependencies.get_current_user)):
    return crud.create_work(db=db, work=work, user_id=current_user['uid'])

@router.get("/", response_model=List[schemas.Work])
def read_works(skip: int = 0, limit: int = 1000, db: Session = Depends(database.get_db)):
    works = crud.get_works(db, skip=skip, limit=limit)
    return works

@router.get("/{work_id}", response_model=schemas.Work)
def read_work(work_id: str, db: Session = Depends(database.get_db)):
    db_work = crud.get_work(db, work_id=work_id)
    if db_work is None:
        raise HTTPException(status_code=404, detail="Work entry not found")
    return db_work
