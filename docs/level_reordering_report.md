# Campaign replacement and original-level mapping

The exact five input definitions are preserved in `tool/legacy_levels.json`.
No commercial game's board was copied. The campaign generator builds ten recurring
silhouette families, with size, asymmetry, terrain and collection changes; recurring
families deliberately give players opportunities to practice familiar structures.

| Original | New position | Treatment and reason |
|---|---:|---|
| 1 | 16 | Retain full 10×10 board; replace its unexplained flare requirement with color collection after introductory play. |
| 2 | 8 | Retain alternating side cutouts in its 5×5 board; introduce this constrained space after five generous opening boards. Rebalance targets and moves. |
| 3 | 76 | Retain original walls, frozen cells and irregular 10×10 outline; replace rare bomb objective with color goals. Terrain combinations belong late in the campaign. |
| 4 | 56 | Retain original outline and two frozen cells; replace special-dependent opening goals with later collection pressure. |
| 5 | 24 | Retain narrow 5×5 cross; moderate its quotas because its small move-selection space is harder than its size suggests. |

All five are **adaptations**, not unchanged puzzles: move budgets and objectives are
rebalanced. New positions describe design ancestry, not equivalent achievement.

The first five levels use 6×6 boards, one or two ordinary color targets, 24 moves,
and no walls, frozen pieces or special-item requirements. Small boundary cutouts
introduce different outlines without splitting the playing area. Their quotas rise
from four pieces of one color to eight and ten pieces of two colors. Actual sampled
completion rates and winning traces are recorded separately in the validation report;
ease and enjoyment still need human playtesting.

Later chapters combine color collection, frozen cells (after 21), a generous stripe
goal tutorial at 18 and later stripe goals from 39, and permanent walls (after 41). Chapter openings and sixth
positions provide recovery beats with lower quotas, more moves and simpler terrain.
Levels 56 and 76 are explicit exceptions: their retained legacy geometry contains obstacles.
These are authored pacing intentions; measured difficulty is the evidence used to
assess them, rather than assuming level numbers prove a smooth curve.

The initial 30,000-trial pass found no winning witness for 13 later levels.
`tool/level_balance.json` preserves that baseline's per-level average-policy rates
and the explicit color-quota corrections. The generator applies these corrections
without altering the first five levels or terrain. Level 8 receives a separate
introductory quota reduction. Required stripe counts are never rounded away.
The final validation reruns the same seeds, so these results are calibration
evidence rather than an independent estimate of human success.

## Existing player saves

Migration preserves earned unlocked positions as grandfathered campaign credit.
It does not pretend completion of an old board proves completion of its later
adaptation. Original best scores are archived and labeled as original-trail scores;
the revised boards get their own score history. Rewards, currency and cosmetic
ownership remain intact. A player who finished the original fifth level can proceed
to level 6. This favors preserving access without silently attaching old scores to
different puzzles. See progression tests for repeated-load and level-100 behavior.

## Reproduction

Run `dart run tool/generate_levels.dart` from the project root, then run the
production-engine validator described in `game_engine_analysis.md`. Generation
alone is not a solvability check. The separate design metadata file does not alter
the app's level JSON schema.
