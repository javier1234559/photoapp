import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class FilterScreen extends StatefulWidget {
  final AssetEntity asset;
  static String appBarName = "Filter";
  static String routeName = "/filter";
  const FilterScreen({super.key, required this.asset});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.transparent,
        title: Text(FilterScreen.appBarName),
      ),
      // backgroundColor: Colors.black26,
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
    );
  }
}
