import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photoapp/data/mapper/asset_mapper.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/domain/model/tag.dart';
import 'package:photoapp/presentation/screens/add_album_screen.dart';
import 'package:photoapp/presentation/viewmodel/detail_album_view_model.dart';
import 'package:photoapp/presentation/viewmodel/gallery_album_view_model.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:photoapp/utils/wallpaper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class DetailAlbumScreen extends StatefulWidget {
  final Media media;

  const DetailAlbumScreen({super.key, required this.media});

  @override
  State<DetailAlbumScreen> createState() => _DetailAlbumScreenState();
}

class _DetailAlbumScreenState extends State<DetailAlbumScreen> {
  late GalleryAlbumViewModel _galleryAlbumViewModel;
  late DetailAlbumViewModel _detailAlbumViewModel;

  @override
  void initState() {
    super.initState();
    _detailAlbumViewModel = DetailAlbumViewModel(widget.media);
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
              color: icon == Icons.favorite && _detailAlbumViewModel.isFavorite
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
        if (_detailAlbumViewModel.controller!.value.isPlaying) {
          _detailAlbumViewModel.pauseVideo();
        } else {
          _detailAlbumViewModel.playVideo();
        }
      },
      child: Icon(
        _detailAlbumViewModel.controller != null &&
                _detailAlbumViewModel.controller!.value.isPlaying
            ? Icons.pause
            : Icons.play_arrow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _detailAlbumViewModel,
      child: _detailAlbumScreenContent(context),
    );
  }

  Widget _detailAlbumScreenContent(BuildContext context) {
    _galleryAlbumViewModel =
        Provider.of<GalleryAlbumViewModel>(context, listen: false);
    int initialPage = _galleryAlbumViewModel.currentAlbum.medias.indexWhere(
        (element) => element.id == _detailAlbumViewModel.currentMedia.id);
    initialPage = initialPage != -1 ? initialPage : 0;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.transparent,
        title: Consumer<DetailAlbumViewModel>(
          builder: (context, _detailAlbumViewModel, child) {
            return Text(
              _detailAlbumViewModel.currentMedia.name,
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
      backgroundColor: Colors.black26,
      body: PageView.builder(
        controller: PageController(initialPage: initialPage),
        itemCount: _galleryAlbumViewModel.album.medias.length,
        onPageChanged: (index) {
          _detailAlbumViewModel.currentMedia =
              _galleryAlbumViewModel.album.medias[index];
        },
        itemBuilder: (context, index) {
          // _detailAlbumViewModel.currentMedia = _galleryAlbumViewModel.album.medias[index];
          LoggingUtil.logInfor(
              'Media path $index : ${_galleryAlbumViewModel.album.medias[index].toString()}');
          Widget? pageWidget;

          if (_galleryAlbumViewModel.album.medias[index].type == "video") {
            pageWidget = FutureBuilder(
              future: _detailAlbumViewModel
                  .initVideoPlayer(_galleryAlbumViewModel.album.medias[index]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio:
                        _detailAlbumViewModel.controller!.value.aspectRatio,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width:
                            _detailAlbumViewModel.controller!.value.size.width,
                        height:
                            _detailAlbumViewModel.controller!.value.size.height,
                        child: VideoPlayer(_detailAlbumViewModel.controller!),
                      ),
                    ),
                  );
                } else {
                  // While the controller is still loading, display a loading spinner
                  return const Center(child: CircularProgressIndicator());
                }
              },
            );
          }

          if (_galleryAlbumViewModel.album.medias[index].type == "image") {
            pageWidget = FutureBuilder<AssetEntity?>(
              future: AssetMapper.transformMediaToAssetEntity(
                  _galleryAlbumViewModel.album.medias[index]),
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

          pageWidget = pageWidget ??
              Center(
                child: Text(
                    'Unsupported media type ${_galleryAlbumViewModel.album.medias[index].type}',
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
              );

          // Wrap the pageWidget with PageStorageKey
          return Container(
            key: PageStorageKey(index.toString()),
            child: pageWidget,
          );
        },
      ),
      floatingActionButton: Consumer<DetailAlbumViewModel>(
        builder: (context, _detailAlbumViewModel, child) {
          return _detailAlbumViewModel.currentMedia.type == "video"
              ? _buttonPlay()
              : Container();
        },
      ),
      bottomNavigationBar: Consumer<DetailAlbumViewModel>(
          builder: (context, _detailAlbumViewModel, child) {
        return BottomAppBar(
          color: Colors.black26,
          child: SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildActionButton(Icons.share, 'Share', onPressed: () async {
                    await Share.share(_detailAlbumViewModel.currentMedia.path);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for sharing with others!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }),
                  buildActionButton(Icons.favorite, 'Love',
                      onPressed: () async {
                    await _detailAlbumViewModel.toggleFavorite();
                  }),
                  buildActionButton(Icons.delete, 'Delete', onPressed: () {}),
                  buildActionButton(Icons.tag, 'Hash Tag', onPressed: () async {
                    Tag? newTag = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AddHashTag();
                      },
                    );
                    if (newTag != null) {
                      await _detailAlbumViewModel.creatNewHashTag(newTag);
                      Navigator.of(context).pop();
                    }
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
                        List<Media> listMedia = [
                          _detailAlbumViewModel.currentMedia
                        ];
                        await Navigator.push(
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
                                _detailAlbumViewModel.currentMedia.path);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(result)));
                      } else if (value == 3) {
                        String result =
                            await WallpaperHandler.setWallPaperLockScreen(
                                _detailAlbumViewModel.currentMedia.path);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(result)));
                      } else if (value == 4) {
                        String result =
                            await WallpaperHandler.setWallPaperBothScreen(
                                _detailAlbumViewModel.currentMedia.path);
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
    _detailAlbumViewModel.controller?.dispose();
    super.dispose();
  }
}

class AddHashTag extends StatefulWidget {
  const AddHashTag({super.key});

  @override
  State<AddHashTag> createState() => _AddHashTagState();
}

class _AddHashTagState extends State<AddHashTag> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add new hashtag'),
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
            String hashTagName = _textFieldController.text;
            Tag newTag = Tag(name: hashTagName, color: "0xff000000");
            if (hashTagName.isNotEmpty) {
              Navigator.of(context).pop(newTag);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
