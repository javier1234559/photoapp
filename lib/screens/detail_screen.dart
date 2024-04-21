import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photoapp/database/album_dao.dart';
import 'package:photoapp/database/db_helper.dart';
import 'package:photoapp/database/media_album_dao.dart';
import 'package:photoapp/database/media_dao.dart';
import 'package:photoapp/models/album.dart';
import 'package:photoapp/models/media.dart';
import 'package:photoapp/models/media_album.dart';
import 'package:photoapp/screens/crop_screen.dart';
import 'package:photoapp/screens/filter_screen.dart';
import 'package:share_plus/share_plus.dart';

class DetailScreen extends StatefulWidget {
  final AssetEntity asset;

  const DetailScreen({super.key, required this.asset});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final AlbumDao albumDao;
  late final MediaDao mediaDao;
  late final MediaAlbumDao mediaAlbumDao;
  late Media media;
  late final ScaffoldMessengerState scaffoldMessenger;
  var _isFavorite = false;

  @override
  void initState() {
    super.initState();

    // Obtain the singleton instance of AppDatabase
    initializeDatabase();

    // Construct a Media object
    media = Media.fromAssetEntityId(widget.asset.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scaffoldMessenger = ScaffoldMessenger.of(context);
    // Remember: Accessing inherited widgets like ScaffoldMessenger in initState() can cause errors.
    // Use didChangeDependencies() instead, as it's called after initState() and when dependencies change,
    // ensuring the widget tree is fully built and inherited widgets are available.
  }

// Initialize database and obtain DAOs
  Future<void> initializeDatabase() async {
    final appDatabase = await DBHelper.getInstance();
    albumDao = appDatabase.albumDao;
    mediaDao = appDatabase.mediaDao;
    mediaAlbumDao = appDatabase.mediaAlbumDao;
  }

  void toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void test() async {
    List<Media> test1 = await mediaDao.findAllMedia();
    print(test1.length);
    print(test1[0].assetEntityId.toString());
    List<MediaAlbum> test2 = await mediaAlbumDao.findAllMediaAlbum();
    print(test2.length);
    print(test2[0].id.toString());
  }

  Future<void> updateMediaToLoveAlbum(Media media, bool isLove) async {
    try {
      final List<Album> loveAlbums = await albumDao.findAlbumByTitle('Love');

      // Check if Love album exists, if not, create it
      if (loveAlbums.isEmpty) {
        final Album loveAlbum = Album(1, 'Love', '', '');
        await albumDao.insertAlbum(loveAlbum);
      }

      // Get the Love album
      final Album loveAlbum = loveAlbums.first;

      int mediaId = int.parse(media.id);
      final MediaAlbum? existingMediaAlbum =
          await mediaAlbumDao.findExistMediaFromAlbum(loveAlbum.title, mediaId);

      if (isLove) {
        // If it's liked, add the media to the Love album
        if (existingMediaAlbum == null) {
          // Save the media to the database
          await mediaDao.insertMedia(media);

          MediaAlbum mediaAlbum = MediaAlbum(null, loveAlbum.id, mediaId);
          await mediaAlbumDao.insertMediaToAlbum(mediaAlbum);
          test();
          // Print success message
          print('Media added to Love album successfully.');
        } else {
          print('Media is already in Love album.');
        }
      } else {
        test();
        print(existingMediaAlbum.toString());
        // If it's unliked, remove the media from the Love album if it exists
        if (existingMediaAlbum != null) {
          // If the media is in the Love album, remove it
          await mediaDao.deleteMedia(media);
          await mediaAlbumDao.deleteMediaFromAlbum(existingMediaAlbum);

          print('Media removed from Love album successfully.');
        } else {
          // Print message indicating media doesn't exist in the Love album
          print('Media is not in Love album.');
        }
      }
    } catch (e) {
      print('Error updating media to Love album: $e');
    }
  }

  Widget _buildActionButton(IconData icon, String title,
      {required VoidCallback onPressed}) {
    return InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                color: icon == Icons.favorite && _isFavorite
                    ? const Color.fromARGB(255, 255, 81, 81)
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
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for sharing my website!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }),
                _buildActionButton(Icons.favorite, 'Love', onPressed: () async {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });

                  print('Favorite: $_isFavorite');
                  await updateMediaToLoveAlbum(
                      media, _isFavorite); // Await here
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
                _buildActionButton(Icons.more_vert, 'More',
                    onPressed: () async {
                  // final personDao = database.personDao;
                  // final person = Person(1, 'Frank');

                  // await personDao.insertPerson(person);
                  // final result = await personDao.findPersonById(1);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
