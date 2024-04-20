import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photoapp/screens/crop_screen.dart';
import 'package:photoapp/screens/filter_screen.dart';
import 'package:share_plus/share_plus.dart';

class DetailScreen extends StatefulWidget {
  final AssetEntity asset;
  var _isFavorite = false;

  DetailScreen({super.key, required this.asset});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Widget _buildActionButton(IconData icon, String title,
      {required VoidCallback onPressed}) {
    return InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                color: icon == Icons.favorite && widget._isFavorite
                    ? Color.fromARGB(255, 255, 81, 81)
                    : Colors.grey),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(color: Colors.white70),
            ),
          ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.transparent,
        title: Text(widget.asset.title ?? 'Detail Image'),
      ),
      backgroundColor: Colors.black26,
      body: Center(
        child: Hero(
          tag: widget.asset.id, // Unique tag for Hero widget
          child: AssetEntityImage(
            widget.asset,
            isOriginal: true, // Load the original image
            fit: BoxFit.contain,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black26,
        child: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.share, 'Share', onPressed: () async {
                  final File? file = await widget.asset.file;
                  final String fullPath = file!.path;
                  final result = await Share.shareXFiles([XFile(fullPath)]);
                  if (result.status == ShareResultStatus.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for sharing my website!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }),
                _buildActionButton(Icons.favorite, 'Love', onPressed: () {
                  setState(() {
                    widget._isFavorite = !widget._isFavorite;
                  });
                }),
                _buildActionButton(Icons.delete, 'Delete', onPressed: () {}),
                _buildActionButton(Icons.crop, 'Crop', onPressed: () {
                  Navigator.of(context).pushNamed('/crop');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CropScreen(asset: widget.asset),
                    ),
                  );
                }),
                _buildActionButton(Icons.filter_vintage_outlined, 'Filter',
                    onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FilterScreen(asset: widget.asset),
                    ),
                  );
                }),
                // Add more action buttons here
                _buildActionButton(Icons.more_vert, 'More', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
