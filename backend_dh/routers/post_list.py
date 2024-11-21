# routers/post_list.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from core.database import get_db
from schema.post import PostList
from core.crud import get_post_list_from_db

router = APIRouter()

# routers/post_list.py
@router.get("/post-list", response_model=List[PostList])
async def get_posts(skip: int = 0, limit: int = 20, db: Session = Depends(get_db)):
    # DB에서 게시물들을 최신일자(post_date 기준 내림차순)로 조회
    posts = get_post_list_from_db(db, skip, limit)
    
    if not posts:
        raise HTTPException(status_code=404, detail="No posts found")
    
    return posts
