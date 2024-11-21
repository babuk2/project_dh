import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/festival.dart'; // URL 열기 위한 패키지

class FestivalScreen extends StatelessWidget {
  final List<Festival> festivals = [
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

  @override
  Widget build(BuildContext context) {
    // 화면 크기 비례 계산
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 텍스트 크기 계산 (화면 크기에 비례하여 크기 조정)
    double titleFontSize = screenWidth * 0.04; // 화면 너비의 5% 크기
    double subtitleFontSize = screenWidth * 0.03; // 화면 너비의 4% 크기
    double dateFontSize = screenWidth * 0.03; // 화면 너비의 3% 크기

    return Scaffold(
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 한 줄에 두 개의 항목 배치
          crossAxisSpacing: 1, // 각 항목 간의 가로 간격 1px
          mainAxisSpacing: 1, // 각 항목 간의 세로 간격 1px
          childAspectRatio: 2.5, // 아이템의 비율 (세로/가로 비율)
        ),
        itemCount: festivals.length,
        itemBuilder: (context, index) {
          final festival = festivals[index];
          return Card(
            margin: EdgeInsets.all(0), // 카드 간 간격 제거
            elevation: 4, // 카드 그림자
            child: Stack(
              children: [
                // 카드 배경 이미지 설정
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(festival.imageUrl), // 이미지 URL 사용
                      fit: BoxFit.cover, // 이미지가 영역을 꽉 채우도록 설정
                    ),
                  ),
                ),
                // 카드 내부 내용
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          launchURL(festival.link);  // title을 클릭하면 링크 열기
                        },
                        child: Text(
                          festival.title,
                          style: TextStyle(
                            fontSize: titleFontSize, // 비례적인 텍스트 크기
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // 배경이 어두울 경우 흰색 텍스트로 설정
                          ),
                        ),
                      ),
                      Text(
                        festival.subtitle,
                        style: TextStyle(
                          fontSize: subtitleFontSize, // 비례적인 텍스트 크기
                          color: Colors.white, // 텍스트 색상
                        ),
                      ),
                      Text(
                        festival.date,
                        style: TextStyle(
                          fontSize: dateFontSize, // 비례적인 텍스트 크기
                          color: Colors.white, // 텍스트 색상
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
