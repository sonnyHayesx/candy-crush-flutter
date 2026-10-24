import 'package:flutter_test/flutter_test.dart';
import 'package:prismleaf_vale/model/tile.dart';
import '../tool/level_solver.dart';

Map<String, dynamic> fixture({
  List<String> objectives = const ['12;blue', '2;flare'],
}) => {
  'level': 1,
  'rows': 6,
  'cols': 6,
  'grid': List.filled(6, '1,1,1,1,1,1'),
  'moves': 30,
  'objective': objectives,
};
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('seeded real engine replays every intermediate board and objective', () {
    final a = HeadlessGame(fixture(), 12345),
        b = HeadlessGame(fixture(), 12345);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    expect(a.fingerprint(), b.fingerprint());
    for (var i = 0; i < 12 && !a.bloc.isLevelOver; i++) {
      final move = a.legalMoves.first;
      a.play(move);
      b.play(move);
      expect(a.fingerprint(), b.fingerprint());
      expect(a.bloc.gameController.level.movesLeft, 29 - i);
    }
  });
  test('stripe events satisfy legacy flare objectives', () {
    final g = HeadlessGame(fixture(), 1);
    addTearDown(g.dispose);
    g.bloc.pushTileEvent(TileType.blue_h, 1);
    g.bloc.pushTileEvent(TileType.red_v, 1);
    expect(g.bloc.gameController.level.objectives.last.count, 0);
  });
  test('headless rejects nonadjacent swap without consuming a move', () {
    final g = HeadlessGame(fixture(), 1);
    addTearDown(g.dispose);
    expect(() => g.play(const SolverMove(0, 0, 5, 5)), throwsStateError);
    expect(g.bloc.gameController.level.movesLeft, 30);
  });
  test('fireball removes its center and neighboring normal tiles', () {
    final g = HeadlessGame(fixture(), 2);
    addTearDown(g.dispose);
    final c = g.bloc.gameController;
    c.grid[3][3].type = TileType.fireball;
    c.proceedWithExplosion(c.grid[3][3], g.bloc);
    expect(c.grid[3][3].type, TileType.empty);
    expect(c.grid[3][4].type, TileType.empty);
  });
  test('one-ply evaluation leaves the production state unchanged', () {
    final g = HeadlessGame(fixture(), 99);
    addTearDown(g.dispose);
    final before = g.fingerprint();
    for (final m in g.legalMoves) {
      g.value(m, true);
    }
    expect(g.fingerprint(), before);
  });
}
