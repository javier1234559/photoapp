
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photoapp/data/mapper/asset_mapper.dart';
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        Provider.of<AlbumViewModel>(context, listen: false).refreshAlbum();
      },
      child: Consumer<AlbumViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.albums.isEmpty) {
            return const Center(child: Text('No albums found'));
          }

          return GridView.builder(
            itemCount: viewModel.albums.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Number of columns
              crossAxisSpacing: 5, // Spacing between columns
              mainAxisSpacing: 5, // Spacing between rows
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {},
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: ClipRect(
                    child: _buildThumbnail(viewModel.albums[index]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
