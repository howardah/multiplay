import 'dart:convert';
import 'dart:io';

import 'package:multiplay/globals/common.dart';
import 'package:process_run/shell.dart';
import 'package:uuid/uuid.dart';

Future<Map<String, dynamic>> getJsonAttachment(String filePath,
    [Shell? givenShell]) async {
  File jsonFile = File('${cacheDir.path}/tempJson-${Uuid().v1()}.json');
  File outFile = File('${cacheDir.path}/tempJson-${Uuid().v1()}.mka');
  String command =
      '"$ffmpeg" -dump_attachment:t:0 "${jsonFile.path}" -i "$filePath" "${outFile.path}"';
  givenShell != null ? await givenShell.run(command) : await shell.run(command);
  Map<String, dynamic> json = await jsonDecode(await jsonFile.readAsString());
  jsonFile.delete();
  outFile.delete();
  return json;
}

Future<double> getDuration(String filePath, [Shell? givenShell]) async {
  String command =
      '"$ffprobe" -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$filePath"';
  double duration = givenShell != null
      ? double.parse((await givenShell.run(command)).first.stdout.toString())
      : double.parse((await shell.run(command)).first.stdout.toString());
  print(duration);
  return duration;
}
