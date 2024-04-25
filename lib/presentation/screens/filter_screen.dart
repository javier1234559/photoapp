import 'package:flutter/material.dart';
import 'package:photoapp/domain/model/media.dart';

class FilterScreen extends StatefulWidget {
  final Media media;
  static String appBarName = "Filter";
  static String routeName = "/filter";
  const FilterScreen({super.key, required this.media});

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
      // body: Center(
      //   child: Hero(
      //     tag: widget.media.id, // Unique tag for Hero widget
      //     child: mediaEntityImage(
      //       widget.media,
      //       isOriginal: true, // Load the original image
      //       fit: BoxFit.contain,
      //     ),
      //   ),
      // ),
    );
  }
}
