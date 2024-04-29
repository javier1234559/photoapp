import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static String appBarName = "Search";
  static String routeName = "/search";
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        print(value);
                        // Implement search functionality here
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  FloatingActionButton(
                    onPressed: () {
                      // Implement search functionality here
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
                  // Search Results with Tags
                  _buildSearchResultsRow(
                    title: 'Search result with tags',
                    items: searchResultsWithTags,
                  ),
                  // Search Results with Albums
                  _buildSearchResultsRow(
                    title: 'Search with Album',
                    items: searchResultsWithAlbums,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsRow(
      {required String title, required List<String> items}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
