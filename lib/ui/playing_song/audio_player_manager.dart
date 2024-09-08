import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class DurationState {
  final Duration progress;
  final Duration buffer;
  final Duration? total;

  DurationState({
    required this.progress,
    required this.buffer,
    required this.total,
  });
}

class AudioPlayerManager {
  late String songUrl;
  AudioPlayer? audioPlayer;
  Stream<DurationState>? durationState;

  AudioPlayerManager({required this.songUrl});

  void init() {
    audioPlayer = AudioPlayer();
    audioPlayer!.setUrl(songUrl);

    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        audioPlayer!.positionStream,
        audioPlayer!.playbackEventStream,
        (position, playbackEvent) =>
            DurationState(progress: position, buffer: playbackEvent.bufferedPosition, total: playbackEvent.duration));
  }

  void dispose() {
    audioPlayer?.dispose();
  }

  void updateSongUrl(String url) {
    dispose();
    songUrl = url;
    init();
  }
}
