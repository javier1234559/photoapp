import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photoapp/domain/model/album.dart';
import 'package:photoapp/presentation/viewmodel/album_view_model.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:provider/provider.dart';

class AlbumScreen extends StatefulWidget {
  static String appBarName = "Album";
  static String routeName = "/album";
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  
  Widget _buildThumbnail(Album album) {
    return FutureBuilder<Widget>(
      future: _generateThumbnail(album),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return snapshot.data!;
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<Widget> _generateThumbnail(Album album) async {
    File thumbnailImage = File(album.thumbnailPath);

    return Image.file(thumbnailImage, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlbumViewModel>(
      builder: (context, viewModel, child) {
        return FutureBuilder<List<Album>>(
          future: viewModel.loadAlbums(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              LoggingUtil.logDebug('Error loading album: ${snapshot.error}');
              return Center(child: Text('Error loading album: $snapshot'));
            } else {
              final List<Album> albums = snapshot.data ?? [];
              if (albums.isEmpty) {
                return const Center(child: Text('No images found'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  viewModel.loadAlbums();
                },
                child: GridView.builder(
                  itemCount: albums.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Number of columns
                    crossAxisSpacing: 5, // Spacing between columns
                    mainAxisSpacing: 5, // Spacing between rows
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // if (albums[index].type == "video") {
                        //   _openVideoScreen(albums[index]);
                        // } else {
                        //   _openDetailScreen(albums[index]);
                        // }
                      },
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: ClipRect(
                          child: _buildThumbnail(albums[index]),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        );
      },
    );
  }
}
