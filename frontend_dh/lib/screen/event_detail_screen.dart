import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';

class EventDetailScreen extends StatefulWidget {
  final String postId; // 게시물 ID

  EventDetailScreen({required this.postId});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Map<String, String>? _postDetail; // 게시물 상세 정보
  bool _isLoading = true; // 로딩 상태

  // 서버에서 게시물 상세 정보를 가져오기
  Future<void> _fetchPostDetail() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/post-detail/${widget.postId}'), // 게시물 상세 API URL
    );

    if (response.statusCode == 200) {
      // 바이트 데이터를 UTF-8로 디코딩
      final String responseBody = utf8.decode(response.bodyBytes);

      final Map<String, dynamic> fetchedPost = json.decode(responseBody);
      setState(() {
        _postDetail = {
          'title': fetchedPost['title'],
          'content': fetchedPost['content'], // 상세 내용
          'img_url': fetchedPost['img_url'], // 이미지 URL
          'post_date': fetchedPost['post_date'],
        };
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상세 정보를 불러오는 데 실패했습니다.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPostDetail(); // 게시물 상세 데이터 불러오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('게시물 상세')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // SingleChildScrollView로 감싸서 스크롤 가능하게 함
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _postDetail!['title']!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8),
              Text('게시일: ${_postDetail!['post_date']}'),
              SizedBox(height: 16),
              Image.network(_postDetail!['img_url']!),
              SizedBox(height: 16),
              Html(  // HTML을 그대로 렌더링
                data: _postDetail!['content']!,  // HTML 내용을 data로 전달
              ),
            ],
          ),
        ),
      ),
    );
  }
}
