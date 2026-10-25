import 'dart:math' as math;

import 'package:prismleaf_vale/animations/model/animations_resolver.dart';
import 'package:prismleaf_vale/bloc/game_bloc.dart';
import 'package:prismleaf_vale/model/tile.dart';

/// Coordinates use the engine convention: zero-based row zero is the bottom.
class SolverMove {
  const SolverMove(this.row, this.col, [this.toRow, this.toCol]);
  final int row, col;
  final int? toRow, toCol;
  bool get tap => toRow == null;
  List<int> toJson() => [
    row,
    col,
    if (!tap) ...[toRow!, toCol!],
  ];
  factory SolverMove.fromJson(List<dynamic> v) => v.length == 2
      ? SolverMove(v[0], v[1])
      : SolverMove(v[0], v[1], v[2], v[3]);
}

/// Calls the production controller/resolver. No rules, gravity or refill clone.
class HeadlessGame {
  HeadlessGame(Map<String, dynamic> definition, int seed)
    : bloc = GameBloc.simulation(definition, seed);
  final GameBloc bloc;
  int reshuffles = 0;
  bool get won =>
      bloc.gameController.level.objectives.every((o) => o.count == 0);
  List<SolverMove> get legalMoves {
    final controller = bloc.gameController;
    final result = controller.swaps
        .map((s) => SolverMove(s.from.row, s.from.col, s.to.row, s.to.col))
        .toList();
    final level = controller.level;
    for (var r = 0; r < level.numberOfRows; r++) {
      for (var c = 0; c < level.numberOfCols; c++) {
        final Tile t = controller.grid[r][c];
        if (t.canMove && Tile.isBomb(t.type!)) result.add(SolverMove(r, c));
      }
    }
    result.sort((a, b) {
      final av = a.toJson(), bv = b.toJson();
      for (var i = 0; i < math.min(av.length, bv.length); i++) {
        if (av[i] != bv[i]) return av[i].compareTo(bv[i]);
      }
      return av.length.compareTo(bv.length);
    });
    return result;
  }

  void play(SolverMove move) {
    if (bloc.isLevelOver) throw StateError('Move after game over');
    final c = bloc.gameController;
    final Tile from = c.grid[move.row][move.col];
    if (move.tap) {
      if (!from.canMove || !Tile.isBomb(from.type!)) {
        throw StateError('Illegal tap');
      }
      c.proceedWithExplosion(from, bloc);
    } else {
      final Tile to = c.grid[move.toRow!][move.toCol!];
      if (!c.swapContains(from, to)) throw StateError('Illegal swap');
      final bomb = Tile.isBomb(from.type!);
      c.swapTiles(from, to);
      final one = c.getCombo(from.row, from.col);
      final two = c.getCombo(to.row, to.col);
      c.resolveCombo(one, bloc);
      c.resolveCombo(two, bloc);
      if (bomb) {
        c.proceedWithExplosion(
          Tile(row: from.row, col: from.col, type: from.type),
          bloc,
        );
      }
    }
    final resolver = AnimationsResolver(gameBloc: bloc, level: c.level)
      ..resolve();
    if (resolver.involvedCells.isNotEmpty &&
        resolver.getAnimationsSequences().isNotEmpty) {
      for (final rc in resolver.involvedCells) {
        c.grid[rc.row][rc.col].visible = false;
      }
      c.refreshGridAfterAnimations(
        resolver.resultingGridInTermsOfTileTypes,
        resolver.involvedCells,
      );
    }
    c.identifySwaps();
    bloc.playMove();
    if (!bloc.isLevelOver && !c.stillMovesToPlay()) {
      reshuffles++;
      c.reshuffling();
    }
  }

