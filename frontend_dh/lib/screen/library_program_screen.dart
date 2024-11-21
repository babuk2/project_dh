import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LibraryProgramScreen extends StatefulWidget {
  @override
  _LibraryProgramScreenState createState() => _LibraryProgramScreenState();
}

class _LibraryProgramScreenState extends State<LibraryProgramScreen> {
  List<Map<String, String>> _programs = []; // 강좌 리스트
  bool _isLoading = false; // 로딩 상태

  // 서버에서 강좌 리스트 가져오기
  Future<void> _fetchPrograms() async {
    if (_isLoading) return; // 로딩 중이면 추가 호출 방지
    setState(() {
      _isLoading = true;
    });

    // 서버에서 강좌 데이터를 가져오는 HTTP GET 요청
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/library-program'), // API URL
    );

    if (response.statusCode == 200) {
      // 서버에서 받은 데이터를 UTF-8로 디코딩
      final String responseBody = utf8.decode(response.bodyBytes);

      // JSON 데이터를 List<Map<String, String>> 형태로 변환
      final List<dynamic> fetchedPrograms = json.decode(responseBody);

      setState(() {
        _programs.addAll(fetchedPrograms.map((program) {
          return {
            'title': program['title'] as String,
            'category': program['category'] as String,
            'registration_period': program['registration_period'] as String,
            'course_period': program['course_period'] as String,
            'course_time': program['course_time'] as String,
            'location': program['location'] as String,
            'instructor': program['instructor'] as String, // 강사 추가
            'capacity': program['capacity'] as String, // 정원 추가
            'status': program['status'] as String, // 접수상태 추가
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
    _fetchPrograms(); // 초기 데이터 로드
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('강좌 프로그램'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중일 때 로딩 표시
          : ListView.builder(
        itemCount: _programs.length, // 추가 로딩 없이 데이터만 표시
        itemBuilder: (context, index) {
          final program = _programs[index];

          return ListTile(
            title: Text(program['title']!), // 강좌 제목 표시
            subtitle: Text('${program['category']} - ${program['course_period']}'),
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(program['title']![0], style: TextStyle(color: Colors.white)),
            ),
            onTap: () {
              // 클릭 시 상세 정보 보기
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(program['title']!),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('강사: ${program['instructor']}'),
                        Text('정원: ${program['capacity']}명'),
                        Text('접수 상태: ${program['status']}'),
                        Text('등록 기간: ${program['registration_period']}'),
                        Text('수업 기간: ${program['course_period']}'),
                        Text('수업 시간: ${program['course_time']}'),
                        Text('장소: ${program['location']}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: Text('닫기'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
