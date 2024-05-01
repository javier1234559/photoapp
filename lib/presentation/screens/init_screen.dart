import 'package:flutter/material.dart';
import 'package:photoapp/presentation/screens/list_album_screen.dart';
import 'package:photoapp/presentation/screens/gallery_screen.dart';
import 'package:photoapp/presentation/screens/search_screen.dart';
import 'package:photoapp/presentation/viewmodel/init_view_model.dart';
import 'package:provider/provider.dart';

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
    const ListAlbumScreen(),
    const SearchScreen(),
  ];

  final appBarTitles = [
    GalleryScreen.appBarName,
    ListAlbumScreen.appBarName,
    SearchScreen.appBarName
  ];

  void updateCurrentIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final initViewModel = Provider.of<InitViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitles[currentSelectedIndex],
          style: const TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(
                  50, // left
                  50, // top
                  10, // right
                  0, // bottom
                ),
                items: [
                  const PopupMenuItem<int>(
                    value: 3,
                    child: Text('View as 3 column'),
                  ),
                  const PopupMenuItem<int>(
                    value: 4,
                    child: Text('View as 4 column'),
                  ),
                  const PopupMenuItem<int>(
                    value: 5,
                    child: Text('View as 5 column'),
                  ),
                  const PopupMenuItem<int>(
                    value: 6,
                    child: Text('Setting Screen'),
                  ),
                ],
              ).then((value) {
                if (value != null) {
                  if (value == 3) {
                    initViewModel.crossAxisCount = 3;
                  } else if (value == 4) {
                    initViewModel.crossAxisCount = 4;
                  } else if (value == 5) {
                    initViewModel.crossAxisCount = 5;
                  } else {
                    Navigator.pushNamed(context, '/setting');
                  }
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
          child: pages[currentSelectedIndex],
        ),
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