  /// One-ply visible-board heuristic; never samples future refills.
  double value(SolverMove m, bool strategic) {
    final c = bloc.gameController;
    final Tile a = c.grid[m.row][m.col];
    double tileValue(Tile t) {
      final normalized = Tile.normalizeBombType(t.type!);
      final type =
          normalized == TileType.bomb_h || normalized == TileType.bomb_v
          ? TileType.flare
          : t.type;
      final needed = c.level.objectives.where(
        (o) => o.type == type && o.count > 0,
      );
      return (needed.isEmpty ? 0.25 : 3.0) + (t.depth > 0 ? 0.7 : 0);
    }

    double explosion(Tile t, int r, int col) {
      double score = 0;
      final norm = Tile.normalizeBombType(t.type!);
      for (var rr = 0; rr < c.level.numberOfRows; rr++) {
        for (var cc = 0; cc < c.level.numberOfCols; cc++) {
          final dr = (rr - r).abs(), dc = (cc - col).abs();
          final hits = norm == TileType.bomb_h
              ? dr == 0
              : norm == TileType.bomb_v
              ? dc == 0
              : norm == TileType.flare
              ? dr + dc <= 1
              : norm == TileType.bomb
              ? dr + dc <= 2
              : dr + dc <= 3;
          final Tile target = c.grid[rr][cc];
          if (hits &&
              (Tile.isNormal(target.type!) || Tile.isBomb(target.type!))) {
            score += tileValue(target);
          }
        }
      }
      return score;
    }

    if (m.tap) return explosion(a, m.row, m.col);
    final Tile b = c.grid[m.toRow!][m.toCol!];
    final sourceBomb = Tile.isBomb(a.type!);
    c.swapTiles(a, b);
    double score = sourceBomb ? explosion(a, a.row, a.col) : 0;
    final visited = <int>{};
    for (final combo in [c.getCombo(a.row, a.col), c.getCombo(b.row, b.col)]) {
      for (final t in combo.tiles) {
        if (visited.add(t.row * 100 + t.col)) score += tileValue(t);
      }
      if (combo.resultingTileType != null) {
        score += strategic ? 4 : 0.5;
        score += tileValue(Tile(type: combo.resultingTileType));
      }
    }
    c.swapTiles(a, b);
    return score;
  }

  String fingerprint() {
    final c = bloc.gameController;
    return [
      for (var r = 0; r < c.level.numberOfRows; r++)
        for (var col = 0; col < c.level.numberOfCols; col++)
          '${c.grid[r][col].type.index}:${c.grid[r][col].depth}',
      c.level.movesLeft,
      ...c.level.objectives.map((o) => o.count),
    ].join(',');
  }

  void dispose() => bloc.dispose();
}

Map<String, dynamic> runTrial(
  Map<String, dynamic> definition,
  int seed,
  String agent,
) {
  final game = HeadlessGame(definition, seed);
  final policy = math.Random(seed ^ 0x513ca7);
  final trace = <List<int>>[];
  var legalTotal = 0;
  String? failure;
  try {
    while (!game.bloc.isLevelOver) {
      final moves = game.legalMoves;
      legalTotal += moves.length;
      if (moves.isEmpty) {
        failure = 'deadlock';
        break;
      }
      final epsilon = agent == 'beginner'
          ? 0.65
          : agent == 'average'
          ? 0.2
          : 0.0;
      SolverMove choice;
      if (policy.nextDouble() < epsilon) {
        choice = moves[policy.nextInt(moves.length)];
      } else {
        var best = -double.infinity;
        var choices = <SolverMove>[];
        for (final move in moves) {
          final value = game.value(move, agent == 'strategic');
          if (value > best + 1e-9) {
            best = value;
            choices = [move];
          } else if ((value - best).abs() < 1e-9) {
            choices.add(move);
          }
        }
        choice = choices[policy.nextInt(choices.length)];
      }
      trace.add(choice.toJson());
      game.play(choice);
    }
    return {
      'seed': seed,
      'won': game.won,
      'moves_used': trace.length,
      'moves_remaining': game.bloc.gameController.level.movesLeft,
      'reshuffles': game.reshuffles,
      'mean_legal_actions': trace.isEmpty ? 0 : legalTotal / trace.length,
      'failure_reason': game.won ? null : failure ?? 'move_budget_exhausted',
      'remaining_objectives': {
        for (final o in game.bloc.gameController.level.objectives)
          o.type.name: o.count,
      },
      'winning_move_sequence': game.won ? trace : null,
    };
  } finally {
    game.dispose();
  }
}
