import 'package:music_app/data/source/source.dart';

import '../model/song.dart';

abstract interface class Repository {
  Future<List<Song>> loadSongs();
}

class DefaultRepository implements Repository {
  final _localDataSource = LocalDataSource();
  final _remoteDataSource = RemoteDataSource();

  @override
  Future<List<Song>> loadSongs() async {
    List<Song> songs = [];

    List<Song>? remoteSongs = await _remoteDataSource.loadSongs();
    if (remoteSongs != null) {
      songs.addAll(remoteSongs);
    } else {
      List<Song>? localSongs = await _localDataSource.loadSongs();
      songs.addAll(localSongs ?? []);
    }
    return songs;
  }
}
