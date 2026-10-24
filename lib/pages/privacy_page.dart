import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../brand/brand_theme.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  static const policyUrl = 'https://sonnyhayesx.github.io/app-privacy-policy/';
  static const _channel = MethodChannel('prismleafvale/privacy');

  Future<void> _openPolicy(BuildContext context) async {
    try {
      await _channel.invokeMethod<void>('openPrivacyPolicy');
    } on PlatformException {
      if (context.mounted) _showBrowserError(context);
    } on MissingPluginException {
      if (context.mounted) _showBrowserError(context);
    }
  }

  void _showBrowserError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not open a browser. Copy the policy address below.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacy & data')),
    body: ValeBackdrop(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ValeCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.icon(
                    onPressed: () => _openPolicy(context),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Privacy Policy'),
                  ),
                  const SizedBox(height: 8),
                  const Text('Opens in your browser.'),
                  const SizedBox(height: 8),
                  const SelectableText(policyUrl),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ValeCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'On your device',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Prismleaf Vale stores unlocked glades, scores, glow, '
                    'daily rewards, streaks, recent reward history, and '
                    'sound and color preferences on this '
                    'device. No account or game server is used. Clearing app '
                    'storage removes this local progress.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ValeCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Optional ads',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The game may show a banner on the trail map and offers '
                    'an optional rewarded ad for three extra moves. Ads are '
                    'never needed to play. When ads are enabled, Google Mobile '
                    'Ads and its consent tool may process IP address, app '
                    'interactions, diagnostics, and device identifiers for ad '
                    'delivery, measurement, and fraud prevention. Available '
                    'privacy choices appear in Settings where required.',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This all-ages game requests child-directed advertising '
                    'with a maximum G content rating for everyone. It does '
                    'not ask for your age.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
