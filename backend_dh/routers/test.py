from fastapi import APIRouter
import requests
import xmltodict
from fastapi.responses import JSONResponse

router = APIRouter()

@router.get("/test-db")
def test_db_connection():
    url = 'http://apis.data.go.kr/B552657/ErmctInsttInfoInqireService/getParmacyListInfoInqire'
    params = {
        'serviceKey' : 'AqY7NHy8gn1ROMIJWrGmm/88icACyjAmgAILkaaEobA8fXaertUF4eWXC1pD+qUo7JZYA4T5Ec3Z5bbD5tK8pA==',
        'Q0' : '강원특별자치도',
        'Q1' : '동해시',
        'ORD' : 'NAME',
        'pageNo' : '1',
        'numOfRows' : '10'
    }

    # API 요청
    response = requests.get(url, params=params)
    
    # XML -> JSON 변환
    if response.status_code == 200:
        xml_data = response.content
        json_data = xmltodict.parse(xml_data)  # XML을 파싱하여 JSON으로 변환

        # 반환된 JSON 데이터 확인
        return JSONResponse(content=json_data)  # JSONResponse로 반환
    else:
        return {"error": "Failed to fetch data from the API"}

