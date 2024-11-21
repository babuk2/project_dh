# core/crud.py
from sqlalchemy.orm import Session
from schema.post import PostCreate
from model.post import Post



# 크롤링 게시물 저장 함수
def save_post_to_db(db: Session, post_data: PostCreate):
    db_post = Post(
        title=post_data.title,
        link=post_data.link,
        img_url=post_data.img_url,
        post_date=post_data.post_date,
        content=post_data.content
    )
    db.add(db_post)
    db.commit()
    db.refresh(db_post)
    return db_post

# 게시물 리스트 조회
def get_post_list_from_db(db: Session, skip: int = 0, limit: int = 10):
    result = db.query(Post.post_id, Post.title, Post.img_url, Post.post_date, Post.link).\
        order_by(Post.post_date.desc()).\
        offset(skip).\
        limit(limit).\
        all()
    return result

        
# 게시물 상세 조회
def get_post_detail_from_db(db: Session, post_id: int):
    return db.query(Post).filter(Post.post_id == post_id).first()
