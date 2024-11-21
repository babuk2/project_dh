import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/festival.dart';

class CombinedScreen extends StatefulWidget {
  @override
  _CombinedScreenState createState() => _CombinedScreenState();
}

class _CombinedScreenState extends State<CombinedScreen> {
  List<Festival> festivals = [
    Festival(
      title: '동해항 크랩킹페스타',
      subtitle: '행사종료',
      date: '2024년 4월12일(금)~4월15일(월)',
      link: 'http://dhfesta.or.kr/dckf',
      imageUrl: 'https://i.postimg.cc/rsSz755L/image.png',
    ),
    Festival(
      title: '무릉별유천지 라벤더축제',
      subtitle: '행사종료',
      date: '2024년 6월8일(토) ~ 23일(일)',
      link: 'http://dhfesta.or.kr/dhlf',
      imageUrl: 'https://i.postimg.cc/gj9nMgXD/image.png',
    ),
    Festival(
      title: '묵호 도째비페스타',
      subtitle: '행사종료',
      date: '2024년 7월19일(금)~ 21일(일)',
      link: 'http://dhfesta.or.kr/dmdf',
      imageUrl: 'https://i.postimg.cc/qR6NXPRq/image.png',
    ),
    Festival(
      title: '동해 무릉제',
      subtitle: '행사종료',
      date: '2024년 9월 26일(목)~29일(일)',
      link: 'http://dhfesta.or.kr/dmrf',
      imageUrl: 'https://i.postimg.cc/3x90KjV8/image.png',
    ),
  ];

  List<Map<String, String>> _schedules = []; // 스케줄 리스트
  bool _isLoading = false; // 로딩 상태

  // 서버에서 스케줄 리스트 가져오기
  Future<void> _fetchSchedules() async {
    if (_isLoading) return; // 로딩 중이면 추가 호출 방지
    setState(() {
      _isLoading = true;
    });

    // 서버에서 스케줄 데이터를 가져오는 HTTP GET 요청
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/schedule-list'), // API URL
    );

    if (response.statusCode == 200) {
      // 서버에서 받은 데이터를 UTF-8로 디코딩
      final String responseBody = utf8.decode(response.bodyBytes);

      // JSON 데이터를 List<Map<String, String>> 형태로 변환
      final Map<String, dynamic> fetchedData = json.decode(responseBody);
      final List<dynamic> fetchedSchedules = fetchedData['schedules'];

      setState(() {
        _schedules.addAll(fetchedSchedules.map((schedule) {
          return {
            'category': schedule['category'] as String,
            'date_start': schedule['date_start'] as String,
            'date_end': schedule['date_end'] as String,
            'time': schedule['time'] as String,
            'place': schedule['place'] as String,
            'subject': schedule['subject'] as String,
            'type': schedule['type'] as String,
          };
        }).toList());
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는 데 실패했습니다.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSchedules(); // 초기 데이터 로드
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 축제 카드 목록
          LayoutBuilder(
            builder: (context, constraints) {
              double itemWidth = constraints.maxWidth > 980 ? 480 : constraints.maxWidth / 2;

              return GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 두 개의 항목을 한 줄에 배치
                  crossAxisSpacing: 8, // 항목 간 간격
                  mainAxisSpacing: 8, // 항목 간 세로 간격
                  childAspectRatio: 2.5, // 비율 조정
                ),
                itemCount: festivals.length,
                itemBuilder: (context, index) {
                  final festival = festivals[index];

                  return Card(
                    margin: EdgeInsets.zero, // 카드 간격 제거
                    elevation: 4, // 카드 그림자
                    child: Stack(
                      children: [
                        // 배경 이미지
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(festival.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => launchURL(festival.link), // 링크 열기
                                child: Text(
                                  festival.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,

                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                festival.subtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                festival.date,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // 스케줄 목록
          Expanded(
            child: ListView.builder(
              itemCount: _schedules.length,
              itemBuilder: (context, index) {
                final schedule = _schedules[index];

                return ListTile(
                  title: Text(schedule['subject']!),
                  subtitle: Text('${schedule['date_start']} ~ ${schedule['date_end']} - ${schedule['place']}'),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(schedule['date_start']!.split('-')[2], style: TextStyle(color: Colors.white)),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('스케줄: ${schedule['subject']}')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // URL 열기 함수
  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
