import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';  // JSON 디코딩을 위한 패키지
import 'package:intl/intl.dart';  // 날짜 포맷팅을 위한 패키지
import 'package:url_launcher/url_launcher.dart';  // url_launcher 임포트
import 'package:flutter_tts/flutter_tts.dart';  // flutter_tts 임포트

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _newsItems = [];  // API에서 받은 뉴스 데이터를 저장할 리스트
  FlutterTts _flutterTts = FlutterTts();  // FlutterTts 객체
  bool _isSpeaking = false;  // 음성을 읽고 있는지 여부
  String _currentText = "";  // 현재 읽고 있는 텍스트

  // 데이터 가져오기
  Future<void> _fetchNews() async {
    final response = await http.get(Uri.parse('http://localhost:8000/naver-news'));

    if (response.statusCode == 200) {
      // UTF-8로 응답 본문을 디코딩
      final data = json.decode(utf8.decode(response.bodyBytes));  // bodyBytes를 UTF-8로 디코딩
      setState(() {
        _newsItems = List<Map<String, dynamic>>.from(data['items']);
      });
    } else {
      throw Exception('Failed to load news');
    }
  }

  // HTML 태그 및 특수문자 제거 함수
  String removeHtmlTags(String text) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    String cleanedText = text.replaceAll(exp, '');  // <b></b> 태그를 포함한 모든 HTML 태그 제거

    // 특수문자 및 괄호 제거
    cleanedText = cleanedText.replaceAll(RegExp(r'[\(\)\[\]\{\}\<\>\$\%\^\&\*\+\=]'), '');
    return cleanedText;  // 특수문자 및 괄호 제거 후 반환
  }

  // 날짜 포맷팅 함수
  String formatDate(String pubDate) {
    // 날짜 형식을 파싱할 때 사용할 패턴 정의
    DateTime dateTime = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z").parse(pubDate);

    // 원하는 형식으로 변환하여 반환
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
  }

  // 텍스트 읽기 시작
  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();  // 일시정지된 경우 중지
      setState(() {
        _isSpeaking = false;
      });
    } else {
      await _flutterTts.setLanguage("ko-KR");  // 한국어로 설정
      await _flutterTts.speak(text);  // 텍스트 읽기 시작
      setState(() {
        _isSpeaking = true;
        _currentText = text;
      });
    }
  }

  // 앱 상태 변화 시 호출되는 메서드 (앱이 백그라운드로 갔다가 돌아오거나 화면이 변할 때 처리)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // 앱이 백그라운드로 이동하거나 비활성화될 때 TTS 멈추기
      if (_isSpeaking) {
        _flutterTts.stop();  // TTS 중지
        setState(() {
          _isSpeaking = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("ko-KR");  // 한국어로 설정
    _flutterTts.setVoice({"name": "ko-KR-male", "locale": "ko-KR"});  // 한국어 남성 목소리 설정
    _fetchNews();  // 화면이 처음 로드될 때 뉴스 데이터를 가져옵니다.
    WidgetsBinding.instance.addObserver(this);  // 상태 변화 관찰
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);  // 상태 변화 관찰 해제
    super.dispose();
  }

  // URL을 외부 브라우저로 여는 함수
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 첫 번째 영역: 동해시 관련 뉴스
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '동해시 관련 뉴스',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(_isSpeaking ? Icons.pause : Icons.play_arrow),  // 일시정지/재생 아이콘 변경
                  onPressed: () {
                    // 재생/일시정지 버튼 클릭 시 텍스트 읽기 기능 토글
                    String textToRead = '';
                    for (var item in _newsItems) {
                      textToRead += removeHtmlTags(item["title"]) + '\n'; // 제목을 읽음
                      textToRead += removeHtmlTags(item["description"]) + '\n'; // 설명을 읽음
                    }
                    _speak(textToRead);  // 텍스트 읽기 시작
                  },
                ),
              ],
            ),
          ),

          // 뉴스 항목 리스트
          Expanded(
            child: _newsItems.isEmpty
                ? Center(child: CircularProgressIndicator())  // 데이터가 로드되지 않았으면 로딩 인디케이터 표시
                : ListView.builder(
              itemCount: _newsItems.length,
              itemBuilder: (context, index) {
                var item = _newsItems[index];
                String formattedDate = formatDate(item["pubDate"]);
                String title = removeHtmlTags(item["title"]);
                String description = removeHtmlTags(item["description"]);

                return ListTile(
                  title: InkWell(
                    onTap: () {
                      // 뉴스 제목 클릭 시 링크로 이동
                      print("Opening link: ${item['link']}");
                    },
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formattedDate), // 날짜 표시
                      SizedBox(height: 8),
                      // 숨겨진 description (사용자에게는 보이지 않지만 데이터를 처리)
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 0,  // 크기를 0으로 설정하여 보이지 않게 함
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // 뉴스 제목 클릭 시 링크 열기
                    _launchURL(item['link']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
