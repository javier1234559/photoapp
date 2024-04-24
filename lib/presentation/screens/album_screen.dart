import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photoapp/database/album_dao.dart';
import 'package:photoapp/database/db_helper.dart';
import 'package:photoapp/database/models/album.dart';

class AlbumScreen extends StatefulWidget {
  static String appBarName = "Album";
  static String routeName = "/album";
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  int displayColumnCount = 3;
  int numberOfItems = 12;
  late AlbumDao albumDao;
  List<Album>? _albums;

  @override
  void initState() {
    super.initState();

    // initializeDatabase();

    _loadAlbums();
  }

  Future<void> initializeDatabase() async {
    final appDatabase = await DBHelper.getInstance();
    albumDao = appDatabase.albumDao;
  }

  Future<void> _loadAlbums() async {
    final database = await DBHelper.getInstance();
    albumDao = database.albumDao;
    final albums = await albumDao.findAllAlbum();
    setState(() {
      _albums = albums;
    });
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

  _openDetailAlbum(AssetEntity asset) {}

  @override
  Widget build(BuildContext context) {
    if (_albums == null || _albums!.isEmpty) {
      // Return a message when there are no albums
      return const Center(child: Text('No albums found'));
    }

    return GridView.builder(
      itemCount: _albums?.length ?? 0,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Number of columns
        crossAxisSpacing: 5, // Spacing between columns
        mainAxisSpacing: 5, // Spacing between rows
      ),
      itemBuilder: (context, index) {
        return FutureBuilder<AssetEntity>(
          future: _albums![index].getThumbnailAssetEntity(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final AssetEntity asset = snapshot.data!;
              return AssetEntityImage(
                asset,
                isOriginal: false,
                fit: BoxFit.cover,
                thumbnailSize: const ThumbnailSize.square(300),
                thumbnailFormat: ThumbnailFormat.jpeg,
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}
