import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photoapp/data/mapper/asset_mapper.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/presentation/screens/add_album_screen.dart';
import 'package:photoapp/presentation/viewmodel/detail_screen_view_model.dart';
import 'package:photoapp/presentation/viewmodel/gallery_view_model.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  final Media media;

  const VideoScreen({super.key, required this.media});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late GalleryViewModel galleryViewModel;
  late DetailScreenViewModel detailViewModel;

  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    detailViewModel = DetailScreenViewModel(widget.media);
    _initVideoPlayer();
  }

  void _initVideoPlayer() async {
    _controller = VideoPlayerController.file(File(widget.media.path));
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
    }).catchError((error) {
      // Handle the error appropriately.
      print('Error occurred while initializing video player: $error');
    });
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => detailViewModel,
      child: _videoScreenContent(context),
    );
  }

  Widget _buildVideoPlayer() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  _videoScreenContent(BuildContext context) {
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
          return FutureBuilder<AssetEntity?>(
            future: AssetMapper.transformMediaToAssetEntity(galleryViewModel.medias[index]),
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
                  child: _buildVideoPlayer(assetSnapshot.data),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              // If the video is paused, play it.
              _controller.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
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
                    print(detailViewModel.currentMedia.name);
                  }),
                  buildActionButton(Icons.delete, 'Delete', onPressed: () {}),
                  buildActionButton(Icons.crop, 'Crop', onPressed: () {
                    // Navigate to crop screen
                  }),
                  buildActionButton(Icons.filter_vintage_outlined, 'Filter',
                      onPressed: () {
                    // Navigate to filter screen
                    showMenu(
                      context: context,
                      position: const RelativeRect.fromLTRB(
                          100, 600, 8, 0), // Vị trí của menu popup
                      items: [
                        const PopupMenuItem(
                          child: Text('Thêm album'),
                          value: 1,
                        ),
                        const PopupMenuItem(
                          child: Text('Option 2'),
                          value: 2,
                        ),
                      ],
                      // Xử lý sự kiện khi một mục trong menu được chọn
                      // Ở đây chúng ta in ra giá trị của mục được chọn
                      // Bạn có thể thay đổi hành động này theo nhu cầu của mình
                    ).then((value) {
                      if (value == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddAlbumScreen()),
                        );
                      }
                    });
                  }),
                  buildActionButton(Icons.more_vert, 'Move',
                      onPressed: () async {
                    // Handle more actions
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddAlbumScreen(),
                      ),
                    );
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
    super.dispose();
    _controller.dispose();
  }
}
