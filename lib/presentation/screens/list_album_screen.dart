import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photoapp/data/mapper/asset_mapper.dart';
import 'package:photoapp/domain/model/album.dart';
import 'package:photoapp/presentation/screens/album_screen.dart';
import 'package:photoapp/presentation/screens/favorite_screen.dart';
import 'package:photoapp/presentation/screens/recyclebin_screen.dart';
import 'package:photoapp/presentation/viewmodel/album_view_model.dart';
import 'package:photoapp/presentation/viewmodel/init_view_model.dart';
import 'package:photoapp/utils/constants.dart';
import 'package:provider/provider.dart';

class ListAlbumScreen extends StatefulWidget {
  static String appBarName = "Album";
  static String routeName = "/album";
  const ListAlbumScreen({super.key});

  @override
  State<ListAlbumScreen> createState() => _ListAlbumScreenState();
}

class _ListAlbumScreenState extends State<ListAlbumScreen> {
  late AlbumViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<AlbumViewModel>(context, listen: false);
  }

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
    if (album.medias.isEmpty) {
      if (album.title == 'Favorite') {
        return Image.asset(favoriteLogoPath);
      } else if (album.title == 'Recycle Bin') {
        return Image.asset(recycleBinLogoPath);
      }
    }
    final asset =
        await AssetMapper.transformMediaToAssetEntity(album.medias.last);
    return AssetEntityImage(
      asset!,
      isOriginal: false,
      fit: BoxFit.cover,
      thumbnailSize: const ThumbnailSize.square(200),
      thumbnailFormat: ThumbnailFormat.jpeg,
    );
  }

  Widget _buildDefaultAlbumItem(String imagePath, String albumName) {
    return GestureDetector(
      onTap: () async {
        if (albumName == 'Favorite') {
          await _viewModel.loadFavoriteAlbum();
          Album favoriteAlbum = _viewModel.favoriteAlbum;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FavoriteScreen(
                album: favoriteAlbum,
              ),
            ),
          );
        } else if (albumName == 'Recycle Bin') {
          await _viewModel.loadRecycleBinAlbum();
          Album recycleBin = _viewModel.recycleBinAlbum;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecycleBinScreen(
                album: recycleBin,
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 100,
              height: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              albumName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initViewModel = Provider.of<InitViewModel>(context);
    return Consumer<AlbumViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.albums.isEmpty) {
          return const Center(child: Text('No albums found'));
        }

        return RefreshIndicator(onRefresh: () async {
          await viewModel.refreshAlbum();
        }, child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _buildDefaultAlbumItem(favoriteLogoPath, 'Favorite'),
                    _buildDefaultAlbumItem(recycleBinLogoPath, 'Recycle Bin'),
                  ],
                ),
                SizedBox(
                  child: SingleChildScrollView(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: viewModel.albums.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: initViewModel.crossAxisCount,
                        crossAxisSpacing: initViewModel.crossAxisSpacing,
                        mainAxisSpacing: initViewModel.mainAxisSpacing,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlbumScreen(
                                  album: viewModel.albums[index],
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: _buildThumbnail(
                                        viewModel.albums[index]),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                viewModel.albums[index].title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ));
      },
    );
  }
}
