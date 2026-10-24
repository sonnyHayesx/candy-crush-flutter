import 'package:flutter/material.dart';

import '../brand/brand_theme.dart';
import '../brand/progress.dart';
import '../brand/campaign.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your journey')),
    body: ValeBackdrop(
      child: SafeArea(
        child: AnimatedBuilder(
          animation: GameProgress.instance,
          builder: (context, _) {
            final progress = GameProgress.instance;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ValeCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trail progress',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Glades restored: ${progress.highestCompletedLevel} / ${Campaign.totalLevels}',
                      ),
                      Text('Total wins: ${progress.totalWins}'),
                      Text('Best scores combined: ${progress.bestTotalScore}'),
                      Text('Glow: ${progress.glow}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ValeCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily light',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Current streak: ${progress.currentStreak} days'),
                      Text('Longest streak: ${progress.longestStreak} days'),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: progress.canClaimDaily
                            ? () async {
                                final amount = await progress.claimDaily();
                                if (context.mounted && amount > 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Collected $amount glow'),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.wb_sunny_rounded),
                        label: Text(
                          progress.canClaimDaily
                              ? 'Claim today\'s glow'
                              : 'Come back tomorrow',
                        ),
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
                        'Valley colors',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Change the valley backdrop. Gameplay stays the same.',
                      ),
                      ListTile(
                        title: const Text('Forest'),
                        trailing: progress.selectedTheme == 'forest'
                            ? const Icon(Icons.check_circle_rounded)
                            : null,
                        onTap: () => progress.selectTheme('forest'),
                      ),
                      if (progress.twilightUnlocked)
                        ListTile(
                          title: const Text('Twilight'),
                          trailing: progress.selectedTheme == 'twilight'
                              ? const Icon(Icons.check_circle_rounded)
                              : null,
                          onTap: () => progress.selectTheme('twilight'),
                        )
                      else
                        OutlinedButton(
                          onPressed: progress.glow >= 100
                              ? progress.unlockTwilight
                              : null,
                          child: const Text('Unlock Twilight for 100 glow'),
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
                        'Best by glade',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (progress.bestScores.isEmpty)
                        const Text('Play a glade to set a new best.'),
                      for (final level
                          in (progress.bestScores.keys.toList()..sort()))
                        Text(
                          'Glade $level: ${progress.bestScores[level] ?? 0}',
                        ),
                      if (progress.legacyCompletedLevel > 0 ||
                          progress.legacyBestScores.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Original trail keepsakes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${progress.legacyCompletedLevel} original glades restored. Your earned trail access and glow are preserved.',
                        ),
                        const Text(
                          'These bests belong to the original five layouts.',
                        ),
                        for (final entry in progress.legacyBestScores.entries)
                          Text('Original glade ${entry.key}: ${entry.value}'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ValeCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent glow rewards',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (progress.rewardHistory.isEmpty)
                        const Text('Your rewards will appear here.'),
                      for (final record in progress.rewardHistory.take(10))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '${record.day}  •  ${record.kind == 'daily' ? 'Daily light (day ${record.detail})' : '${record.campaignVersion == 1 ? 'Original glade' : 'Glade'} ${record.detail} clear'}  •  +${record.glow} glow',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
