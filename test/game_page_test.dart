import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prismleaf_vale/bloc/bloc_provider.dart';
import 'package:prismleaf_vale/bloc/game_bloc.dart';
import 'package:prismleaf_vale/pages/game_page.dart';
import 'package:prismleaf_vale/brand/progress.dart';
import 'package:prismleaf_vale/animations/animation_swap_tiles.dart';
import 'package:prismleaf_vale/animations/animation_chain.dart';
import 'package:prismleaf_vale/animations/animation_combo_three.dart';
import 'package:prismleaf_vale/animations/animation_combo_collapse.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<GameBloc> openGame(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({
    'prismleaf_sound_enabled': false,
    'prismleaf_haptics_enabled': false,
  });
  await GameProgress.instance.load();
  late GameBloc bloc;
  final level = await tester.runAsync(() async {
    bloc = GameBloc();
    return bloc.setLevel(1);
  });
  await tester.pumpWidget(
    BlocProvider<GameBloc>(
      bloc: bloc,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GamePage(level: level!),
                ),
              ),
              child: const Text('Open test level'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open test level'));
  await tester.pumpAndSettle();
  await tester.pump();
  await tester.tap(find.text('Begin level'));
  await tester.pumpAndSettle();
  addTearDown(bloc.dispose);
  return bloc;
}

Future<void> startSwap(WidgetTester tester, GameBloc bloc) async {
  final swap = bloc.gameController.swaps.first;
  final level = bloc.gameController.level;
  final start = Offset(
    level.boardLeft + (swap.from.col + 0.5) * level.tileWidth,
    level.boardTop +
        (level.numberOfRows - swap.from.row - 0.5) * level.tileHeight,
  );
  final direction = Offset(
    (swap.to.col - swap.from.col).toDouble(),
    (swap.from.row - swap.to.row).toDouble(),
  );
  final gesture = await tester.startGesture(start);
  await gesture.moveBy(direction * 22);
  await gesture.moveBy(direction * 8);
  await gesture.up();
  await tester.pump();
}

void main() {
  testWidgets('background sequence pauses and resume restores moves', (
    tester,
  ) async {
    final bloc = await openGame(tester);
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();
    expect(find.text('Trail paused'), findsOneWidget);
    await tester.tap(find.text('Keep playing'));
    await tester.pumpAndSettle();
    final moves = bloc.gameController.level.movesLeft;
    await startSwap(tester, bloc);
    expect(find.byType(AnimationSwapTiles), findsOneWidget);
    await tester.pumpAndSettle();
    expect(bloc.gameController.level.movesLeft, moves - 1);
    expect(tester.takeException(), isNull);
  });

  for (final delay in [0, 150, 350]) {
    testWidgets('leaving a move after $delay ms cleans every overlay', (
      tester,
    ) async {
      final bloc = await openGame(tester);
      await startSwap(tester, bloc);
      await tester.pump(Duration(milliseconds: delay));
      Navigator.of(tester.element(find.byType(GamePage))).pop();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Open test level'), findsOneWidget);
      expect(find.byType(AnimationSwapTiles), findsNothing);
      expect(find.byType(AnimationChain), findsNothing);
      expect(find.byType(AnimationComboThree), findsNothing);
      expect(find.byType(AnimationComboCollapse), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('background during a move settles once and remains resumable', (
    tester,
  ) async {
    final bloc = await openGame(tester);
    final moves = bloc.gameController.level.movesLeft;
    await startSwap(tester, bloc);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Trail paused'), findsOneWidget);
    expect(bloc.gameController.level.movesLeft, moves - 1);
    await tester.tap(find.text('Keep playing'));
    await tester.pumpAndSettle();
    await startSwap(tester, bloc);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(bloc.gameController.level.movesLeft, moves - 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A loaded level shows its playable intro and board', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    late GameBloc bloc;
    final level = await tester.runAsync(() async {
      bloc = GameBloc();
      return bloc.setLevel(1);
    });
    addTearDown(bloc.dispose);
    await tester.pumpWidget(
      BlocProvider<GameBloc>(
        bloc: bloc,
        child: MaterialApp(home: GamePage(level: level!)),
      ),
    );
    await tester.pump();
    expect(find.text('Begin level'), findsOneWidget);
    expect(find.text('Glade 1'), findsWidgets);
    final largeTileWidth = level.tileWidth;
    expect(largeTileWidth, greaterThan(0));
    tester.view.physicalSize = const Size(960, 1704);
    await tester.pump();
    await tester.pump();
    // Small boards can remain at the tile-size cap on both screens.
    expect(level.tileWidth, lessThanOrEqualTo(largeTileWidth + 0.001));
    expect(level.boardLeft, greaterThanOrEqualTo(0));
  });
}
