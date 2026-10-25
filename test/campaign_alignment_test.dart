import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prismleaf_vale/bloc/bloc_provider.dart';
import 'package:prismleaf_vale/bloc/game_bloc.dart';
import 'package:prismleaf_vale/pages/game_page.dart';
import 'package:prismleaf_vale/panel/objective/components/objective_panel.dart';
import 'package:prismleaf_vale/brand/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prismleaf_vale/model/tile.dart';

void main() {
  final definitions =
      (jsonDecode(File('assets/levels.json').readAsStringSync())['levels']
              as List)
          .cast<Map<String, dynamic>>();
  for (final size in [
    const Size(320, 568),
    const Size(412, 915),
    const Size(800, 360),
  ]) {
    testWidgets('all 100 boards align within ${size.width}x${size.height}', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        'prismleaf_sound_enabled': false,
        'prismleaf_haptics_enabled': false,
      });
      await GameProgress.instance.load();
      for (final definition in definitions) {
        final bloc = GameBloc.simulation(
          definition,
          100000 + (definition['level'] as int),
        );
        final level = bloc.gameController.level;
        await tester.pumpWidget(
          BlocProvider<GameBloc>(
            bloc: bloc,
            child: MaterialApp(
              home: GamePage(key: ValueKey(level.index), level: level),
            ),
          ),
        );
        await tester.pump();
        expect(level.tileWidth, greaterThan(0));
        expect(level.tileHeight, greaterThan(0));
        final board = Rect.fromLTWH(
          level.boardLeft,
          level.boardTop,
          level.tileWidth * level.numberOfCols,
          level.tileHeight * level.numberOfRows,
        );
        expect(
          board.overlaps(tester.getRect(find.byType(ObjectivePanel))),
          isFalse,
          reason: 'Objectives cover board at level ${level.index}',
        );
        for (var r = 0; r < level.numberOfRows; r++) {
          for (var c = 0; c < level.numberOfCols; c++) {
            final Tile tile = bloc.gameController.grid[r][c];
            tile.setPosition();
            expect(
              tile.x,
              closeTo(level.boardLeft + c * level.tileWidth, .001),
            );
            expect(
              tile.y,
              closeTo(
                level.boardTop +
                    (level.numberOfRows - 1 - r) * level.tileHeight,
                .001,
              ),
            );
            expect(tile.x, greaterThanOrEqualTo(0));
            expect(tile.y, greaterThanOrEqualTo(0));
            expect(
              tile.x! + level.tileWidth,
              lessThanOrEqualTo(size.width + .001),
            );
            expect(
              tile.y! + level.tileHeight,
              lessThanOrEqualTo(size.height + .001),
            );
          }
        }
        expect(tester.takeException(), isNull, reason: 'Level ${level.index}');
        await tester.pumpWidget(const SizedBox.shrink());
        bloc.dispose();
      }
    });
  }
}
