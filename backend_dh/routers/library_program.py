from fastapi import APIRouter
from pydantic import BaseModel
import httpx  # 비동기 HTTP 클라이언트
from bs4 import BeautifulSoup
from typing import List

router = APIRouter()

# 강좌 정보를 담을 Pydantic 모델
class Lecture(BaseModel):
    title: str
    category: str
    registration_period: str
    course_period: str
    course_time: str
    location: str
    instructor: str  # 강사
    capacity: str  # 정원
    status: str  # 접수상태

# 새로운 엔드포인트: /library-program
@router.get("/library-program", response_model=List[Lecture])
async def get_library_program():
    url = "https://www.donghaelib.go.kr/web/menu/10027/program/30010/lectureList.do?manageCd=&year=&searchCategory=&searchStatusCd=finish&searchCondition=title&searchKeyword="
    
    # httpx를 사용하여 비동기적으로 요청
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
    
    soup = BeautifulSoup(response.text, 'html.parser')

    # 강좌 목록 추출
    lecture_items = soup.find_all('div', class_='article-item')
    lectures = []

    for item in lecture_items:
        title = item.find('a', class_='title').text.strip()
        category = item.find('span', class_='lib MB').text.strip()
        
        # 강좌 정보가 담긴 p 태그를 모두 추출
        paragraphs = item.find_all('p')
        registration_period = paragraphs[0].text.strip() if len(paragraphs) > 0 else "N/A"
        course_period = paragraphs[1].text.strip() if len(paragraphs) > 1 else "N/A"
        course_time = paragraphs[2].text.strip() if len(paragraphs) > 2 else "N/A"
        location = paragraphs[3].text.strip() if len(paragraphs) > 3 else "N/A"
        
        # 추가 정보: 강사, 정원, 접수상태 - 클래스명이 정확한지 확인하여 수정
        instructor = item.find('span', class_='instructor')
        instructor = instructor.text.strip() if instructor else "N/A"

        capacity = item.find('span', class_='capacity')
        capacity = capacity.text.strip() if capacity else "N/A"

        status = item.find('span', class_='status')
        status = status.text.strip() if status else "N/A"

        # Lecture 모델에 데이터 추가
        lecture = Lecture(
            title=title,
            category=category,
            registration_period=registration_period,
            course_period=course_period,
            course_time=course_time,
            location=location,
            instructor=instructor,
            capacity=capacity,
            status=status
        )
        lectures.append(lecture)

    return lectures
