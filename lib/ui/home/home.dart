import 'package:flutter/material.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/ui/home/view_model.dart';

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
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observeData();
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    super.dispose();
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

  Widget getRowItem(BuildContext context, int position) {
    return Center(
      child: Text(_songs.elementAt(position).title),
    );
  }

  Widget getDiverItem(BuildContext context, int position) {
    return const Divider(color: Colors.grey, thickness: 1, indent: 24, endIndent: 24);
  }
}

class _SongItemSection {
  _SongItemSection({
    required this.song,
    required this.parent,
  });

  final Song song;
  final _HomeTabPageState parent;
}
