import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photoapp/domain/model/album.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/presentation/screens/detail_album_screen.dart';
import 'package:photoapp/presentation/viewmodel/gallery_album_view_model.dart';
import 'package:photoapp/presentation/viewmodel/init_view_model.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:provider/provider.dart';

class FavoriteScreen extends StatefulWidget {
  final Album album;

  const FavoriteScreen({super.key, required this.album});

  @override
  State<StatefulWidget> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late GalleryAlbumViewModel _galleryAlbumviewModel;

  @override
  void initState() {
    super.initState();
    _galleryAlbumviewModel =
        Provider.of<GalleryAlbumViewModel>(context, listen: false);
    _galleryAlbumviewModel.currentAlbum = widget.album;
  }

  void _openDetailScreen(Media media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailAlbumScreen(media: media),
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

    if (_galleryAlbumviewModel.currentAlbum.medias.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorite'),
        ),
        body: const Center(
            child: Text(
                'There are no any favorited media found . Let\'s add some!')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: () async {
            print('Refresh _galleryAlbumviewModel.currentAlbum');
          },
          child: GridView.builder(
            itemCount: _galleryAlbumviewModel.currentAlbum.medias.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: initViewModel.crossAxisCount,
              crossAxisSpacing: initViewModel.crossAxisSpacing,
              mainAxisSpacing: initViewModel.mainAxisSpacing,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    _openDetailScreen(_galleryAlbumviewModel.currentAlbum.medias[index]);
                  },
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: _buildThumbnail(_galleryAlbumviewModel.currentAlbum.medias[index]),
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
