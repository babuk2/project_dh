import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class PharmaciesScreen extends StatefulWidget {
  @override
  _PharmaciesScreenState createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  List<Map<String, String>> _pharmacies = []; // 약국 리스트
  bool _isLoading = false; // 로딩 상태

  // 현재 시간을 기반으로 영업중인지 판단하는 함수
  bool _isOpen(String openTime, String closeTime) {
    final now = DateTime.now();
    final currentTime = DateFormat('HH:mm').format(now);

    // 현재 시간이 영업시간 사이에 있으면 영업중
    return openTime.compareTo(currentTime) <= 0 && closeTime.compareTo(currentTime) >= 0;
  }

  // 서버에서 약국 리스트 가져오기
  Future<void> _fetchPharmacies() async {
    if (_isLoading) return; // 로딩 중이면 추가 호출 방지
    setState(() {
      _isLoading = true;
    });

    // 서버에서 약국 데이터를 가져오는 HTTP GET 요청
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/pharmacies'), // API URL
    );

    if (response.statusCode == 200) {
      // 서버에서 받은 데이터를 UTF-8로 디코딩
      final String responseBody = utf8.decode(response.bodyBytes);

      // JSON 데이터를 List<Map<String, String>> 형태로 변환
      final Map<String, dynamic> fetchedData = json.decode(responseBody);
      final List<dynamic> fetchedPharmacies = fetchedData['pharmacies'];

      setState(() {
        _pharmacies.addAll(fetchedPharmacies.map((pharmacy) {
          return {
            'name': pharmacy['name'] as String,
            'address': pharmacy['address'] as String,
            'phone_number': pharmacy['phone_number'] as String,
            'status': _isOpen(pharmacy['open_time'], pharmacy['close_time']) ? '영업중' : '영업종료',
            'open_time': pharmacy['open_time'] as String,
            'close_time': pharmacy['close_time'] as String,
          };
        }).toList());

        // 영업중인 약국 우선 정렬 후, 가나다 순 정렬
        _pharmacies.sort((a, b) {
          int statusComparison = b['status']!.compareTo(a['status']!); // 영업중이 먼저 오도록 정렬
          if (statusComparison != 0) return statusComparison;
          return a['name']!.compareTo(b['name']!); // 그 후 이름 순으로 정렬
        });

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
    _fetchPharmacies(); // 초기 데이터 로드
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('약국 리스트'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중일 때 로딩 표시
          : ListView.builder(
        itemCount: _pharmacies.length, // 리스트의 항목 개수
        itemBuilder: (context, index) {
          final pharmacy = _pharmacies[index];

          // 영업 중인지 아닌지에 따라 색상 설정
          final statusColor = pharmacy['status'] == '영업중' ? Colors.green : Colors.grey;

          return ListTile(
            title: Text(pharmacy['name']!), // 약국 이름 표시
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${pharmacy['address']}'),
                // open_time과 close_time이 null이 아닐 때만 표시
                if (pharmacy['open_time'] != null && pharmacy['close_time'] != null)
                  Text('${pharmacy['open_time']} ~ ${pharmacy['close_time']}'),
              ],
            ),
            leading: CircleAvatar(
              backgroundColor: statusColor,
              child: Text(
                pharmacy['status'] == '영업중' ? '운영' : '종료',  // '영업중' 또는 '영업종료' 표시
                style: TextStyle(color: Colors.white),
              ),
            ),
            onTap: () {
              // 클릭 시 상세 정보 보기
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(pharmacy['name']!),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('주소: ${pharmacy['address']}'),
                        Text('전화번호: ${pharmacy['phone_number']}'),
                        Text('상태: ${pharmacy['status']}'),
                        if (pharmacy['open_time'] != null && pharmacy['close_time'] != null)
                          Text('영업시간: ${pharmacy['open_time']} - ${pharmacy['close_time']}'),
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
