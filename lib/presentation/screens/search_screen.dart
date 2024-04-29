import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/presentation/screens/gallery_screen.dart';
import 'package:photoapp/presentation/viewmodel/album_view_model.dart';
import 'package:photoapp/presentation/viewmodel/gallery_view_model.dart';
import 'package:photoapp/utils/logger.dart';

class SearchScreen extends StatefulWidget {
  static String appBarName = "Search";
  static String routeName = "/search";
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // late AlbumViewModel _albumViewModel;
  late GalleryViewModel _galleryViewModel;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _albumViewModel = AlbumViewModel();
    _galleryViewModel = GalleryViewModel();
  }

  // Example data for the search results
  List<String> searchResultsWithTags = ['Tag1', 'Tag2', 'Tag3'];
  List<String> searchResultsWithAlbums = ['Album1', 'Album2', 'Album3'];

  // Example data for the date filter
  List<String> dateOptions = ['Today', 'This Week', 'This Month', 'This Year'];
  String? selectedDateOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        print(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  FloatingActionButton(
                    onPressed: () {
                      final String value = _controller.text;
                      LoggingUtil.logInfor('Button clicked with value: $value');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Submitted value: $value'),
                        ),
                      );
                    },
                    child: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
            // Date Filter
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDateOption ??
                          dateOptions
                              .first, // Set a default value when selectedDateOption is null
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDateOption = newValue;
                        });
                      },
                      items: dateOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            // Search Results Rows
            Expanded(
              child: Column(
                children: [
                  // // Search Results with Tags
                  // _buildSearchResultsAlbum(
                  //   title: 'Search result with albums',
                  //   items: _albumViewModel.albums,
                  // ),
                  // Search Results with Medias
                  _buildSearchResultsMedia(
                    title: 'Search with media files',
                    medias: _galleryViewModel.medias,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsMedia(
      {required String title, required List<Media> medias}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: medias.length,
            itemBuilder: (context, index) {
              final media = medias[index];
              return ListTile(
                title: Text(media.name),
                subtitle: Text(media.path),
                leading: Image.file(File(media.path)),
                onTap: () {
                  // Navigate to the detail screen
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
