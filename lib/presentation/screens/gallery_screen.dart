import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/presentation/viewmodel/gallery_view_model.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:provider/provider.dart';

import 'detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  static String appBarName = "Gallery";
  static String routeName = "/gallery";
  const GalleryScreen({super.key});

  @override
  State<StatefulWidget> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  void _openDetailScreen(Media media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(media: media),
      ),
    );
  }

  Widget _buildThumbnail(Media media) {
    return FutureBuilder<Widget>(
      future: _generateThumbnail(media),
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

  Future<Widget> _generateThumbnail(Media media) async {
    File thumbnailImage = File(media.path);

    if (!(await thumbnailImage.exists())) {
      return const Center(child: CircularProgressIndicator());
    }

    // If it's a video, add additional UI elements
    if (media.type == AssetType.video.toString()) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.file(thumbnailImage, fit: BoxFit.cover),
          Positioned(
            bottom: 0,
            left: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 16.0,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      media.duration.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 5), // Add space to the bottom of the Row
              ],
            ),
          )
        ],
      );
    } else {
      // If it's not a video, just display the image
      return Image.file(thumbnailImage, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryViewModel>(
      builder: (context, viewModel, child) {
        return FutureBuilder<List<Media>>(
          future: viewModel.loadRecentMedia(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              LoggingUtil.logDebug('Error loading media: ${snapshot.error}');
              return Center(child: Text('Error loading media: $snapshot'));
            } else {
              final List<Media> medias = snapshot.data ?? [];
              if (medias.isEmpty) {
                return const Center(child: Text('No images found'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  viewModel.loadRecentMedia();
                },
                child: GridView.builder(
                  itemCount: medias.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Number of columns
                    crossAxisSpacing: 5, // Spacing between columns
                    mainAxisSpacing: 5, // Spacing between rows
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _openDetailScreen(medias[index]),
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: ClipRect(
                          child: _buildThumbnail(medias[index]),
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
