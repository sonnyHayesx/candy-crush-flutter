// Audio names correspond to the original short tones generated in tool/generate_sfx.ps1.
// ignore_for_file: constant_identifier_names
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../brand/progress.dart';

class Audio {
  static AudioPlayer? _player;
  static Future<void> _operations = Future.value();
  static int _generation = 0;

  static Future<void> playAsset(AudioType type) {
    if (!GameProgress.instance.soundEnabled) return Future.value();
    final generation = _generation;
    _operations = _operations.then((_) async {
      if (generation != _generation) return;
      try {
        final player = _player ??= AudioPlayer();
        await player.stop();
        await player.setAsset('assets/audio/${type.name}.wav');
        if (generation == _generation && GameProgress.instance.soundEnabled) {
          unawaited(
            player.play().catchError((Object error) {
              debugPrint('Unable to play sound: $error');
            }),
          );
        }
      } catch (error) {
        debugPrint('Unable to play sound: $error');
      }
    });
    return _operations;
  }

  static Future<void> stop() async {
    _generation++;
    try {
      await _operations;
      await _player?.stop();
    } catch (error) {
      debugPrint('Unable to stop sound: $error');
    }
  }
}

enum AudioType { select, invalid, swap, move_down, bomb, game_start, win, lost }
