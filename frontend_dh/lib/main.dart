import 'package:flutter/material.dart';
import 'package:frontend_dh/screen/home_screen.dart';
import 'package:frontend_dh/screen/festival_screen.dart';
import 'package:frontend_dh/screen/event_screen.dart';
import 'package:frontend_dh/screen/pharmacies_screen.dart';
import 'package:frontend_dh/screen/schedule_screen.dart';
import 'package:frontend_dh/screen/combined_screen.dart';
import 'package:frontend_dh/screen/library_program_screen.dart';
import 'package:frontend_dh/screen/community_program_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> _screens = [
    HomeScreen(),
    CombinedScreen(),
    //FestivalScreen(),
    EventScreen(),
    //ScheduleScreen(),
    LibraryProgramScreen(),
    PharmaciesScreen(),
    // CommunityProgramScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('APP BAR')),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue, // 선택된 아이템 색상
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: '축제',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: '행사',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: '도서관 프로그램',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.house),
            label: '주민센터 프로그램',
          ),
        ],
      ),
    );
  }
}
