import 'package:flutter/material.dart';
import 'package:photoapp/data/dao/media_dao.dart';
import 'package:photoapp/data/dao/tag_dao.dart';
import 'package:photoapp/data/db_helper.dart';
import 'package:photoapp/domain/media_repository.dart';
import 'package:photoapp/domain/model/media.dart';
import 'package:photoapp/domain/model/tag.dart';
import 'package:photoapp/utils/logger.dart';
import 'package:photoapp/utils/permission.dart';

class SearchViewModel extends ChangeNotifier {
  late MediaLocalRepository mediaLocalRepository;
  List<Tag> _selectedHashtags = [];
  List<Media> _searchedMedias = [];
  List<Media> _medias = [];

  List<Media> get searchedMedias => _searchedMedias;

  set searchedMedias(List<Media> value) {
    _searchedMedias = value;
    notifyListeners();
  }

  List<Tag> get selectedHashtags => _selectedHashtags;

  set selectedMedias(List<Tag> value) {
    _selectedHashtags = value;
    notifyListeners();
  }

  List<Media> get medias => _medias;

  set medias(List<Media> value) {
    _medias = value;
    notifyListeners();
  }

  SearchViewModel() {
    LoggingUtil.logInfor('Initializing SearchViewModel...');
    loadRecentMedia();
    notifyListeners();
  }

  _initialDatabase() async {
    final appDatabase = await DBHelper.getInstance();
    MediaDao mediaDao = appDatabase.mediaDao;
    TagDao tagDao = appDatabase.tagDao;
    mediaLocalRepository =
        MediaLocalRepository(mediaDao: mediaDao, tagDao: tagDao);
  }

  Future<List<Media>> loadRecentMedia({offset = 0, limit = 200}) async {
    await PermissionHandler.requestPermissions();
    await _initialDatabase();
    List<Media> assetMedias =
        await mediaLocalRepository.getAllMedia(offset, limit);
    medias = await filterMediaInRecycleBin(assetMedias);
    searchedMedias = medias;
    LoggingUtil.logInfor('Media Search loaded: ${medias.length} items');
    return medias;
  }

  Future<List<Media>> filterMediaInRecycleBin(List<Media> assetMedias) async {
    List<Media> medias = await mediaLocalRepository.getAllMedia(0, 200);
    medias = medias.where((element) => element.isDelete == false).toList();

    if (medias.isEmpty) {
      //if there is no media in databasse
      return assetMedias;
    }

    return assetMedias
        .where((element) => medias.any((media) => media.id == element.id))
        .toList();
  }

  List<Tag> getSetTags() {
    List<Tag> tags = [];
    for (var media in _medias) {
      tags.addAll(media.tags);
    }
    return tags.toSet().toList();
  }

  void searchMediaByName(String name) async {
    if (name.isEmpty) {
      searchedMedias = medias;
      return;
    }

    List<Media> filterSearch = medias
        .where((element) =>
            element.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
    LoggingUtil.logInfor(
        'Search for name: $name, found ${medias.length} items');
    searchedMedias = filterSearch;
    notifyListeners();
  }

  void searchMediaByDate(String selectedOption) {
    DateTime now = DateTime.now();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();

    switch (selectedOption) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 7));
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(days: 1));
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        endDate =
            DateTime(now.year + 1, 1, 1).subtract(const Duration(days: 1));
        break;
      default:
        searchedMedias = medias;
        return;
    }

    searchedMedias = medias.where((media) {
      if (media.dateModifiedTimestamp != null) {
        LoggingUtil.logError(
            'dateModifiedTimestamp: ${media.dateModifiedTimestamp}');
        DateTime modifiedDate = DateTime.fromMillisecondsSinceEpoch(
            media.dateModifiedTimestamp! ~/ 1000);
        return modifiedDate.isAfter(startDate) &&
            modifiedDate.isBefore(endDate);
      }
      return false;
    }).toList();

    notifyListeners();
  }

  void searchMediaByTag() async {
    if (_selectedHashtags.isEmpty) {
      searchedMedias = medias;
      return;
    }

    List<Media> filterSearch = medias
        .where(
            (media) => media.tags.any((tag) => selectedHashtags.contains(tag)))
        .toList();
    LoggingUtil.logInfor(
        'Search for tag: , found ${filterSearch.length} items');
    searchedMedias = filterSearch;
    notifyListeners();
  }

  void updateMediaTag(Tag tag) {
    if (selectedHashtags.contains(tag)) {
      selectedHashtags.remove(tag);
    } else {
      selectedHashtags.add(tag);
    }
    notifyListeners();
  }
}
