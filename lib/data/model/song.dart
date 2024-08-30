class Song {
  String id;
  String title;
  String album;
  String artist;
  String source;
  String image;
  int duration;
  String favorite;
  int counter;
  int replay;

  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.source,
    required this.image,
    required this.duration,
    required this.favorite,
    required this.counter,
    required this.replay,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      album: json['album'],
      artist: json['artist'],
      source: json['source'],
      image: json['image'],
      duration: json['duration'],
      favorite: json['favorite'],
      counter: json['counter'],
      replay: json['replay'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song{id: $id, title: $title, album: $album, artist: $artist, source: $source, image: $image, duration: $duration, favorite: $favorite, counter: $counter, replay: $replay}';
  }
}
