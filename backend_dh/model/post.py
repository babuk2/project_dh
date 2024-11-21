# model/post.py
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from model import Base

class Post(Base):
    __tablename__ = "POSTS"

    post_id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    link = Column(String)
    img_url = Column(String)
    post_date = Column(String)  # 'date' -> 'post_date'로 수정
    content = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
