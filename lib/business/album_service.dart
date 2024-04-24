import 'package:photo_manager/photo_manager.dart';
import 'package:photoapp/database/album_dao.dart';
import 'package:photoapp/database/album_dao.dart';
import 'package:photoapp/database/models/album.dart';
import 'package:photoapp/database/models/media.dart';

class AlbumService {
  final AlbumDao albumDao;

  AlbumService({required this.albumDao});

  getAllAlbum() async {
    
  }

  getAlbumPaginated(int offset, int limit) async {
    // return mediaDao.getAllMedia(offset, limit);
  }

  addMediaToAlbum(Album album, Media media) {
    album.addMediaToAlbum(media);
  }


}
