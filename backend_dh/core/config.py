import os
from dotenv import load_dotenv
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordBearer

# .env 파일에서 환경 변수를 로드합니다.
load_dotenv()

#MONGO DB 연결 정보
MONGODB_URI = os.getenv("MONGODB_URI", "mongodb+srv://babuk:gjqackMpbzO5Qxos@wnp001.1oip4.mongodb.net/?retryWrites=true&w=majority&appName=WNP001")  # 
MONGODB_DB_NAME = os.getenv("MONGODB_DB_NAME", "work")  # 

#ORACLE DB 연결 정보
DB_USER = os.getenv("DB_USER", "admin")  # 기본값으로 "admin" 사용
DB_PASSWORD = os.getenv("DB_PASSWORD", "Monochrome*8from")  # 기본값으로 비밀번호 사용
DB_DSN = os.getenv("DB_DSN", "radarchive_high")  # 기본값으로 DSN 사용

# Oracle Client 경로 설정 (여기서는 하드코딩)
ORACLE_CLIENT_PATH = r"C:\Users\tetro\Desktop\Oracle\instantclient_21_13"

class Settings:
    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_DSN = os.getenv("DB_DSN")
    SECRET_KEY = os.getenv("SECRET_KEY")
    ALGORITHM = os.getenv("ALGORITHM")
    ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 30))
    pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
    # OAuth2PasswordBearer를 사용해 토큰 URL 설정
    oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")  # 로그인 엔드포인트
    
settings = Settings()  # 인스턴스를 생성하여 사용
