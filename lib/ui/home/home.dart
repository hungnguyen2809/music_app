import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/ui/home/view_model.dart';
import 'package:music_app/ui/playing_song/playing.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  final List<Song> _songs = [];
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observeData();
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.songStream.close();
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songs) {
      setState(() {
        _songs.addAll(songs);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  Widget getBody() {
    bool showLoading = _songs.isEmpty;

    if (showLoading) {
      return getProgressbar();
    }

    return getLListView();
  }

  Widget getProgressbar() {
    return const Center(child: CircularProgressIndicator());
  }

  ListView getLListView() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _songs.length,
      itemBuilder: getRowItem,
      separatorBuilder: getDiverItem,
    );
  }

  void navigateTo(Song item) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return PlayingSong(songs: _songs, playingSong: item);
    }));
  }

  void showBottomSheet(Song item) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 400,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Modal bottom sheet"),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget getRowItem(BuildContext context, int position) {
    return Center(
      child: _SongItemSection(song: _songs[position], parent: this),
    );
  }

  Widget getDiverItem(BuildContext context, int position) {
    return const Divider(color: Colors.grey, thickness: 1, indent: 24, endIndent: 24);
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.song,
    required this.parent,
  });

  final Song song;
  final _HomeTabPageState parent;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 24, right: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FadeInImage.assetNetwork(
          width: 48,
          height: 48,
          image: song.image,
          placeholder: 'assets/itunes_logo.png',
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset("assets/itunes_logo.png", width: 48, height: 48);
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
          onPressed: () {
            parent.showBottomSheet(song);
          },
          icon: const Icon(Icons.more_horiz)),
      onTap: () {
        parent.navigateTo(song);
      },
    );
  }
}
