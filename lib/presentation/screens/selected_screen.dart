import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/presentation/viewmodel/gallery_view_model.dart';
import 'package:photoapp/presentation/viewmodel/init_view_model.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:provider/provider.dart';

class SelectMediaScreen extends StatefulWidget {
  Media firstMediaSelected;
  SelectMediaScreen({super.key, required this.firstMediaSelected});

  @override
  State<StatefulWidget> createState() => _SelectMediaScreenState();
}

class _SelectMediaScreenState extends State<SelectMediaScreen> {
  List<Media> selectedMedias = [];

  @override
  void initState() {
    super.initState();
    selectedMedias.add(widget.firstMediaSelected);
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

  void _addSelectMedia(Media media) {
    if (selectedMedias.contains(media)) {
      selectedMedias.remove(media);
    } else {
      selectedMedias.add(media);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final initViewModel = Provider.of<InitViewModel>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Select Media'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pop(context, selectedMedias);
              },
            ),
            const Text('Add To Album'),
          ],
        ),
        body: Consumer<GalleryViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.medias.isEmpty) {
              return RefreshIndicator(
                  onRefresh: viewModel.refreshMedia,
                  child: const Center(child: Text('No medias found')));
            }

            return RefreshIndicator(
              onRefresh: viewModel.refreshMedia,
              child: GridView.builder(
                itemCount: viewModel.medias.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: initViewModel.crossAxisCount,
                  crossAxisSpacing: initViewModel.crossAxisSpacing,
                  mainAxisSpacing: initViewModel.mainAxisSpacing,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _addSelectMedia(viewModel.medias[index]);
                    },
                    child: Stack(
                      children: <Widget>[
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: _buildThumbnail(viewModel.medias[index]),
                          ),
                        ),
                        if (selectedMedias.contains(
                            viewModel.medias[index])) // if the item is selected
                          const Icon(Icons.check_circle,
                              color: Colors.green), // show selection icon
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ));
  }
}
