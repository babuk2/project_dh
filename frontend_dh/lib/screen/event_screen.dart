import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'event_detail_screen.dart'; // EventDetailScreen 임포트

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> _posts = []; // 게시물 리스트
  bool _isLoading = false; // 로딩 상태
  int _page = 1; // 페이지 번호

  // 서버에서 게시물 리스트 가져오기
  Future<void> _fetchPosts() async {
    if (_isLoading) return; // 로딩 중일 때 추가 호출 방지
    setState(() {
      _isLoading = true;
    });

    // 서버에서 게시물 데이터를 가져오는 HTTP GET 요청
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/post-list'), // API URL
    );

    if (response.statusCode == 200) {
      // 서버에서 받은 바이트 데이터를 UTF-8로 디코딩
      final String responseBody = utf8.decode(response.bodyBytes);

      // 서버에서 받은 JSON 데이터를 List<Map<String, String>> 형식으로 변환
      final List<dynamic> fetchedPosts = json.decode(responseBody);

      // 데이터 처리
      setState(() {
        // API에서 받은 데이터를 _posts에 추가
        _posts.addAll(fetchedPosts.map((post) {
          return {
            'post_id': post['post_id'].toString(), // 게시물 ID
            'title': post['title'] as String,
            'img_url': post['img_url'] as String,
            'post_date': post['post_date'] as String,
          };
        }).toList());

        _isLoading = false;
        _page++; // 페이지 증가
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

  // 스크롤이 끝에 도달하면 데이터 추가 호출
  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _fetchPosts(); // 끝에 도달하면 추가 데이터 로드
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchPosts(); // 초기 데이터 불러오기
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length + 1, // 마지막에 로딩 인디케이터 추가
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            // 마지막 아이템일 경우 로딩 인디케이터 표시
            return _isLoading ? Center(child: CircularProgressIndicator()) : SizedBox();
          }
          final post = _posts[index];
          return ListTile(
            title: Text(post['title']!),
            subtitle: Text(post['post_date']!),
            leading: Image.network(
              post['img_url']!,
              width: 60,  // 고정된 너비
              height: 60, // 고정된 높이
              fit: BoxFit.cover,  // 이미지를 잘라서 채우기
              errorBuilder: (context, error, stackTrace) {
                // 이미지 로딩 에러가 발생하면 대체 이미지 표시
                return Image.network(
                  'https://postfiles.pstatic.net/MjAyNDA5MjlfOTMg/MDAxNzI3NTgzMjMzNzIz.TWsWEDvdbX76lj7soy3KmWUkRKosUAkzrfS9bQKcVRog.K84d0yyg6eCYkMBaknaQXsRkMjnEn0aofzVn_zK0s9Ug.JPEG/IMG_1716.JPG',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error); // 에러가 나면 에러 아이콘 표시
                  },
                );

              },
            ),
            onTap: () {
              // 게시물 클릭 시 상세 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(postId: post['post_id']!), // ID 전달
                ),
              );
            },
          );
        },
      ),
    );
  }
}
