import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photoapp/domain/model/album.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/presentation/viewmodel/init_view_model.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:provider/provider.dart';

import 'detail_screen.dart';

class RecycleBinScreen extends StatefulWidget {
  Album album;

  RecycleBinScreen({super.key, required this.album});

  @override
  State<StatefulWidget> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  late Album album;

  @override
  void initState() {
    super.initState();
    album = widget.album;
  }

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
    final initViewModel = Provider.of<InitViewModel>(context);

    if (album.medias.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Recycle Bin"),
        ),
        body:
            const Center(child: Text('There are no any deleted media found ')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recycle Bin"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: RefreshIndicator(
          onRefresh: () async {
            print('Refresh album');
          },
          child: GridView.builder(
            itemCount: album.medias.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: initViewModel.crossAxisCount,
              crossAxisSpacing: initViewModel.crossAxisSpacing,
              mainAxisSpacing: initViewModel.mainAxisSpacing,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    _openDetailScreen(album.medias[index]);
                  },
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: _buildThumbnail(album.medias[index]),
                    ),
                  ) //
                  );
            },
          ),
        ),
      ),
    );
  }
}
