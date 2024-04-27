import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photoapp/data/mapper/asset_mapper.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/presentation/screens/add_album_screen.dart';
import 'package:photoapp/presentation/viewmodel/detail_screen_view_model.dart';
import 'package:photoapp/presentation/viewmodel/gallery_view_model.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class DetailScreen extends StatefulWidget {
  final Media media;

  const DetailScreen({super.key, required this.media});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DetailScreenViewModel(widget.media),
      child: _DetailScreenContent(),
    );
  }
}

class _DetailScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DetailScreenViewModel viewModel =
        Provider.of<DetailScreenViewModel>(context);

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
                color: icon == Icons.favorite && viewModel.isFavorite
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

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.transparent,
        title: Text(viewModel.currentMedia.name),
      ),
      backgroundColor: Colors.black26,
      body: Consumer<GalleryViewModel>(
        builder: (context, galleryViewModel, child) {
          return PageView.builder(
            itemCount: galleryViewModel.medias.length,
            itemBuilder: (context, index) {
              return FutureBuilder<AssetEntity?>(
                future: AssetMapper.transformMediaToAssetEntity(
                    galleryViewModel.medias[index]),
                builder: (BuildContext context,
                    AsyncSnapshot<AssetEntity?> assetSnapshot) {
                  if (assetSnapshot.connectionState ==
                      ConnectionState.waiting) {
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
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black26,
        child: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildActionButton(Icons.share, 'Share', onPressed: () async {
                  await Share.share(viewModel.currentMedia.path);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for sharing with others!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }),
                buildActionButton(Icons.favorite, 'Love', onPressed: () async {
                  await viewModel.toggleFavorite();
                }),
                buildActionButton(Icons.delete, 'Delete', onPressed: () {}),
                buildActionButton(Icons.crop, 'Crop', onPressed: () {
                  // Navigate to crop screen
                }),
                buildActionButton(Icons.filter_vintage_outlined, 'Filter', onPressed: () {
                  // Navigate to filter screen
                  showMenu(
                        context: context,
                        position: const RelativeRect.fromLTRB(100, 600, 8, 0), // Vị trí của menu popup
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
                            MaterialPageRoute(builder: (context) => AddAlbumScreen()),
                          );
                        }
                      });
                }),
                buildActionButton(Icons.more_vert, 'Move', onPressed: () async {
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
      ),
    );
  }
}
