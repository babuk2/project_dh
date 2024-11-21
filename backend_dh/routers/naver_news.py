
import urllib.request
from fastapi import APIRouter
import json
import os
from fastapi.responses import JSONResponse

router = APIRouter()

@router.get("/naver-news")
def get_naverNews():
    search_keyword = '동해시'
    
    # 클라이언트 아이디와 시크릿을 환경 변수로 처리 (보안상 안전)
    client_id = os.getenv("NAVER_CLIENT_ID", "9RgyEWQTD4NUJFPuFYbU")  
    client_secret = os.getenv("NAVER_CLIENT_SECRET", "7GjGYzrpV0")

    if not client_id or not client_secret:
        return JSONResponse(status_code=400, content={"error": "Missing Naver API credentials"})
    
    encText = urllib.parse.quote(search_keyword)

    # 테스트용 첫 페이지만 가져오기
    url = f"https://openapi.naver.com/v1/search/news.json?query={encText}&start=1&display=100"

    request = urllib.request.Request(url)
    request.add_header("X-Naver-Client-Id", client_id)
    request.add_header("X-Naver-Client-Secret", client_secret)

    try:
        response = urllib.request.urlopen(request)
        rescode = response.getcode()

        if rescode == 200:
            response_body = response.read()
            response_result = response_body.decode('utf-8')
            response_result = json.loads(response_result)
            return response_result  # 프론트엔드로 결과 반환
        else:
            return JSONResponse(status_code=rescode, content={"error": f"Error Code: {rescode}"})

    except urllib.error.URLError as e:
        return JSONResponse(status_code=500, content={"error": f"Request failed: {e}"})
