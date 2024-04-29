import 'package:flutter/material.dart';
import 'package:photoapp/presentation/screens/album_screen.dart';
import 'package:photoapp/presentation/screens/gallery_screen.dart';
import 'package:photoapp/presentation/screens/init_screen.dart';
import 'package:photoapp/presentation/screens/search_screen.dart';
import 'package:photoapp/presentation/screens/setting_screen.dart';
import 'package:photoapp/presentation/viewmodel/album_view_model.dart';
import 'package:photoapp/presentation/viewmodel/gallery_view_model.dart';
import 'package:photoapp/presentation/viewmodel/init_view_model.dart';
import 'package:photoapp/utils/theme.dart';
import 'package:provider/provider.dart';

final Map<String, WidgetBuilder> routes = {
  InitScreen.routeName: (context) => const InitScreen(),
  GalleryScreen.routeName: (context) => const GalleryScreen(),
  AlbumScreen.routeName: (context) => const AlbumScreen(),
  SearchScreen.routeName: (context) => const SearchScreen(),
  SettingsScreen.routeName: (context) => const SettingsScreen(),
};

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GalleryViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => AlbumViewModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => InitViewModel(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo App - Organize your photos!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: Provider.of<InitViewModel>(context).themeMode,
      initialRoute: InitScreen.routeName,
      routes: routes,
    );
  }
}
