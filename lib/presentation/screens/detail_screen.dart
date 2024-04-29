import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photoapp/data/mapper/asset_mapper.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/presentation/screens/add_album_screen.dart';
import 'package:photoapp/presentation/viewmodel/detail_screen_view_model.dart';
import 'package:photoapp/presentation/viewmodel/gallery_view_model.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:photoapp/utils/wallpaper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class DetailScreen extends StatefulWidget {
  final Media media;

  const DetailScreen({super.key, required this.media});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late GalleryViewModel galleryViewModel;
  late DetailScreenViewModel detailViewModel;

  @override
  void initState() {
    super.initState();
    detailViewModel = DetailScreenViewModel(widget.media);
  }

  Widget buildActionButton(IconData icon, String title,
      {required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: icon == Icons.favorite && detailViewModel.isFavorite
                  ? const Color.fromARGB(255, 255, 81, 81)
                  : Colors.grey,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonPlay() {
    return FloatingActionButton(
      onPressed: () {
        if (detailViewModel.controller!.value.isPlaying) {
          detailViewModel.pauseVideo();
        } else {
          detailViewModel.playVideo();
        }
      },
      child: Icon(
        detailViewModel.controller != null &&
                detailViewModel.controller!.value.isPlaying
            ? Icons.pause
            : Icons.play_arrow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => detailViewModel,
      child: _detailScreenContent(context),
    );
  }

  Widget _detailScreenContent(BuildContext context) {
    galleryViewModel = Provider.of<GalleryViewModel>(context, listen: false);
    int initialPage = galleryViewModel.medias
        .indexWhere((element) => element.id == detailViewModel.currentMedia.id);
    initialPage = initialPage != -1 ? initialPage : 0;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.transparent,
        title: Consumer<DetailScreenViewModel>(
          builder: (context, detailViewModel, child) {
            return Text(
              detailViewModel.currentMedia.name,
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
      backgroundColor: Colors.black26,
      body: PageView.builder(
        controller: PageController(initialPage: initialPage),
        itemCount: galleryViewModel.medias.length,
        onPageChanged: (index) {
          detailViewModel.currentMedia = galleryViewModel.medias[index];
        },
        itemBuilder: (context, index) {
          LoggingUtil.logInfor(
              'Media path $index : ${galleryViewModel.medias[index].toString()}');
          Widget pageWidget;

          if (galleryViewModel.medias[index].type == "video") {
            pageWidget = FutureBuilder(
              future: detailViewModel
                  .initVideoPlayer(galleryViewModel.medias[index]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Failed to load video'),
                  );
                } else {
                  return Consumer<DetailScreenViewModel>(
                    builder: (context, detailViewModel, child) {
                      return AspectRatio(
                        aspectRatio:
                            detailViewModel.controller!.value.aspectRatio,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: detailViewModel.controller!.value.size.width,
                            height:
                                detailViewModel.controller!.value.size.height,
                            child: VideoPlayer(detailViewModel.controller!),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            );
          } else {
            pageWidget = FutureBuilder<AssetEntity?>(
              future: AssetMapper.transformMediaToAssetEntity(
                  galleryViewModel.medias[index]),
              builder: (BuildContext context,
                  AsyncSnapshot<AssetEntity?> assetSnapshot) {
                if (assetSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (assetSnapshot.hasError) {
                  return Text('Error: ${assetSnapshot.error}');
                } else {
                  return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: PhotoView(
                      imageProvider: AssetEntityImageProvider(
                        assetSnapshot.data!,
                        isOriginal: true,
                      ),
                    ),
                  );
                }
              },
            );
          }

          // Wrap the pageWidget with PageStorageKey
          return Container(
            key: PageStorageKey(index.toString()),
            child: pageWidget,
          );
        },
      ),
      floatingActionButton: Consumer<DetailScreenViewModel>(
        builder: (context, detailViewModel, child) {
          return detailViewModel.currentMedia.type == "video"
              ? _buttonPlay()
              : Container();
        },
      ),
      bottomNavigationBar: Consumer<DetailScreenViewModel>(
          builder: (context, detailViewModel, child) {
        return BottomAppBar(
          color: Colors.black26,
          child: SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildActionButton(Icons.share, 'Share', onPressed: () async {
                    await Share.share(detailViewModel.currentMedia.path);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for sharing with others!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }),
                  buildActionButton(Icons.favorite, 'Love',
                      onPressed: () async {
                    await detailViewModel.toggleFavorite();
                  }),
                  buildActionButton(Icons.delete, 'Delete', onPressed: () {}),
                  buildActionButton(Icons.tag, 'Hash Tag', onPressed: () {
                    // Navigate to crop screen
                  }),
                  buildActionButton(Icons.more_vert, 'More',
                      onPressed: () async {
                    showMenu(
                      context: context,
                      position: const RelativeRect.fromLTRB(100, 550, 8, 0),
                      items: [
                        const PopupMenuItem(
                          value: 1,
                          child: Text('Add Album'),
                        ),
                        const PopupMenuItem(
                          value: 2,
                          child: Text('Use as Wallpaper Home Screen'),
                        ),
                        const PopupMenuItem(
                          value: 3,
                          child: Text('Use as Wallpaper Lock Screen'),
                        ),
                        const PopupMenuItem(
                          value: 4,
                          child: Text('Use as Wallpaper Both Screen'),
                        ),
                      ],
                    ).then((value) async {
                      if (value == 1) {
                        List<Media> listMedia = [detailViewModel.currentMedia];
                        final result = Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddAlbumScreen(selectedMedia: listMedia)),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Add to album successfully!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (value == 2) {
                        String result =
                            await WallpaperHandler.setWallPaperHomeScreen(
                                detailViewModel.currentMedia.path);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(result)));
                      } else if (value == 3) {
                        String result =
                            await WallpaperHandler.setWallPaperLockScreen(
                                detailViewModel.currentMedia.path);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(result)));
                      } else if (value == 4) {
                        String result =
                            await WallpaperHandler.setWallPaperBothScreen(
                                detailViewModel.currentMedia.path);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(result)));
                      }
                    });
                  }),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    detailViewModel.controller?.dispose();
    super.dispose();
  }
}
