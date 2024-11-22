// src/api/apiClient.js
import axios from 'axios';

const apiClient = axios.create({
  baseURL: 'https://example.com/api', // 백엔드 API의 기본 URL
  timeout: 10000,                     // 요청 제한 시간 (ms)
  headers: {
    'Content-Type': 'application/json',
  },
});

// 요청 인터셉터
apiClient.interceptors.request.use(
  config => {
    // 필요시 토큰 추가
    const token = 'your-token'; // 실제로는 상태관리나 스토리지에서 가져와야 함
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  error => Promise.reject(error),
);

// 응답 인터셉터
apiClient.interceptors.response.use(
  response => response,
  error => Promise.reject(error),
);

export default apiClient;
