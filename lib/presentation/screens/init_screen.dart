import 'package:flutter/material.dart';
import 'package:photoapp/presentation/screens/album_screen.dart';
import 'package:photoapp/presentation/screens/gallery_screen.dart';
import 'package:photoapp/presentation/screens/search_screen.dart';

class InitScreen extends StatefulWidget {
  static String routeName = "/";
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  int currentSelectedIndex = 0;

  final pages = [
    const GalleryScreen(),
    const AlbumScreen(),
    const SearchScreen(),
  ];

  final appBarTitles = [
    GalleryScreen.appBarName,
    AlbumScreen.appBarName,
    SearchScreen.appBarName
  ];

  void updateCurrentIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[currentSelectedIndex]),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 5), // Add top padding here
        child: pages[currentSelectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: updateCurrentIndex,
        currentIndex: currentSelectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Images',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Albums',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}
