import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:multiplay/components/level_meter.dart';
import 'package:multiplay/components/styled_icon_button.dart';
import 'package:multiplay/globals/common.dart';
import 'package:multiplay/tools/ffmpeg_commands.dart';
import 'package:multiplay/tools/play_commands.dart';
import 'package:multiplay/tools/get_json_attachment.dart';
import 'package:multiplay/tools/toolbox.dart';
import 'package:process_run/shell.dart';

class Track extends StatefulWidget {
  Track(
      {Key? key,
      required this.file,
      this.level = 1.0,
      this.trackName,
      this.cacheCount = 3})
      : super(key: key);

  final XFile file;
  final double level;
  final String? trackName;
  final int cacheCount;

  @override
  TrackState createState() => TrackState();
}

class TrackState extends State<Track> {
  Duration _duration = Duration();
  bool _playing = false;
  bool _rendersReady = false;
  double _playHead = 0;
  List<double> _levels = List<double>.filled(2, -100.0);
  String _currentCommand = '';
  Stopwatch _stopwatch = new Stopwatch();
  Map<String, dynamic>? info;
  StreamSubscription? _stdout;
  StreamSubscription? _stderr;
  Shell? _shell;
  ShellLinesController _stdoutController = ShellLinesController();
  ShellLinesController _stderrController = ShellLinesController();
  Stdin _stdinController = stdin;
  List<String> preRenders = [];

  Future<void> _updateDuration() async {
    double durationInSeconds = await getDuration(widget.file.path, _shell);
    Duration ld = Duration(
        milliseconds: (durationInSeconds * 1000)
            .round()); //await widget.longestDuration();
    print(ld);
    setState(() {
      _duration = ld;
    });
  }

  Future<void> retrieveInfo() async {
    Map<String, dynamic> fileInfo =
        await getJsonAttachment(widget.file.path, _shell);
    print('fileInfo');
    print(fileInfo);
    if (false) return; // ToDO: add validation
    info = fileInfo;
    await preRendersRefill();
    print(preRenders);
  }

  Future<int> preRendersRefill() async {
    Map<String, dynamic>? infoNull = info;
    if (infoNull == null) return 0;
    int fillCount = 0;
    while (preRenders.length < widget.cacheCount) {
      preRenders.add(await makeCachedFile(infoNull, widget.file.path));
      if (preRenders.length == 1) {
        setState(() {
          _rendersReady = true;
        });
      }
      fillCount++;
    }
    return fillCount;
  }

  Future<bool> preRendersClear(int number) async {
    List<String> toTrashPaths = preRenders.getRange(0, number).toList();
    preRenders.removeRange(0, number);
    for (String trashPath in toTrashPaths) {
      File trashFile = new File(trashPath);
      await trashFile.delete();
    }
    if (preRenders.length == 0) {
      setState(() {
        _rendersReady = false;
      });
    }
    return true;
  }

  Future<bool> preRendersShift() async {
    await preRendersClear(1);
    await preRendersRefill();
    return true;
  }

  Duration get duration => _duration;

  @override
  void initState() {
    _asyncInitState();
    super.initState();
  }

  void _asyncInitState() async {
    print(('-' * 100) + '1');
    _initShell();
    print(('-' * 100) + '2');
    await _updateDuration();
    print(('-' * 100) + '3');
    await retrieveInfo();
    // print(('-' * 100) + '4');
  }

  void _renewShell() {
    _shell = Shell(
      workingDirectory: toolsDir.path,
      stdout: _stdoutController.sink,
      stderr: _stderrController.sink,
      // stdin: _stdinController
    );
  }

  void _initShell() {
    _renewShell();
    _stdout = _stdoutController.stream.listen((event) {
      // print('Length: ${event.length}');
    });

    _stderr = _stderrController.stream.listen((event) {
      String eventStr = event.toString();
      String? timeString =
          (RegExp(r'pts_time:([0-9]*.?[0-9]*)').firstMatch(eventStr))?.group(1);
      if (timeString != null) {
        setState(() {
          _playHead = double.parse(timeString);
        });
      }
      String? leftChannel =
          (RegExp(r'lavfi.astats.1.RMS_level=(-?[0-9]*\.?[0-9]*(?:inf)?)')
                  .firstMatch(eventStr))
              ?.group(1);
      if (leftChannel != null) {
        setState(() {
          _levels[0] = leftChannel == '-inf' ? -100 : double.parse(leftChannel);
        });
      }
      String? rightChannel =
          (RegExp(r'lavfi.astats.2.RMS_level=(-?[0-9]*\.?[0-9]*(?:inf)?)')
                  .firstMatch(eventStr))
              ?.group(1);
      if (rightChannel != null) {
        setState(() {
          _levels[1] =
              rightChannel == '-inf' ? -100 : double.parse(rightChannel);
        });
      }

      // print(_levels);
    });

    // _shellStream?.pause();
  }

  bool pause() {
    if (!_playing) return false;
    _shell?.kill();
    _renewShell();
    setState(() {
      _playing = false;
      _levels = [-100, -100];
    });
    return true;
  }

  void playPause() {
    _playPause();
  }

  Future<void> _playPause() async {
    // ToDO: Actual error handling;
    Map<String, dynamic>? infoNull = info;
    if (infoNull == null) return;

    bool paused = pause();
    if (paused) return;

    print('_playhead: $_playHead');
    pauseOtherTracks(context, widget);
    // _listenToShell();

    String command = _playHead == 0
        ? playCommandFromFile(preRenders[0])
        : amendSeekTime(_currentCommand, _playHead);

    setState(() {
      _currentCommand = command;
      _playing = true;
    });
    await _shell?.run(command);
    _stopwatch.stop();
    // _stopListenToShell();
    setState(() {
      _playing = false;
      _playHead = 0;
    });
    preRendersShift();
  }

  void _stop() {
    if (_playing) {
      _shell?.kill();
      _renewShell();
    }
    preRendersShift();

    setState(() {
      _playing = false;
      _playHead = 0;
      _levels = [-100, -100];
    });
  }

  @override
  void dispose() {
    super.dispose();
    _stdout?.cancel();
    _stderr?.cancel();
    preRendersClear(preRenders.length);
  }

  void _testButton() {
    _stdinController.readLineSync();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Row(
            children: [
              (_playHead > 0.0 || _playing)
                  ? StyledIconButton(
                      onPressed: _stop,
                      icon: Icon(Icons.stop_circle_rounded),
                    )
                  : StyledIconButton(
                      onPressed: _stop,
                      icon: Icon(
                        Icons.stop_circle_rounded,
                        color: Colors.grey,
                      ),
                    ),
              SizedBox(
                width: 10.0,
              ),
              (_rendersReady)
                  ? IconButton(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: _playPause,
                      icon: Icon(!_playing
                          ? Icons.play_arrow_rounded
                          : Icons.pause_circle_filled_rounded))
                  : IconButton(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () {},
                      icon: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.grey,
                      )),
              SizedBox(width: 150.0, child: Text(widget.file.name)),
              SizedBox(
                width: 10.0,
              ),
              Container(
                width: 85,
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  color: Colors.black12,
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  '${printDurationFromSeconds(_playHead)} / ${printDuration(_duration)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 9.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(100, 100, 100, 1)),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              SizedBox(
                  child: RotatedBox(
                quarterTurns: 1,
                child: SizedBox(
                  width: 60,
                  height: 300,
                  child: LevelMeter(
                    left: _levels[0],
                    right: _levels[1],
                  ),
                ),
              )),
              Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}
