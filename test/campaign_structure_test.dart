import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final levels =
      (jsonDecode(File('assets/levels.json').readAsStringSync())
              as Map<String, dynamic>)['levels']
          as List<dynamic>;

  test(
    'campaign has 100 distinct valid connected boards and supported goals',
    () {
      expect(levels.length, 100);
      final layouts = <String>{};
      for (var i = 0; i < levels.length; i++) {
        final d = levels[i] as Map<String, dynamic>;
        expect(d.keys.toSet(), {
          'level',
          'rows',
          'cols',
          'grid',
          'moves',
          'objective',
        });
        expect(d['level'], i + 1);
        final n = d['rows'] as int;
        expect(
          d['cols'],
          n,
          reason: 'Production engine requires square boards',
        );
        expect(n, inInclusiveRange(5, 10));
        final grid = (d['grid'] as List)
            .map((r) => (r as String).split(','))
            .toList();
        expect(grid.length, n);
        for (final row in grid) {
          expect(row.length, n);
          expect(
            row.every((cell) => {'1', '2', 'X', 'W'}.contains(cell)),
            isTrue,
          );
        }
        expect(
          layouts.add((d['grid'] as List).join('/')),
          isTrue,
          reason: 'Level ${i + 1} repeats a full terrain layout',
        );
        final playable = <int>{};
        for (var r = 0; r < n; r++) {
          for (var c = 0; c < n; c++) {
            if (grid[r][c] == '1' || grid[r][c] == '2') playable.add(r * n + c);
          }
        }
        final seen = <int>{playable.first};
        final queue = <int>[playable.first];
        while (queue.isNotEmpty) {
          final cell = queue.removeLast();
          final r = cell ~/ n;
          final c = cell % n;
          final neighbours = [
            if (r > 0) cell - n,
            if (r < n - 1) cell + n,
            if (c > 0) cell - 1,
            if (c < n - 1) cell + 1,
          ];
          for (final next in neighbours) {
            if (playable.contains(next) && seen.add(next)) queue.add(next);
          }
        }
        expect(
          seen,
          playable,
          reason: 'Disconnected playable cells at ${i + 1}',
        );
        expect(d['moves'], greaterThan(0));
        for (final goal in d['objective'] as List) {
          final parts = (goal as String).split(';');
          expect(parts.length, 2);
          expect(int.parse(parts[0]), greaterThan(0));
          expect({
            'red',
            'blue',
            'green',
            'purple',
            'yellow',
            'orange',
            'flare',
          }, contains(parts[1]));
        }
        if (i < 5) {
          expect(
            grid.expand((r) => r).any((c) => c == 'W' || c == '2'),
            isFalse,
          );
          expect(
            (d['objective'] as List).any(
              (o) => (o as String).endsWith(';flare'),
            ),
            isFalse,
          );
          expect(d['moves'], greaterThanOrEqualTo(20));
        }
      }
    },
  );
}
