from fastapi import APIRouter, HTTPException
from bs4 import BeautifulSoup
import httpx
from datetime import datetime

router = APIRouter()

@router.get("/schedule-list")
async def fetch_schedule():
    # 현재 날짜에서 년월 추출
    current_date = datetime.now()
    year_month = current_date.strftime("%Y%m")

    # URL 설정
    base_url = "https://www.dh.go.kr/www/selectWebSchdulListMap.do"
    params = {
        "key": "486",
        "yyyymm": year_month
    }

    # 요청 보내기
    try:
        async with httpx.AsyncClient(verify=False) as client:
            response = await client.get(base_url, params=params)
            response.raise_for_status()
            html_content = response.text

        # HTML 파싱
        soup = BeautifulSoup(html_content, "html.parser")
        schedule_items = soup.select("li.schedule_item")
        
        # 필요한 데이터 추출
        schedule_list = []
        for item in schedule_items:
            category = item["data-category"]  # 행정/행사 구분
            date_start = item.find("button")["data-bgnde"]
            date_end = item.find("button")["data-endde"]
            time = item.find("button")["data-time"]
            place = item.find("button")["data-place"]
            subject = item.find("span", class_="subject").text.strip()
            schedule_type = item.find("span", class_="schedule_type").text.strip()

            # 행정과 행사 구분 (category 값에 기반)
            schedule_category = "행정" if "행정" in category else "행사"

            schedule_list.append({
                "category": schedule_category,  # 행정/행사 구분 정보 추가
                "date_start": date_start,
                "date_end": date_end,
                "time": time,
                "place": place,
                "subject": subject,
                "type": schedule_type,
            })
        
        return {"year_month": year_month, "schedules": schedule_list}

    except httpx.HTTPError as e:
        raise HTTPException(status_code=500, detail=f"Error fetching schedule: {e}")
