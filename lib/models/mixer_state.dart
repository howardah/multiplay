import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multiplay/components/track.dart';
import 'package:multiplay/globals/common.dart';
import 'package:multiplay/models/track_models.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class Mixer extends ChangeNotifier {
  List<TrackInstance> _openTracks = [];
  bool _playing = false;
  double _playtime = 0.0;

  Stopwatch _stopwatch = Stopwatch();

  List<TrackInstance> get tracks => _openTracks;

  bool get playing => _playing;

  // Duration? get duration => (_openTracks.sort((a, b) => a.trackKey.currentState?.duration > b.trackKey.currentState?.duration ? 1 : 0));

  void addTrack(TrackInstance track) {
    _openTracks.add(track);
    notifyListeners();
  }

  void openMkaFile() async {
    final typeGroup = XTypeGroup(label: 'audio', extensions: ['.mka']);
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
    GlobalKey<TrackState> _keyChild = GlobalKey();

    if(file == null) return;

    addTrack(
      TrackInstance(
          track: Track(
            key: _keyChild,
            file: file,
          ),
          trackKey: _keyChild),
    );
  }

  void removeTrack(int index) {
    _openTracks.removeAt(index);
    notifyListeners();
  }

  void moveTrack(oldIndex, newIndex) {
    int trackLength = _openTracks.length;
    // Because the list length is recalculated while dragging an
    // item, the new index is always one more than it should be
    // while dragging further in the list. \/
    if (oldIndex < newIndex) newIndex--; // So, minus one.

    int index = newIndex >= trackLength ? (trackLength - 1) : newIndex;
    TrackInstance moving = _openTracks.removeAt(oldIndex);
    _openTracks.insert(index, moving);
    notifyListeners();
  }

  void play([double? seekPoint]) async {
    _stopwatch.reset();
    if (_playing) shell.kill();

    _playing = true;
    notifyListeners();
    _stopwatch.start();
    await shell.run(playString());

    _stopwatch.stop();
    print(_stopwatch.elapsed);
    _playing = false;
    notifyListeners();
  }

  String playString() {
    // String inputList = '';
    // int mapCount = 0;
    // String mapList = '';
    //
    // for (TrackInstance track in _openTracks) {
    //   List<XFile> xFiles = track.track.files;
    //   XFile file = (xFiles.toList()..shuffle()).first;
    //   double? stateLevel = track.trackKey.currentState?.level;
    //   double level = stateLevel != null ? stateLevel : 1.0;
    //   inputList +=
    //       'amovie=${file.path}, volume=${level.toString()} [aid${mapCount.toString()}]; ';
    //   mapList += '[aid${mapCount.toString()}]';
    //   mapCount++;
    // }
    // return './ffplay -f lavfi "$inputList${mapList}amix=inputs=${mapCount.toString()}:duration=longest" -nodisp -autoexit';
    return '';
  }

  Future<String> exportString(File outFile, [Directory? source]) async {
    // List<Map<String, dynamic>> infoList = [];
    // String inputList = '';
    // int mapCount = 0;
    // String mapList = '';
    // int metaCount = 0;
    // String metadataList = '';
    //
    // Directory sourceDir = source != null
    //     ? source
    //     : await Directory('${cacheDir.path}/Export-${Uuid().v1()}').create();
    //
    // for (TrackInstance track in _openTracks) {
    //   List<XFile> xFiles = track.track.files;
    //   String? title = track.trackKey.currentState?.title;
    //   String trackName = title != null ? title : 'Track${mapCount.toString()}';
    //   String safeName = trackName.replaceAll(RegExp(r'\W'), '_');
    //   metaCount = 1;
    //
    //   Map<String, dynamic> trackInfo = {
    //     "name": trackName,
    //     "safeName": safeName,
    //     "level": track.track.player.volume,
    //     "startingIndex": mapCount,
    //     "length": xFiles.length
    //   };
    //
    //   for (XFile file in xFiles) {
    //     inputList += '-i "${file.path}" ';
    //     mapList += '-map ${mapCount.toString()} ';
    //     metadataList +=
    //         '-metadata:s:a:${mapCount.toString()} $safeName=${metaCount.toString()} ';
    //     mapCount++;
    //     metaCount++;
    //   }
    //
    //   infoList.add(trackInfo);
    // }
    //
    // final Map<String, dynamic> playSettings = {
    //   'play_settings': {
    //     'effects': [],
    //     'tracks': infoList,
    //   }
    // };
    // String json = jsonEncode(playSettings);
    // File jsonFile = await File('${sourceDir.path}/play_settings.json').create();
    // await jsonFile.writeAsString(json);
    //
    // String now = DateFormat('yyyyMMDD-HHmmss').format(DateTime.now());
    // String ffreport =
    //     ''; //'FFREPORT=file=\"${(cacheDir.path)}/export-$now.log\":level=32';
    //
    // String shellCommand = '$ffreport ' +
    //     '"${(toolsDir.path)}/ffmpeg" -y ' +
    //     '$inputList $mapList ' +
    //     '-attach ${jsonFile.path} ' +
    //     '$metadataList -metadata:s:t:0 mimetype=application/json ' +
    //     '${outFile.path}';
    //
    // return shellCommand;

    return '';
  }
}
