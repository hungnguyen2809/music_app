import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:music_app/data/model/song.dart';
import 'package:http/http.dart' as http;

abstract interface class DataSource {
  Future<List<Song>?> loadSongs();
}

class LocalDataSource extends DataSource {
  @override
  Future<List<Song>?> loadSongs() async {
    final response = await rootBundle.loadString('assets/songs.json');
    var songWrapper = jsonDecode(response) as Map;
    var songList = songWrapper['songs'] as List;
    List<Song> songs = songList.map((song) => Song.fromJson(song)).toList();
    return songs;
  }
}

class RemoteDataSource extends DataSource {
  final urlRemote = 'https://thantrieu.com/resources/braniumapis/songs.json';

  @override
  Future<List<Song>?> loadSongs() async {
    final uri = Uri.parse(urlRemote);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final bodyContent = utf8.decode(response.bodyBytes);
      var songWrapper = jsonDecode(bodyContent) as Map;
      var songList = songWrapper['songs'] as List;
      List<Song> songs = songList.map((song) => Song.fromJson(song)).toList();
      return songs;
    } else {
      return null;
    }
  }
}
