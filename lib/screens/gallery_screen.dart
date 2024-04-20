import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import 'detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  static String appBarName = "Gallery";
  static String routeName = "/gallery";
  const GalleryScreen({super.key});

  @override
  State<StatefulWidget> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<AssetEntity>? _medias;

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) => _loadRecentMedia());
  }

  Future<void> _loadRecentMedia() async {
    final List<AssetPathEntity> albums =
        await PhotoManager.getAssetPathList(onlyAll: true);
    final AssetPathEntity album = albums.firstWhere((element) => element.isAll);
    final List<AssetEntity> assets = await album.getAssetListRange(
        start: 0, end: 100); // Adjust the range as needed

    // Filter the assets to include only images and videos
    final List<AssetEntity> mediaList = assets.where((asset) {
      return asset.type == AssetType.image || asset.type == AssetType.video;
    }).toList();

    print(mediaList);
    setState(() {
      _medias = mediaList; // Store AssetEntity objects
    });
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.photos.status;
    if (!status.isGranted) {
      await [
        Permission.storage,
        Permission.camera,
      ].request();
      await Permission.photos.request();
    }
  }

  void _openDetailScreen(AssetEntity asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(asset: asset),
      ),
    );
  }

  Future<Widget> _buildThumbnail(AssetEntity asset) async {
    if (asset.type == AssetType.video) {
      // If it's a video, build video player thumbnail and display video duration
      Duration? videoDuration = asset.videoDuration;

      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AssetEntityImage(
            asset,
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
                        size: 16.0,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        videoDuration.toString().substring(2, 7),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height: 5), // Add space to the bottom of the Row
                ],
              ))
        ],
      );
    } else {
      // If it's an image, build image thumbnail
      return AssetEntityImage(
        asset,
        isOriginal: false,
        fit: BoxFit.cover,
        thumbnailSize: const ThumbnailSize.square(300),
        thumbnailFormat: ThumbnailFormat.jpeg, // Preferred thumbnail format
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: _medias?.length ?? 0,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Number of columns
        crossAxisSpacing: 5, // Spacing between columns
        mainAxisSpacing: 5, // Spacing between rows
      ),
      itemBuilder: (context, index) {
        final AssetEntity asset = _medias![index];

        return GestureDetector(
          onTap: () => _openDetailScreen(asset),
          child: SizedBox(
            width: 150,
            height: 150,
            child: ClipRect(
              child: FutureBuilder<Widget>(
                future: _buildThumbnail(asset),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return snapshot.data!;
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
