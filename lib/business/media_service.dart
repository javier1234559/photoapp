import 'package:photo_manager/photo_manager.dart';
import 'package:photoapp/database/media_dao.dart';
import 'package:photoapp/database/models/media.dart';

class MediaService {
  final MediaDao mediaDao;

  MediaService({required this.mediaDao});

  getAllMedia() async {
    
  }

  getMediaPaginated(int offset, int limit) async {
    // return mediaDao.getAllMedia(offset, limit);
  }


}
