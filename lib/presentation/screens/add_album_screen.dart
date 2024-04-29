import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photoapp/data/mapper/asset_mapper.dart';
import 'package:photoapp/domain/model/album.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/presentation/viewmodel/album_view_model.dart';

import 'package:photoapp/presentation/viewmodel/init_view_model.dart';
import 'package:photoapp/utils/constants.dart';
import 'package:provider/provider.dart';

class AddAlbumScreen extends StatefulWidget {
  List<Media> selectedMedia;
  AddAlbumScreen({super.key, required this.selectedMedia});

  @override
  State<AddAlbumScreen> createState() => _AddAlbumScreenState();
}

class _AddAlbumScreenState extends State<AddAlbumScreen> {
  late AlbumViewModel albumViewModel;
  late List<Media> selectedMedia;

  @override
  void initState() {
    super.initState();
    selectedMedia = widget.selectedMedia;
    albumViewModel = Provider.of<AlbumViewModel>(context, listen: false);
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

  Future<void> _addToNewAlbum() async {
    String? nameAlbum = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddAlbumDialog();
      },
    );
    if (nameAlbum != null) {
      await albumViewModel.addToAlbum(nameAlbum, selectedMedia);
      Navigator.of(context).pop();
    }
  }

  Future<void> _addToExistAlbum(String nameAlbum) async {
    await albumViewModel.addToAlbum(nameAlbum, selectedMedia);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final initViewModel = Provider.of<InitViewModel>(context);

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Choose Album to add media to"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Consumer<AlbumViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.albums.isEmpty) {
              return const Center(child: Text('No albums found'));
            }
            return GridView.builder(
              itemCount: viewModel.albums.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: initViewModel.crossAxisCount,
                crossAxisSpacing: initViewModel.crossAxisSpacing,
                mainAxisSpacing: initViewModel.mainAxisSpacing,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      String title = viewModel.albums[index].title;
                      _addToExistAlbum(title);
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: _buildThumbnail(viewModel.albums[index]),
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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addToNewAlbum,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add),
      ),
    ));
  }
}

class AddAlbumDialog extends StatefulWidget {
  const AddAlbumDialog({super.key});

  @override
  State<AddAlbumDialog> createState() => _AddAlbumDialogState();
}

class _AddAlbumDialogState extends State<AddAlbumDialog> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add album'),
      content: TextField(
        controller: _textFieldController,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            String newItem = _textFieldController.text;
            if (newItem.isNotEmpty) {
              Navigator.of(context).pop(newItem);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
