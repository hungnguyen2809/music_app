import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/account/account.dart';
import 'package:music_app/ui/discovery/discovery.dart';
import 'package:music_app/ui/home/home.dart';
import 'package:music_app/ui/settings/settings.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const MusicAppRoot(),
    );
  }
}

class MusicAppRoot extends StatefulWidget {
  const MusicAppRoot({super.key});

  @override
  State<MusicAppRoot> createState() => _MusicAppRootState();
}

class _MusicAppRootState extends State<MusicAppRoot> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text("Music App"),
        ),
        child: CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.album), label: "Discovery"),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
              ],
            ),
            tabBuilder: (BuildContext context, int index) {
              return _tabs[index];
            }));
  }
}
