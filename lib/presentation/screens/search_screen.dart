import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/domain/model/tag.dart';
import 'package:photoapp/presentation/screens/detail_screen.dart';
import 'package:photoapp/presentation/viewmodel/search_view_model.dart';
import 'package:photoapp/utils/constants.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  static String appBarName = "Search";
  static String routeName = "/search";
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> dateOptions = [
    'No Date',
    'Today',
    'This Week',
    'This Month',
    'This Year'
  ];
  String? selectedDateOption;

  @override
  void initState() {
    super.initState();
  }

  void _openDetailScreen(Media media) async {
    bool isRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(media: media),
      ),
    ) as bool;

    if (isRefresh) {
      Navigator.pushNamed(context, '/gallery');
    }
  }

  Widget _buildThumbnail(Media media) {
    return FutureBuilder<Widget>(
      future: _generateThumbnail(media),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return snapshot.data!;
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<Widget> _generateThumbnail(Media media) async {
    AssetEntity? asset = await AssetEntity.fromId(media.id);

    if (media.type == AssetType.video.name.toString()) {
      LoggingUtil.logDebug('Video thumbnail: ${media.path}');
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AssetEntityImage(
            asset!,
            isOriginal: false,
            fit: BoxFit.cover,
            thumbnailSize: const ThumbnailSize.square(200),
            thumbnailFormat: ThumbnailFormat.jpeg,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 12.0,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      media.duration.toString(),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12.0),
                    ),
                  ],
                ),
                const SizedBox(height: 5), // Add space to the bottom of the Row
              ],
            ),
          )
        ],
      );
    } else {
      return AssetEntityImage(
        asset!,
        isOriginal: false,
        fit: BoxFit.cover,
        thumbnailSize: const ThumbnailSize.square(200),
        thumbnailFormat: ThumbnailFormat.jpeg,
      );
    }
  }

  Widget searchButtonWidget() {
    return Consumer<SearchViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0),
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
                    LoggingUtil.logWarning('Submitted value: $value');
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              FloatingActionButton(
                onPressed: () {
                  final String value = _controller.text;

                  // Use the searchMediaByName method
                  viewModel.searchMediaByName(value);

                  LoggingUtil.logWarning('Submitted value: $value');

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
        );
      },
    );
  }

  Widget listOfTagsWidget() {
    return Consumer<SearchViewModel>(
      builder: (context, viewModel, child) {
        List<Tag> mediaTags = viewModel.getSetTags();

        return Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0),
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mediaTags.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    viewModel.updateMediaTag(mediaTags[index]);
                    viewModel.searchMediaByTag();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                    decoration: BoxDecoration(
                      color:
                          viewModel.selectedHashtags.contains(mediaTags[index])
                              ? kPrimaryColor
                              : null,
                      border: Border.all(
                        color: viewModel.selectedHashtags
                                .contains(mediaTags[index])
                            ? Colors.black
                            : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      '#${mediaTags[index].name}',
                      style: TextStyle(
                        color: viewModel.selectedHashtags
                                .contains(mediaTags[index])
                            ? Colors.black
                            : kPrimaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget dateFilterWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: DropdownButtonHideUnderline(
            child: Consumer<SearchViewModel>(
              builder: (context, viewModel, child) {
                return DropdownButton<String>(
                  value: selectedDateOption ?? dateOptions.first,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDateOption = newValue;
                    });
                    viewModel.searchMediaByDate(newValue!);
                  },
                  items:
                      dateOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchViewModel(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Search Button
              searchButtonWidget(),
              // Tags Filter
              listOfTagsWidget(),
              // Date Filter
              dateFilterWidget(),
              // Search Results Rows
              Expanded(
                child: Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 2.0, right: 2.0),
                    child: Consumer<SearchViewModel>(
                      builder: (context, viewModel, child) {
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: viewModel.searchedMedias.length,
                          itemBuilder: (context, index) {
                            if (viewModel.searchedMedias.isEmpty) {
                              return const Center(
                                  child: Text('No media found'));
                            }

                            return GestureDetector(
                              onTap: () => {
                                _openDetailScreen(
                                    viewModel.searchedMedias[index])
                              },
                              child: Container(
                                child: _buildThumbnail(
                                    viewModel.searchedMedias[index]),
                              ),
                            );
                          },
                        );
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
