import 'package:flutter/material.dart';

class AlbumScreen extends StatefulWidget {
  static String appBarName = "Album";
  static String routeName = "/album";
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final _albums = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_albums == null || _albums.isEmpty) {
      // Return a message when there are no albums
      return const Center(child: Text('No albums found'));
    }

    return Center(
      child: ListView.builder(
        itemCount: _albums!.length,
        itemBuilder: (context, index) {
          final album = _albums![index];
          return ListTile(
            title: Text(album.name),
            onTap: () {
              // Navigate to the album screen
              Navigator.pushNamed(context, AlbumScreen.routeName,
                  arguments: album);
            },
          );
        },
      ),
    );
  }
}
