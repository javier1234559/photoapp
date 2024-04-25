import 'package:flutter/material.dart';
import 'package:photoapp/domain/model/media.dart';

class CropScreen extends StatefulWidget {
  static String appBarName = "Crop";
  static String routeName = "/crop";

  final Media media;
  const CropScreen({super.key, required this.media});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
