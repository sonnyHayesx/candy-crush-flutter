import 'dart:convert';
import 'dart:io';

void main() {
  final data =
      jsonDecode(File('docs/level_validation_results.json').readAsStringSync())
          as Map<String, dynamic>;
  final levels =
      jsonDecode(File('assets/levels.json').readAsStringSync())['levels']
          as List;
  final metadata =
      jsonDecode(File('docs/level_design_metadata.json').readAsStringSync())
          as List;
  final results = data['levels'] as List;
  final out = StringBuffer('# Measured campaign difficulty\n\n');
  out.writeln(
    'These are seeded heuristic-agent results, not human win rates. A replayed winning trace proves one reachable win for that level, not that every random deal is winnable. No booster, advertisement or extra move is used.\n',
  );
  out.writeln(
    'Difficulty score = 100 × (1 − average-policy win rate). Policies use different random-choice rates and visible-board heuristics; their names do not establish real human skill. Each policy receives 100 seeds per level in the full run.\n',
  );
  out.writeln(
    'Validated results: ${results.length}/100; replayed winning traces: ${results.where((r) => r['trace_replayed'] == true).length}.\n',
  );
  out.writeln('| Chapter | Mean average-policy win rate |');
  out.writeln('|---|---:|');
  for (var chapter = 0; chapter < 10; chapter++) {
    final rows = results
        .where(
          (r) =>
              (r['level_id'] as int) > chapter * 10 &&
              (r['level_id'] as int) <= chapter * 10 + 10,
        )
        .toList();
    if (rows.isNotEmpty) {
      final mean =
          rows.fold<double>(
            0,
            (sum, r) =>
                sum + (r['agents']['average']['win_rate'] as num).toDouble(),
          ) /
          rows.length;
      out.writeln('| ${chapter + 1} | ${(mean * 100).toStringAsFixed(1)}% |');
    }
  }
  out.writeln(
    '\nScores may jump between neighboring levels because board geometry, frozen cells, walls and goal pressure interact. Recovery beats are design intent, not a guarantee of easier measured play. Low-rate levels and sharp jumps need further balancing and human playtesting before claiming a fair smooth curve.\n',
  );
  out.writeln(
    '| Level | Source | Board | Moves | Goals | Frozen / walls / voids | Beginner / average / strategic wins | Score | Witness | Design reason |',
  );
  out.writeln('|---:|---|---|---:|---|---|---|---:|---|---|');
  for (final r in results) {
    final id = r['level_id'] as int;
    final d = levels[id - 1];
    final m = metadata[id - 1];
    final cells = (d['grid'] as List)
        .expand((row) => (row as String).split(','))
        .toList();
    final rates = ['beginner', 'average', 'strategic']
        .map(
          (a) =>
              '${((r['agents'][a]['win_rate'] as num) * 100).toStringAsFixed(0)}%',
        )
        .join(' / ');
    out.writeln(
      '| $id | ${m['source']} | ${d['rows']}×${d['cols']} | ${d['moves']} | ${(d['objective'] as List).join(', ')} | ${cells.where((c) => c == '2').length} / ${cells.where((c) => c == 'W').length} / ${cells.where((c) => c == 'X').length} | $rates | ${r['difficulty_score']} | ${r['trace_replayed']} | ${m['rationale']} |',
    );
  }
  out.writeln(
    '\nFull seeds, failure reasons, actions and replay evidence: `level_validation_results.json`. Reproduce using `flutter test tool/validate_levels_test.dart --dart-define=TRIALS=100 --reporter expanded`, then `dart run tool/report_level_validation.dart`. SDK version and source hash are recorded in the readiness audit.',
  );
  File('docs/level_difficulty_report.md').writeAsStringSync(out.toString());
}
