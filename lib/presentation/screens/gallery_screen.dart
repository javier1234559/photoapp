import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/presentation/screens/video_screen.dart';
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

  void _openVideoScreen(Media media) {
    LoggingUtil.logDebug('Open video screen: ${media.path}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoScreen(media: media),
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
    AssetEntity? asset = await AssetEntity.fromId(media.id);

    if (media.type == AssetType.video.name.toString()) {
      LoggingUtil.logDebug('Video thumbnail: ${media.path}');
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AssetEntityImage(
            asset!,
            isOriginal: false,
            fit: BoxFit.cover,
            thumbnailSize: const ThumbnailSize.square(200),
            thumbnailFormat: ThumbnailFormat.jpeg,
          ),
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
                      size: 12.0,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      media.duration.toString(),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12.0),
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
      return AssetEntityImage(
        asset!,
        isOriginal: false,
        fit: BoxFit.cover,
        thumbnailSize: const ThumbnailSize.square(200),
        thumbnailFormat: ThumbnailFormat.jpeg,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.medias.isEmpty) {
          return RefreshIndicator(
              onRefresh: viewModel.refreshMedia,
              child: const Center(child: Text('No images found')));
        }

        return RefreshIndicator(
          onRefresh: viewModel.refreshMedia,
          child: GridView.builder(
            itemCount: viewModel.medias.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Number of columns
              crossAxisSpacing: 5, // Spacing between columns
              mainAxisSpacing: 5, // Spacing between rows
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (viewModel.medias[index].type == "video") {
                    _openVideoScreen(viewModel.medias[index]);
                  } else {
                    _openDetailScreen(viewModel.medias[index]);
                  }
                },
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: ClipRect(
                    child: _buildThumbnail(viewModel.medias[index]),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
