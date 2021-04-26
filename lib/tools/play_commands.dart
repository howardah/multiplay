import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:multiplay/components/track.dart';
import 'package:multiplay/globals/common.dart';
import 'package:multiplay/models/mixer_state.dart';
import 'package:multiplay/models/track_models.dart';
import 'package:provider/provider.dart';

String constructPlayCommandFromMap(
    Map<String, dynamic> playMap, String filePath) {
  String inputList = "amovie='$filePath':s=";
  int mapCount = 0;
  String mapList = '';
  String weights = '';
  Random random = new Random();

  List<dynamic> tracks = playMap['play_settings']['tracks'];
//TODO: Handle volume somehow
  for (Map<String, dynamic> track in tracks) {
    int startingIndex = track['startingIndex'];
    int chosenIndex = random.nextInt(track['length']) + startingIndex;
    if (mapCount != 0) {
      inputList += '+';
      weights += '|';
    }
    inputList += chosenIndex.toString();
    weights += track['level'].toString();
    mapList += '[aid${mapCount.toString()}]';
    mapCount++;
  }

  String printCommand =
      '-af astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.1.RMS_level,ametadata=print:key=lavfi.astats.2.RMS_level';

  String extraOptions = '';
  String command =
      '"$ffplay" -f lavfi "$inputList$mapList;${mapList}amix=inputs=${mapCount.toString()}:duration=longest:normalize=disable:weights=$weights" $printCommand $extraOptions -nodisp -autoexit';

  print(command);
  return command;
}

String amendSeekTime(String command, double seekPoint) {
  print('am I here? somewhere');
  RegExp seekSegment = RegExp(r'.mka":(.*?)s=');
  return command.replaceFirst(
      seekSegment, '.mka":sp=${seekPoint.toString()}:s=');
}

void pauseOtherTracks(BuildContext context, Track thisTrack) {
  List<TrackInstance> tracks =
      Provider.of<Mixer>(context, listen: false).tracks;
  for (TrackInstance track in tracks) {
    if (track.track != thisTrack) {
      track.trackKey.currentState?.pause();
    } else {
      print('yeah, I found it');
    }
  }
}
