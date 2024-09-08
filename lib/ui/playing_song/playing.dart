import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/ui/playing_song/media_button_controller.dart';

import 'audio_player_manager.dart';

class PlayingSong extends StatelessWidget {
  final Song playingSong;
  final List<Song> songs;

  const PlayingSong({super.key, required this.playingSong, required this.songs});

  @override
  Widget build(BuildContext context) {
    return PlayingSongPage(songs: songs, playingSong: playingSong);
  }
}

class PlayingSongPage extends StatefulWidget {
  final Song playingSong;
  final List<Song> songs;

  const PlayingSongPage({super.key, required this.playingSong, required this.songs});

  @override
  State<PlayingSongPage> createState() => _PlayingSongPageState();
}

class _PlayingSongPageState extends State<PlayingSongPage> with SingleTickerProviderStateMixin {
  late Song _song;
  late int _playSoundIndex;
  late double _progressAnimation;
  late AudioPlayerManager _audioPlayerManager;
  late AnimationController _imageAnimationController;

  @override
  void initState() {
    super.initState();

    _progressAnimation = 0.0;
    _song = widget.playingSong;
    _playSoundIndex = widget.songs.indexOf(widget.playingSong);

    _audioPlayerManager = AudioPlayerManager(songUrl: _song.source);
    _audioPlayerManager.init();
    //
    _imageAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 12000));
  }

  @override
  void dispose() {
    _audioPlayerManager.dispose();
    _imageAnimationController.dispose();

    super.dispose();
  }

  StreamBuilder<DurationState> _getWidgetProgressBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffer ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;

          return ProgressBar(
            total: total,
            progress: progress,
            buffered: buffered,
            barHeight: 5.0,
            barCapShape: BarCapShape.round,
            baseBarColor: Colors.grey.withOpacity(0.5),
            bufferedBarColor: Colors.grey.withOpacity(0.3),
            thumbColor: Theme.of(context).colorScheme.primary,
            progressBarColor: Theme.of(context).colorScheme.primary,
            onSeek: (seek) {
              _audioPlayerManager.audioPlayer?.seek(seek);
            },
          );
        });
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayerManager.audioPlayer!.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final progressingState = playState?.processingState;
        final playing = playState?.playing ?? false;

        if (progressingState == ProcessingState.loading || progressingState == ProcessingState.buffering) {
          _pauseRotationAnim();
          return Container(
              margin: const EdgeInsets.all(8), width: 48, height: 48, child: const CircularProgressIndicator());
        } else if (!playing) {
          return MediaButtonController(
              icon: Icons.play_arrow,
              color: null,
              size: 48,
              func: () {
                _audioPlayerManager.audioPlayer?.play();
              });
        } else if (progressingState != ProcessingState.completed) {
          _playRotationAnim();
          return MediaButtonController(
              icon: Icons.pause,
              color: null,
              size: 48,
              func: () {
                _audioPlayerManager.audioPlayer?.pause();
                _pauseRotationAnim();
              });
        } else {
          if (progressingState == ProcessingState.completed) {
            _stopRotationAnim();
            _resetRotationAnim();
          }
          return MediaButtonController(
              icon: Icons.replay,
              color: null,
              size: 48,
              func: () {
                _audioPlayerManager.audioPlayer?.seek(Duration.zero);
                _resetRotationAnim();
                _playRotationAnim();
              });
        }
      },
    );
  }

  void _nextSongButton() {
    if (_playSoundIndex == widget.songs.length - 1) {
      _playSoundIndex = 0;
    } else {
      ++_playSoundIndex;
    }

    final nextSong = widget.songs[_playSoundIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);

    _resetRotationAnim();
    setState(() {
      _song = nextSong;
    });
  }

  void _prevSongButton() {
    if (_playSoundIndex == 0) {
      _playSoundIndex = widget.songs.length - 1;
    } else {
      --_playSoundIndex;
    }

    final nextSong = widget.songs[_playSoundIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);

    _resetRotationAnim();
    setState(() {
      _song = nextSong;
    });
  }

  void _playRotationAnim() {
    _imageAnimationController.forward(from: _progressAnimation);
    _imageAnimationController.repeat();
  }

  void _pauseRotationAnim() {
    _stopRotationAnim();
    _progressAnimation = _imageAnimationController.value;
  }

  void _stopRotationAnim() {
    _imageAnimationController.stop();
  }

  void _resetRotationAnim() {
    _progressAnimation = 0.0;
    _imageAnimationController.value = _progressAnimation;
  }

  Widget _getWidgetMediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const MediaButtonController(icon: Icons.shuffle, color: Colors.deepPurple, size: 24, func: null),
          MediaButtonController(icon: Icons.skip_previous, color: Colors.deepPurple, size: 36, func: _prevSongButton),
          _playButton(),
          MediaButtonController(icon: Icons.skip_next, color: Colors.deepPurple, size: 36, func: _nextSongButton),
          const MediaButtonController(icon: Icons.repeat, color: Colors.deepPurple, size: 24, func: null),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const delta = 64;
    final screenWidth = MediaQuery.of(context).size.width;
    final radius = screenWidth - delta;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Now Playing"),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_song.album),
              const Text("_ ___ _"),
              const SizedBox(height: 16),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_imageAnimationController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    image: _song.image,
                    placeholder: 'assets/itunes_logo.png',
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/itunes_logo.png',
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 48, bottom: 16),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            _song.title,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium!.color,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _song.artist,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium!.color,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_outline),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 16),
                child: _getWidgetProgressBar(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: _getWidgetMediaButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
