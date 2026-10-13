import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prismleaf_vale/main.dart';
import 'package:prismleaf_vale/brand/progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('storage failure shows retry and recovers to home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    var attempts = 0;
    var adsStarts = 0;
    await tester.pumpWidget(
      StartupApp(
        initializeAds: () async {
          adsStarts++;
        },
        loadProgress: () async {
          if (++attempts == 1) throw StateError('Storage unavailable');
          await GameProgress.instance.load();
        },
      ),
    );
    await tester.pump();
    expect(find.text('Try again'), findsOneWidget);
    expect(adsStarts, 0);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(adsStarts, 1);
    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
