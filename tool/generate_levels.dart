import 'dart:convert';
import 'dart:io';

// Deterministic authored campaign. Runtime pieces/refills remain random.
// Run: dart run tool/generate_levels.dart
void main() {
  final legacy =
      (jsonDecode(File('tool/legacy_levels.json').readAsStringSync())
              as Map<String, dynamic>)['levels']
          as List<dynamic>;
  const relocated = {8: 2, 16: 1, 24: 5, 56: 4, 76: 3};
  const colors = ['blue', 'red', 'purple', 'green', 'yellow', 'orange'];
  final levels = <Map<String, dynamic>>[];
  final notes = <Map<String, dynamic>>[];
  for (var id = 1; id <= 100; id++) {
    final chapter = (id - 1) ~/ 10;
    final beat = (id - 1) % 10;
    final recovery = id > 10 && (beat == 0 || beat == 5);
    var n = id <= 5 ? 6 : 6 + ((chapter + beat) % 5);
    var grid = List.generate(n, (_) => List.filled(n, '1'));
    final family = id <= 5 ? beat : beat;
    // Ten silhouettes recur with different size, asymmetry and interior terrain.
    // Every column retains a top entry; central corridors remain connected.
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        final edge = c == 0 || c == n - 1;
        final bottom = r == n - 1;
        final cut = switch (family) {
          0 => bottom && (c == 0 || c == n - 1),
          1 => edge && r >= n - 2,
          2 => c == 0 && r > n ~/ 2,
          3 => c == n - 1 && r > n ~/ 2,
          4 => bottom && (c < n ~/ 3 || c >= n - n ~/ 3),
          5 => edge && r.isOdd && r > 0,
          6 => r == n - 2 && edge || bottom && (c == 1 || c == n - 2),
          7 => c < 2 && r >= n - 2,
          8 => c >= n - 2 && r >= n - 2,
          _ => edge && r >= n ~/ 2 || bottom && (c == 1 || c == n - 2),
        };
        if (cut) grid[r][c] = 'X';
      }
    }
    if (id >= 21 && !recovery) {
      final frozen = 1 + chapter ~/ 2 + beat % 3;
      for (var k = 0; k < frozen; k++) {
        final r = 1 + (k * 2 + chapter) % (n - 2);
        final c = 1 + (k * 3 + beat) % (n - 2);
        grid[r][c] = '2';
      }
    }
    if (id >= 41 && !recovery && beat % 3 != 0) {
      for (var k = 0; k < 1 + chapter ~/ 4; k++) {
        final r = 2 + (chapter + k * 2) % (n - 3);
        final c = 1 + (beat + k * 3) % (n - 2);
        grid[r][c] = 'W';
      }
    }
    // Later revisits open an asymmetric side inlet rather than repeating a mask.
    if (chapter >= 5 || id == 15) {
      grid[1][chapter.isEven ? 0 : n - 1] = 'X';
      if (chapter >= 7) grid[2][chapter.isEven ? 0 : n - 1] = 'X';
    }
    // Remove decorative islands that cannot participate in an ordinary swap.
    // Keep the largest connected playable component after terrain placement.
    final remaining = <int>{
      for (var r = 0; r < n; r++)
        for (var c = 0; c < n; c++)
          if (grid[r][c] == '1' || grid[r][c] == '2') r * n + c,
    };
    var largest = <int>{};
    while (remaining.isNotEmpty) {
      final component = <int>{remaining.first};
      final queue = [remaining.first];
      remaining.remove(queue.first);
      while (queue.isNotEmpty) {
        final cell = queue.removeLast(), r = cell ~/ n, c = cell % n;
        for (final next in [if (r > 0) cell - n, if (r < n - 1) cell + n,
          if (c > 0) cell - 1, if (c < n - 1) cell + 1]) {
          if (remaining.remove(next)) { component.add(next); queue.add(next); }
        }
      }
      if (component.length > largest.length) largest = component;
    }
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if ((grid[r][c] == '1' || grid[r][c] == '2') && !largest.contains(r * n + c)) grid[r][c] = 'X';
      }
    }
    final source = relocated[id];
    if (source != null) {
      final old = legacy[source - 1] as Map<String, dynamic>;
      n = old['rows'] as int;
      grid = (old['grid'] as List<dynamic>)
          .map((row) => (row as String).split(','))
          .toList();
    }
    final count = id <= 2
        ? 1
        : id <= 10
        ? 2
        : 3;
    var quota = id <= 5 ? 3 + id : 7 + chapter * 3 + beat;
    if (recovery) quota = (quota * .7).round();
    if (source == 5)
      quota = 10; // Original narrow cross has fewer legal options.
    final objectives = List.generate(
      count,
      (i) =>
          '${quota + (i == 1 ? 2 : 0)};${colors[(chapter + i + beat ~/ 3) % 6]}',
    );
    if (id >= 31 && !recovery && beat == 8) objectives.add('1;flare');
    if (id == 18) {
      objectives..clear()..addAll(['6;blue', '6;red', '1;flare']);
    }
    final moves = id <= 5
        ? 24
        : recovery
        ? 30
        : 30 - chapter ~/ 3;
    levels.add({
      'level': id,
      'rows': n,
      'cols': n,
      'grid': grid.map((row) => row.join(',')).toList(),
      'moves': moves,
      'objective': objectives,
    });
    notes.add({
      'level': id,
      'source': source == null
          ? 'original campaign design'
          : 'adapted legacy $source',
      'family': family,
      'recovery': recovery && source != 3 && source != 4,
      'rationale': id <= 5
          ? 'Generous color-only onboarding; no frozen cells or walls.'
          : id == 18
          ? 'Introduce one stripe goal on open terrain with low color quotas and 30 moves.'
          : recovery && (source == 3 || source == 4)
          ? 'Legacy terrain combination with relaxed quotas; not a terrain recovery level.'
          : recovery
          ? 'Recovery: reduced quotas, generous moves and uncluttered terrain.'
          : 'Practice silhouette $family with chapter ${chapter + 1} collection pressure and terrain.',
    });
  }
  const encoder = JsonEncoder.withIndent('  ');
  File(
    'assets/levels.json',
  ).writeAsStringSync('${encoder.convert({'levels': levels})}\n');
  Directory('docs').createSync(recursive: true);
  File(
    'docs/level_design_metadata.json',
  ).writeAsStringSync('${encoder.convert(notes)}\n');
  stdout.writeln(
    'Generated ${levels.length} campaign levels. Run the production-engine validator before acceptance.',
  );
}
