import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prismleaf_vale/brand/campaign.dart';
import 'package:prismleaf_vale/brand/progress.dart';
import 'package:prismleaf_vale/bloc/bloc_provider.dart';
import 'package:prismleaf_vale/bloc/game_bloc.dart';
import 'package:prismleaf_vale/pages/home_page.dart';
import 'package:prismleaf_vale/model/level.dart';
import 'package:prismleaf_vale/splash/game_over_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all 100 glades have distinct names and ten chapters', () {
    expect({
      for (var level = 1; level <= 100; level++) Campaign.levelName(level),
    }, hasLength(100));
    expect(Campaign.chapterLabel(100), contains('Chapter 10'));
  });

  test(
    'legacy final clear preserves rewards and unlocks six, archives scores once',
    () async {
      SharedPreferences.setMockInitialValues({
        'prismleaf_unlocked_level': 5,
        'prismleaf_completed_level': 5,
        'prismleaf_glow': 321,
        'prismleaf_total_wins': 9,
        'prismleaf_best_scores': '{"1":120,"5":900}',
        'prismleaf_reward_history': jsonEncode([
          {'day': '2026-10-01', 'kind': 'level', 'glow': 50, 'detail': 5},
        ]),
      });
      var progress = GameProgress.forTesting();
      await progress.load();
      expect(progress.unlockedLevel, 6);
      expect(progress.highestCompletedLevel, 5);
      expect(progress.legacyCompletedLevel, 5);
      expect(progress.legacyBestScores, {1: 120, 5: 900});
      expect(progress.bestScores, isEmpty);
      expect(progress.glow, 321);
      expect(progress.totalWins, 9);
      expect(progress.rewardHistory.single.campaignVersion, 1);
      await progress.complete(1, 100, score: 100);
      progress = GameProgress.forTesting();
      await progress.load();
      expect(progress.legacyBestScores, {1: 120, 5: 900});
      expect(progress.bestScores, {1: 100});
      expect(progress.unlockedLevel, 6);
      expect(progress.rewardHistory.first.campaignVersion, 2);
    },
  );

  test(
    'full campaign unlocks sequentially and final clear survives restart',
    () async {
      SharedPreferences.setMockInitialValues({});
      var progress = GameProgress.forTesting();
      await progress.load();
      for (var level = 1; level <= 100; level++) {
        expect(progress.unlockedLevel, level);
        await progress.complete(level, 100, score: level * 10);
      }
      progress = GameProgress.forTesting();
      await progress.load();
      expect(progress.unlockedLevel, 100);
      expect(progress.highestCompletedLevel, 100);
      expect(progress.bestScores[100], 1000);
      expect(progress.totalWins, 100);
      final reward = await progress.complete(100, 100, score: 900);
      expect(reward, 20);
      expect(progress.unlockedLevel, 100);
      expect(progress.bestScores[100], 1000);
    },
  );

  testWidgets(
    'final glade celebrates campaign completion without next button',
    (tester) async {
      final level = Level.fromJson({
        'level': 100,
        'rows': 3,
        'cols': 3,
        'grid': ['1,1,1', '1,1,1', '1,1,1'],
        'moves': 20,
        'objective': ['3;blue'],
      });
      var exited = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                GameOverSplash(
                  success: true,
                  level: level,
                  onExit: () {
                    exited = true;
                  },
                  onRetry: () {},
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Valley restored!'), findsOneWidget);
      expect(find.text('Next glade'), findsNothing);
      await tester.tap(find.text('Trail map'));
      expect(exited, isTrue);
    },
  );

  testWidgets('trail lazily builds rows and reaches locked glade 100', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await GameProgress.instance.load();
    late GameBloc bloc;
    await tester.runAsync(() async {
      bloc = GameBloc();
      await bloc.levelsReady;
    });
    expect(bloc.numberOfLevels, 100);
    await tester.pumpWidget(
      BlocProvider<GameBloc>(
        bloc: bloc,
        child: const MaterialApp(home: HomePage()),
      ),
    );
    // The asset future completed in the real async zone; allow FutureBuilder's
    // subscription to that future to settle before pumping the fake clock.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await tester.pumpAndSettle();
    expect(find.text(Campaign.levelName(100)), findsNothing);
    await tester.scrollUntilVisible(
      find.text(Campaign.levelName(100)),
      500,
      maxScrolls: 60,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(Campaign.levelName(100)), findsOneWidget);
    final row = find
        .ancestor(
          of: find.text(Campaign.levelName(100)),
          matching: find.byType(InkWell),
        )
        .first;
    expect(tester.widget<InkWell>(row).onTap, isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    bloc.dispose();
  });
}
