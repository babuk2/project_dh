from datetime import datetime
import httpx
from bs4 import BeautifulSoup
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from core.database import get_db
from schema.post import PostCreate
from core.crud import save_post_to_db
from model.post import Post

router = APIRouter()

base_url = "https://blog.naver.com/PostList.naver?from=postList&blogId=sunrisectdh&categoryNo=13&currentPage="

# 게시물 필터링을 위한 조건
def is_valid_post(title: str, date: str) -> bool:
    current_year = str(datetime.now().year)
    return current_year in date and ('축제' in title or '도시재생' in title and '캘린더' not in title)

# 날짜 형식 처리
def format_date(raw_date: str) -> str:
    today = datetime.now().strftime("%Y-%m-%d")
    try:
        # yyyy-mm-dd 형식인지 확인
        datetime.strptime(raw_date, "%Y-%m-%d")
        return raw_date
    except ValueError:
        # '몇 분 전', '몇 시간 전' 같은 경우 오늘 날짜 반환
        return today

import re  # 정규식을 위한 모듈

# 날짜 형식 처리
def format_date(raw_date: str) -> str:
    today = datetime.now().strftime("%Y%m%d")
    
    # 특수문자 제거
    clean_date = re.sub(r"[^0-9\-]", "", raw_date)
    
    # yyyy-mm-dd 형식 확인
    try:
        date_obj = datetime.strptime(clean_date, "%Y%m%d")
        return date_obj.strftime("%Y%m%d")
    except ValueError:
        # 날짜 형식이 아닌 경우 오늘 날짜 반환
        return today

@router.get("/naver")
async def scrape_posts(db: Session = Depends(get_db)):
    posts = []
    new_posts_count = 0  # 새로 입력된 건수
    duplicate_count = 0  # 중복 건수

    async with httpx.AsyncClient() as client:
        for page_num in range(1, 11):
            url = base_url + str(page_num)
            headers = {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
            }
            response = await client.get(url, headers=headers)

            if response.status_code == 200:
                soup = BeautifulSoup(response.text, 'html.parser')
                post_list = soup.select('.thumblist .item')

                for post in post_list:
                    try:
                        title = post.select_one('.title').text.strip()
                        raw_date = post.select_one('.date').text.strip()
                        date = format_date(raw_date)  # 날짜 포맷 처리
                        link = post.select_one('a')['href']

                        # 상대 URL을 절대 URL로 변환
                        base_url_naver = "https://blog.naver.com"
                        if not link.startswith('http'):
                            link = base_url_naver + link  # 상대 경로를 절대 경로로 변환

                        img_tag = post.select_one('.thumb')
                        img_url = img_tag['src'] if img_tag and img_tag.get('src') else 'https://ssl.pstatic.net/static/blog/no_image2.svg'

                        # 중복 검사
                        existing_post = db.query(Post).filter_by(title=title, post_date=date).first()
                        if existing_post:
                            duplicate_count += 1  # 중복 건수 증가
                            print(f"중복된 게시물: {title} - {date}")
                            continue  # 중복이면 저장하지 않음

                        # 게시물 본문 내용 가져오기
                        post_content_response = await client.get(link, headers=headers)
                        post_content_soup = BeautifulSoup(post_content_response.text, 'html.parser')

                        # <br> 태그를 유지한 상태로 내용 가져오기
                        content = post_content_soup.select_one('.se-main-container')
                        if content:
                            content_html = str(content)  # 전체 HTML로 가져오기
                        else:
                            content_html = ""  # 내용이 없으면 빈 문자열

                        # 네이버 크롤링 코드 수정
                        post_info = {
                            "title": title,
                            "link": link,
                            "img_url": img_url,
                            "post_date": date,
                            "content": content_html
                        }

                        # 스키마로 변환 후 DB 저장
                        post_data = PostCreate(**post_info)
                        save_post_to_db(db, post_data)
                        new_posts_count += 1  # 새로 입력된 건수 증가
                        posts.append(post_info)

                    except Exception as e:
                        print(f"크롤링 중 오류 발생: {e}")

    # 최종 결과 출력
    print(f"새로 입력된 게시물 건수: {new_posts_count}")
    print(f"중복된 게시물 건수: {duplicate_count}")

    return posts

