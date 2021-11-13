import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:multiplay/components/track.dart';
import 'package:multiplay/globals/common.dart';
import 'package:multiplay/models/mixer_state.dart';
import 'package:multiplay/models/track_models.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

Future<String> makeCachedFile(
    Map<String, dynamic> playMap, String filePath) async {
  String inputList = '';
  int mapCount = 0;
  String mapList = '';
  String weights = '';
  Random random = new Random();
  String trackId = new Uuid().v1();

  List<dynamic> tracks = playMap['play_settings']['tracks'];
//TODO: Handle volume somehow
  for (Map<String, dynamic> track in tracks) {
    int startingIndex = track['startingIndex'];
    int chosenIndex = random.nextInt(track['length']) + startingIndex;
    if (mapCount != 0) {
      weights += '|';
    }

    inputList += "amovie='$filePath':s=${chosenIndex.toString()}";
    weights += track['level'].toString();
    inputList += '[aid${mapCount.toString()}];';
    mapList += '[aid${mapCount.toString()}]';
    mapCount++;
  }

  String cacheFile = filePath.replaceAll(RegExp(r"^.*[\/\\]"), '${cacheDir.path}/_playfile_').replaceAll('.mka', '');
  String output = '$cacheFile-$trackId.mp3';

  print(filePath);
  print(output);

  String extraOptions = '';
  String command =
      '"$ffmpeg" -lavfi "$inputList${mapList}amix=inputs=${mapCount.toString()}:duration=longest:normalize=disable:weights=$weights" $extraOptions "$output"';

  Shell shell = new Shell();
  await shell.run(command);

  return output;
}

// String amendSeekTime(String command, double seekPoint) {
//   print('am I here? somewhere');
//   RegExp seekSegment = RegExp(r".mka':(.*?)s=");
//   String newCommand =
//       command.replaceAll(seekSegment, ".mka':sp=${seekPoint.toString()}:s=");
//   print(newCommand);
//   return newCommand;
// }
//
// void pauseOtherTracks(BuildContext context, Track thisTrack) {
//   List<TrackInstance> tracks =
//       Provider.of<Mixer>(context, listen: false).tracks;
//   for (TrackInstance track in tracks) {
//     if (track.track != thisTrack) {
//       track.trackKey.currentState?.pause();
//     } else {
//       print('yeah, I found it');
//     }
//   }
// }
