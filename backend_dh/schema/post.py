from pydantic import BaseModel
from datetime import datetime

class PostCreate(BaseModel):
    title: str
    link: str
    img_url: str
    post_date: str  # 'date' -> 'post_date'
    content: str

    class Config:
        from_attributes = True

class PostList(BaseModel):
    post_id: int  # 프론트엔드에서 post_id로 사용
    title: str
    link: str
    img_url: str
    post_date: str

    class Config:
        from_attributes = True
        orm_mode = True  # SQLAlchemy 모델을 Pydantic 모델로 변환할 수 있도록 설정

class PostDetail(BaseModel):
    post_id: int
    title: str
    link: str
    img_url: str
    post_date: str
    content: str

    class Config:
        from_attributes = True
        orm_mode = True  # SQLAlchemy 모델을 Pydantic 모델로 변환할 수 있도록 설정
