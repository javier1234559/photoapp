import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/presentation/viewmodel/detail_screen_view_model.dart';
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
    final viewModel = Provider.of<DetailScreenViewModel>(context);

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
      body: Center(
        child: Hero(
          tag: viewModel.currentMedia.id, // Unique tag for Hero widget
          child: Image.file(
            File(viewModel.currentMedia
                .path), // Assuming you have the file path of the viewModel.currentMedia
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
                buildActionButton(Icons.filter_vintage_outlined, 'Filter',
                    onPressed: () {
                  // Navigate to filter screen
                }),
                buildActionButton(Icons.more_vert, 'More', onPressed: () async {
                  // Handle more actions
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
