import 'package:flutter/material.dart';
import 'package:photoapp/screens/album_screen.dart';
import 'package:photoapp/screens/gallery_screen.dart';
import 'package:photoapp/screens/init_screen.dart';
import 'package:photoapp/screens/search_screen.dart';
import 'package:photoapp/theme.dart';

final Map<String, WidgetBuilder> routes = {
  InitScreen.routeName: (context) => const InitScreen(),
  GalleryScreen.routeName: (context) => const GalleryScreen(),
  AlbumScreen.routeName: (context) => const AlbumScreen(),
  SearchScreen.routeName: (context) => const SearchScreen(),
};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo App - Organize your photos!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      initialRoute: InitScreen.routeName,
      routes: routes,
    );
  }
}
