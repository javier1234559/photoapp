import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import 'detail_image_screen.dart';

class GalleryScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<AssetEntity>? _images;

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) => _loadRecentImages());
  }

  Future<void> _loadRecentImages() async {
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true);
    final AssetPathEntity album = albums.firstWhere((element) => element.isAll);
    final List<AssetEntity> assets = await album.getAssetListRange(start: 0, end: 100); // Adjust the range as needed
    setState(() {
      _images = assets; // Store AssetEntity objects
    });
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.photos.status;
    if (!status.isGranted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.camera,
      ].request();
      print(statuses[Permission.storage]);
      await Permission.photos.request();
    }
  }

  void openDetailImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailImageScreen(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: _images?.length ?? 0,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // Number of columns
        crossAxisSpacing: 5, // Spacing between columns
        mainAxisSpacing: 5, // Spacing between rows
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => openDetailImage(
              "https://t3.ftcdn.net/jpg/02/68/55/60/360_F_268556012_c1WBaKFN5rjRxR2eyV33znK4qnYeKZjm.jpg"),
          child: Container(
            width: 60,
            height: 60,
            child: ClipRect(
              child: AssetEntityImage(
                _images![index],
                isOriginal: false,
                fit: BoxFit.cover,
                thumbnailSize: const ThumbnailSize.square(200),
                thumbnailFormat:ThumbnailFormat.jpeg, // Preferred thumbnail format
              ),
            ),
          ),
        );
      },
    );
  }
}
