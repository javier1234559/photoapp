import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class CropScreen extends StatefulWidget {
  static String appBarName = "Crop";
  static String routeName = "/crop";

  final AssetEntity asset;
  const CropScreen({super.key, required this.asset});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
