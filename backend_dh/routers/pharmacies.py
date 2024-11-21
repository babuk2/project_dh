from fastapi import APIRouter
import requests
import xmltodict
from fastapi.responses import JSONResponse
from datetime import datetime

router = APIRouter()

@router.get("/pharmacies")
def get_pharmacies():
    url = 'http://apis.data.go.kr/B552657/ErmctInsttInfoInqireService/getParmacyListInfoInqire'
    params = {
        'serviceKey': 'AqY7NHy8gn1ROMIJWrGmm/88icACyjAmgAILkaaEobA8fXaertUF4eWXC1pD+qUo7JZYA4T5Ec3Z5bbD5tK8pA==',
        'Q0': '강원특별자치도',
        'Q1': '동해시',
        'ORD': 'NAME',
        'pageNo': '1',
        'numOfRows': '10'
    }

    # API 요청
    response = requests.get(url, params=params)

    # XML -> JSON 변환
    if response.status_code == 200:
        xml_data = response.content
        json_data = xmltodict.parse(xml_data)  # XML을 파싱하여 JSON으로 변환

        # 공공데이터에서 약국 정보 추출
        pharmacies = json_data.get('response', {}).get('body', {}).get('items', {}).get('item', [])

        # 현재 날짜와 요일 가져오기
        current_day = datetime.now().weekday()  # 월요일=0, 일요일=6
        today = datetime.now().strftime('%Y-%m-%d')

        result_pharmacies = []

        # 각 약국에 대해 영업 중인지 확인
        for pharmacy in pharmacies:
            # 약국의 기본 정보
            duty_name = pharmacy.get('dutyName', 'N/A')
            duty_addr = pharmacy.get('dutyAddr', 'N/A')
            duty_tel = pharmacy.get('dutyTel1', 'N/A')

            # 각 요일별 영업 시간
            duty_time = {
                'Monday': {'open': pharmacy.get('dutyTime1s'), 'close': pharmacy.get('dutyTime1c')},
                'Tuesday': {'open': pharmacy.get('dutyTime2s'), 'close': pharmacy.get('dutyTime2c')},
                'Wednesday': {'open': pharmacy.get('dutyTime3s'), 'close': pharmacy.get('dutyTime3c')},
                'Thursday': {'open': pharmacy.get('dutyTime4s'), 'close': pharmacy.get('dutyTime4c')},
                'Friday': {'open': pharmacy.get('dutyTime5s'), 'close': pharmacy.get('dutyTime5c')},
                'Saturday': {'open': pharmacy.get('dutyTime6s'), 'close': pharmacy.get('dutyTime6c')},
                'Sunday': {'open': pharmacy.get('dutyTime7s'), 'close': pharmacy.get('dutyTime7c')},
                'Holiday': {'open': pharmacy.get('dutyTime8s'), 'close': pharmacy.get('dutyTime8c')}
            }

            # 해당 요일의 영업 여부 판단
            status = "영업중" if duty_time[list(duty_time.keys())[current_day]]['open'] else "영업종료"
            
            # 오늘 영업 중인 경우
            if status == "영업중":
                today_open = duty_time[list(duty_time.keys())[current_day]]['open']
                today_close = duty_time[list(duty_time.keys())[current_day]]['close']
            else:
                today_open = today_close = ''

            # 약국 정보 저장
            result_pharmacies.append({
                'name': duty_name,
                'address': duty_addr,
                'phone_number': duty_tel,
                'status': status,
                'open_time': today_open,
                'close_time': today_close,
                'today': today
            })

        return JSONResponse(content={'pharmacies': result_pharmacies})
    else:
        return {"error": "Failed to fetch data from the API"}
