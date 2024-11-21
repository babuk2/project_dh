# routers/post_detail.py
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from schema.post import PostDetail  # Pydantic 모델 임포트
from core.crud import get_post_detail_from_db  # CRUD 함수 임포트
from core.database import get_db  # DB 세션 임포트

router = APIRouter()

@router.get("/post-detail/{post_id}", response_model=PostDetail)
async def get_post_detail(post_id: int, db: Session = Depends(get_db)):
    post = get_post_detail_from_db(db, post_id)
    
    if not post:
        raise HTTPException(status_code=404, detail="Post not found")
    
    return post
