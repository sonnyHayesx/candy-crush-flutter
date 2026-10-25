import 'dart:convert';
import 'dart:io';

// Record one explicit calibration pass. Do not rerun on already calibrated data.
void main() {
  final target = File('tool/level_balance.json');
  if (target.existsSync()) throw StateError('Balance pass already recorded');
  final results =
      jsonDecode(
            File('docs/level_validation_results.json').readAsStringSync(),
          )['levels']
          as List;
  if (results.length != 100) throw StateError('Complete baseline required');
  final adjustments = <String, dynamic>{};
  for (final r in results) {
    final id = r['level_id'] as int;
    final rate = (r['agents']['average']['win_rate'] as num).toDouble();
    final factor = id <= 5
        ? 1.0
        : id == 8
        ? .75
        : rate == 0
        ? .55
        : rate < .1
        ? .65
        : rate < .35
        ? .8
        : rate < .5
        ? .9
        : 1.0;
    adjustments['$id'] = {
      'color_quota_factor': factor,
      'baseline_average_win_rate': rate,
      'baseline_trace_replayed': r['trace_replayed'],
    };
  }
  target.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(adjustments)}\n',
  );
}
