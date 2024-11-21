import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
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
      body: ListView.builder(
        itemCount: _schedules.length, // 추가 로딩 없이 데이터만 표시
        itemBuilder: (context, index) {
          final schedule = _schedules[index];

          // 'date_start'에서 일별 정보만 가져오기 (예: "2024-11-02"에서 "02"만 가져오기)
          String day = schedule['date_start']?.split('-')[2] ?? '';

          // 행사 여부에 따른 배경색 설정
          Color backgroundColor = schedule['type'] == '행사' ? Colors.blue : Colors.grey;

          return ListTile(
            title: Text(schedule['subject']!), // 제목 표시
            subtitle: Text('${schedule['date_start']} ~ ${schedule['date_end']} - ${schedule['place']}'),
            leading: CircleAvatar(
              backgroundColor: backgroundColor,
              child: Text(day, style: TextStyle(color: Colors.white)),
            ), // 날짜를 동그라미로 표시
            onTap: () {
              // 클릭 시 상세 정보 보기 (임시 처리)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('스케줄: ${schedule['subject']}')),
              );
            },
          );
        },
      ),
    );
  }
}
