from fastapi import FastAPI, File, UploadFile
from fastapi.responses import HTMLResponse
import os
from bs4 import BeautifulSoup

app = FastAPI()

# HTML 파일 업로드를 위한 경로 설정
UPLOAD_DIR = "uploaded_html_files"

# 업로드된 파일을 저장할 폴더가 없으면 생성
if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)

@app.get("/", response_class=HTMLResponse)
async def read_html_form():
    html_content = """
    <html>
        <body>
            <h2>HTML 파일 업로드</h2>
            <form action="/upload/" method="post" enctype="multipart/form-data">
                <input type="file" name="file" accept=".html">
                <input type="submit">
            </form>
        </body>
    </html>
    """
    return html_content

@app.post("/upload/")
async def upload_file(file: UploadFile = File(...)):
    # 파일 저장 경로 설정
    file_location = os.path.join(UPLOAD_DIR, file.filename)
    
    with open(file_location, "wb") as f:
        f.write(file.file.read())

    # HTML 파일을 처리하여 결과를 추출
    with open(file_location, 'r', encoding='utf-8') as f:
        html_content = f.read()
    
    # BeautifulSoup을 이용한 HTML 파싱
    soup = BeautifulSoup(html_content, 'html.parser')
    
    # 테이블 내의 텍스트만 추출하여 tr 별로 줄바꿈을 추가
    table_data = []
    for row in soup.find_all('tr'):
        row_data = []
        for td in row.find_all('td'):
            text = td.get_text(strip=True)
            if text:  # 빈 문자열이 아닌 경우에만
                row_data.append(f"'{text}'")
        if row_data:
            table_data.append(", ".join(row_data))

    # 결과 출력 (줄바꿈 추가)
    result = "\n".join(table_data)
    
    return HTMLResponse(content=f"""
    <html>
        <body>
            <h2>파일 처리 결과</h2>
            <p><strong>업로드된 HTML 파일:</strong> {file.filename}</p>
            <p><strong>테이블 데이터 (포맷된 결과):</strong></p>
            <pre>{result}</pre>
        </body>
    </html>
    """)
