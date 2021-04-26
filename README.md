# multiplay

Like the [mixer application](https://github.com/howardah/multiplay_mixer), this is definitely a work in progress. It is the counterpart to the mixer app & represents my thoughts of playback of the matroska files. Also like the mixer application it relies heavily on [FFmpeg](https://ffmpeg.org/) for reading & processing the audio.

Feel free to send PRs or write me with thoughts if you’re interested and/or have ideas about the project.

## Build

```
flutter pub get
flutter build macos
```

## Priority problems

* ffmpeg, ffplay, and ffprobe all need to be downloaded in order to run the application. It would be far better if they could be bundled into the app. I have figured out how to bundle them but can’t seem to, using the flutter API, figure out how to programmatically locate the app itself in order to make use of the bundled CLI apps.
* Volume control. Because playing the audio happens in a process_run shell, I'm not sure of the best way to make that happen. ffplay provides [a way](https://www.ffmpeg.org/ffplay.html#While-playing) of adjusting playback volume, but I am unsure of whether this works with the `-nodisp` option and have yet to try it.
* Large files (such as assets/audio/example_large_file.mka) take too long to process. Maybe the process should be broken into several shells? Maybe it would be better to write/cache an mp3 or 2 of each loaded file?
* A default limiter should be added to prevent clipping on the player.