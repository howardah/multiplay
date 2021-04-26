import 'package:flutter/material.dart';
import 'package:multiplay/models/mixer_state.dart';
import 'package:provider/provider.dart';

class Tracks extends StatelessWidget {
  const Tracks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(

      /// Calls `context.watch` to make [Count] rebuild when [Counter] changes.
        '${context.watch<Mixer>().tracks}',
        key: const Key('counterState'),
        style: Theme.of(context).textTheme.headline4);
  }
}