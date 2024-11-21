import cx_Oracle
from fastapi import HTTPException
from typing import Generator
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from .config import DB_USER, DB_PASSWORD, DB_DSN, ORACLE_CLIENT_PATH,MONGODB_URI, MONGODB_DB_NAME
from motor.motor_asyncio import AsyncIOMotorClient

# MongoDB 클라이언트 생성
mongo_client = AsyncIOMotorClient(MONGODB_URI)
mongodb = mongo_client[MONGODB_DB_NAME]

# 의존성 주입을 위한 함수
def get_mongo_db():
    return mongodb


# Oracle Client의 경로 설정
cx_Oracle.init_oracle_client(lib_dir=ORACLE_CLIENT_PATH)

# SQLAlchemy 엔진과 세션 만들기
DATABASE_URL = f"oracle+cx_oracle://{DB_USER}:{DB_PASSWORD}@{DB_DSN}"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()  # Base 정의

def get_db() -> Generator[SessionLocal, None, None]:  # type: ignore
    db = SessionLocal()
    try:
        yield db
    except Exception as e:
        print(f"Database operation failed: {e}")
        raise HTTPException(status_code=500, detail="Database operation failed")
    finally:
        db.close()
