import 'package:flutter_test/flutter_test.dart';
import 'package:prismleaf_vale/bloc/game_bloc.dart';
import 'package:prismleaf_vale/main.dart';
import 'package:prismleaf_vale/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:prismleaf_vale/brand/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prismleaf_vale/ads/banner_slot.dart';
import 'package:prismleaf_vale/bloc/bloc_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('A level can be selected while assets load', (tester) async {
    late GameBloc gameBloc;
    final level = await tester.runAsync(() async {
      gameBloc = GameBloc();
      return gameBloc.setLevel(3);
    });
    expect(level?.index, 3);
    gameBloc.dispose();
  });

  testWidgets('App launches into the branded home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(HomePage), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).title,
      'Prismleaf Vale',
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('Completing a glade unlocks the next one and saves it', () async {
    await GameProgress.instance.load();
    await GameProgress.instance.complete(1, 5);
    expect(GameProgress.instance.unlockedLevel, 2);
    expect(GameProgress.instance.highestCompletedLevel, 1);
    expect(
      (await SharedPreferences.getInstance()).getInt(
        'prismleaf_unlocked_level',
      ),
      2,
    );
  });

  testWidgets('home banner is removed on covered and replacement routes', (
    tester,
  ) async {
    final bloc = GameBloc();
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      BlocProvider<GameBloc>(
        bloc: bloc,
        child: MaterialApp(navigatorKey: navigator, home: const HomePage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(BannerSlot, skipOffstage: false), findsOneWidget);
    navigator.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Game route')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(BannerSlot, skipOffstage: false), findsNothing);
    navigator.currentState!.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Next game route')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(BannerSlot, skipOffstage: false), findsNothing);
    navigator.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(BannerSlot, skipOffstage: false), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    bloc.dispose();
  });
}
