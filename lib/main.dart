import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:multiplay/globals/common.dart';
import 'package:multiplay/models/mixer_state.dart';
import 'package:multiplay/models/track_models.dart';
import 'package:multiplay/tools/write_to_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:file_selector/file_selector.dart';

import 'package:multiplay/components/track.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'dart:io';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => Mixer(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // print(context.watch<Mixer>().tracks.length);

    initializeApp(context);
    return MaterialApp(
      title: 'Multiplay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
          border: InputBorder.none,
          fillColor: Colors.white60,
          filled: true,
        ),
        iconTheme: IconThemeData(),
      ),
      home: MyHomePage(title: 'Multiplay'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TrackInstance> _trackGroup = [];
  String _status = '';
  bool _playing = false;
  ShellLinesController _newController = ShellLinesController();
  Shell? _newShell;
  StreamSubscription? _shellStream;

  void _addTrack() async {
    Provider.of<Mixer>(context, listen: false).openMkaFile();
  }

  void _exportTracks() async {
  }

  void _initShell() {
    _newShell = Shell(stdout: _newController.sink, verbose: true);
    _shellStream = _newController.stream.listen((event) {
      print('yeah');
      print(event);
    });
  }

  void _shellFunction() async {
    // var ffmpeg = await Cachin('assets/ffmpeg');

    await _newShell?.run('''
    ls
    ls -l
    ls -l "${toolsDir.path}"
    ''');

  }

  void _reOrder(oldIndex, newIndex) {
    int trackLength = _trackGroup.length;
    int index = newIndex >= trackLength ? (trackLength - 1) : newIndex;
    TrackInstance moving = _trackGroup.removeAt(oldIndex);
    _trackGroup.insert(index, moving);
  }

  void initState() {
    _initShell();
    super.initState();
  }

  void dispose() {
    _shellStream?.cancel();
  }


  // TODO: make some sort of status bar, so I can inform about dependency downloads &
  // Todo: check for internet connection, etc
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Color.fromRGBO(0, 0, 0, 0.08)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 25.0),
                  child: () {
                    if (context.watch<Mixer>().tracks.length == 0) {
                      return SizedBox(
                        height: 390.0,
                        child: Center(
                          child: Text(
                            'Press the plus button to add a track!',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      );
                    }
                    return ReorderableListView.builder(
                      onReorder:
                          Provider.of<Mixer>(context, listen: false).moveTrack,
                      itemCount: context.watch<Mixer>().tracks.length,

                      itemBuilder: (context, index) {
                        TrackInstance ti = context.watch<Mixer>().tracks[index];
                        // return ti.track;
                        return Row(
                          key: ValueKey(ti),
                          children: [
                            SizedBox(
                                width:
                                    (MediaQuery.of(context).size.width - 150),
                                child: ti.track),
                            SizedBox(
                              width: 50.0,
                              height: 50.0,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    Provider.of<Mixer>(context, listen: false).removeTrack(index);
                                  });
                                },
                                icon: Icon(Icons.cancel),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }(),
                ),
                height: 440.0,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        children: [
          SizedBox(
            width: 30.0,
          ),
          Text(_status),
          Spacer(),
          // FloatingActionButton(
          //   onPressed: _shellFunction,
          //   tooltip: 'Shell Attempt',
          //   child: Icon(Icons.code),
          // ),
          SizedBox(
            width: 15.0,
          ),
          FloatingActionButton(
            onPressed: () {
              Provider.of<Mixer>(context, listen: false).play();
              setState(() {
                _playing = true;
              });
            },
            tooltip: 'Play',
            child: Icon(Icons.play_arrow),
          ),
          SizedBox(
            width: 15.0,
          ),
          FloatingActionButton(
            onPressed: _addTrack,
            tooltip: 'Add Track',
            child: Icon(Icons.add),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
