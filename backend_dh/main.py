from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse

from routers import naver , post_list , test , post_detail , batch_operations, schedule, library_program, pharmacies, naver_news


app = FastAPI()

# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인에서 요청을 허용
    allow_credentials=True,
    allow_methods=["*"],  # 모든 HTTP 메서드를 허용
    allow_headers=["*"],  # 모든 헤더를 허용
)
#라우터 등록
app.include_router(naver.router)
app.include_router(test.router)
app.include_router(post_list.router)
app.include_router(post_detail.router)
app.include_router(batch_operations.router)
app.include_router(schedule.router)
app.include_router(library_program.router)
app.include_router(pharmacies.router)
app.include_router(naver_news.router)

@app.get("/", response_class=HTMLResponse)
async def read_root():
    return """
    <html>
        <body>
            <h1>Welcome to the FastAPI server!</h1>
        </body>
    </html>
    """
