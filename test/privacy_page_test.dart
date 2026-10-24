import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prismleaf_vale/pages/privacy_page.dart';

void main() {
  const channel = MethodChannel('prismleafvale/privacy');
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  testWidgets('policy opens externally without leaving the privacy screen', (
    tester,
  ) async {
    String? method;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      method = call.method;
      return null;
    });
    await tester.pumpWidget(const MaterialApp(home: PrivacyPage()));
    await tester.tap(find.text('Privacy Policy'));
    await tester.pump();
    expect(method, 'openPrivacyPolicy');
    expect(find.byType(PrivacyPage), findsOneWidget);
    expect(find.text(PrivacyPage.policyUrl), findsOneWidget);
  });

  testWidgets('browser failure leaves a readable policy address', (
    tester,
  ) async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'browser_unavailable');
    });
    await tester.pumpWidget(const MaterialApp(home: PrivacyPage()));
    await tester.tap(find.text('Privacy Policy'));
    await tester.pump();
    expect(find.textContaining('Could not open a browser'), findsOneWidget);
    expect(find.text(PrivacyPage.policyUrl), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
