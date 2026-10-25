import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'level_solver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('validate campaign using production gameplay', () async {
    const trials = int.fromEnvironment('TRIALS', defaultValue: 100);
    const seedBase = int.fromEnvironment('SEED_BASE', defaultValue: 100000);
    const first = int.fromEnvironment('FIRST', defaultValue: 1);
    const last = int.fromEnvironment('LAST', defaultValue: 100);
    const output = String.fromEnvironment(
      'OUTPUT',
      defaultValue: 'docs/level_validation_results.json',
    );
    final definitions =
        (jsonDecode(File('assets/levels.json').readAsStringSync())['levels']
                as List)
            .cast<Map<String, dynamic>>()
            .where((d) => d['level'] >= first && d['level'] <= last)
            .toList();
    final results = <Map<String, dynamic>>[];
    for (final d in definitions) {
      final agents = <String, dynamic>{};
      Map<String, dynamic>? witness;
      for (final agent in ['beginner', 'average', 'strategic']) {
        final runs = <Map<String, dynamic>>[];
        for (var n = 0; n < trials; n++) {
          if (n % 10 == 0) {
            // ignore: avoid_print
            print('Progress level ${d['level']} $agent trial $n');
            await Future<void>.delayed(Duration.zero);
          }
          final seed = seedBase + d['level'] as int;
          final run = runTrial(d, seed + n * 1009, agent);
          runs.add(run);
          if (run['won'] == true && witness == null) {
            witness = {...run, 'agent': agent};
          }
        }
        final wins = runs.where((r) => r['won'] == true).toList();
        agents[agent] = {
          'simulations': trials,
          'successful_simulations': wins.length,
          'win_rate': wins.length / trials,
          'mean_moves_used':
              runs.fold<double>(0, (v, r) => v + (r['moves_used'] as int)) /
              trials,
          'mean_winning_moves_remaining': wins.isEmpty
              ? null
              : wins.fold<double>(
                      0,
                      (v, r) => v + (r['moves_remaining'] as int),
                    ) /
                    wins.length,
          'runs': [
            for (final r in runs) {...r}..remove('winning_move_sequence'),
          ],
        };
      }
      if (witness != null) {
        final replay = HeadlessGame(d, witness['seed']);
        for (final move in witness['winning_move_sequence']) {
          replay.play(SolverMove.fromJson(move));
        }
        expect(replay.won, isTrue, reason: 'Trace replay level ${d['level']}');
        replay.dispose();
      }
      final winRate = agents['average']['win_rate'] as double;
      final score = (100 * (1 - winRate)).toStringAsFixed(1);
      results.add({
        'level_id': d['level'],
        'number_of_simulations': trials * 3,
        'agents': agents,
        'winning_witness': witness,
        'trace_replayed': witness != null,
        'difficulty_score': double.parse(score),
        'status': witness != null ? 'sampled_win_verified' : 'no_win_found',
      });
      File(output).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'method':
              'visible-board one-ply heuristic search, epsilon policies; actual production controller and animation resolver',
          'seed_formula': '$seedBase + level_id + trial_index * 1009',
          'dart_runtime': Platform.version,
          'coordinate_convention':
              'zero-based [row,col,toRow,toCol] swap, [row,col] tap; row zero bottom',
          'assumptions': [
            'No purchases, ads, extra moves or external boosts.',
            'Random(seed) on this Dart SDK; controller and resolver share RNG.',
            'Witness proves one seeded trajectory only; sampled rates are not human completion rates.',
            'All three agents are simple heuristics, not calibrated human skill models.',
            'Difficulty score = 100 * (1 - average-policy win rate).',
            'No minimum-move or universal solvability claim.',
          ],
          'levels': results,
        }),
      );
      // ignore: avoid_print
      print(
        'Level ${d['level']}: beginner=${agents['beginner']['win_rate']} average=$winRate strategic=${agents['strategic']['win_rate']} witness=${witness != null}',
      );
    }
    expect(
      results.every((r) => r['trace_replayed'] == true),
      isTrue,
      reason: 'Every level needs a replayed winning witness',
    );
  }, timeout: const Timeout(Duration(hours: 3)));
}
