# Measured campaign difficulty

These are seeded heuristic-agent results, not human win rates. A replayed winning trace proves one reachable win for that level, not that every random deal is winnable. No booster, advertisement or extra move is used.

Difficulty score = 100 × (1 − average-policy win rate). Policies use different random-choice rates and visible-board heuristics; their names do not establish real human skill. Each policy receives 100 seeds per level in the full run.

Validated results: 100/100; replayed winning traces: 100.

| Chapter | Mean average-policy win rate |
|---|---:|
| 1 | 99.1% |
| 2 | 95.2% |
| 3 | 89.0% |
| 4 | 76.8% |
| 5 | 72.3% |
| 6 | 67.4% |
| 7 | 60.2% |
| 8 | 56.5% |
| 9 | 52.0% |
| 10 | 41.3% |

Scores may jump between neighboring levels because board geometry, frozen cells, walls and goal pressure interact. Recovery beats are design intent, not a guarantee of easier measured play. Low-rate levels and sharp jumps need further balancing and human playtesting before claiming a fair smooth curve.

| Level | Source | Board | Moves | Goals | Frozen / walls / voids | Beginner / average / strategic wins | Score | Witness | Design reason |
|---:|---|---|---:|---|---|---|---:|---|---|
| 1 | original campaign design | 6×6 | 24 | 4;blue | 0 / 0 / 2 | 100% / 100% / 100% | 0.0 | true | Generous color-only onboarding; no frozen cells or walls. |
| 2 | original campaign design | 6×6 | 24 | 5;blue | 0 / 0 / 4 | 100% / 100% / 100% | 0.0 | true | Generous color-only onboarding; no frozen cells or walls. |
| 3 | original campaign design | 6×6 | 24 | 6;blue, 8;red | 0 / 0 / 2 | 98% / 100% / 100% | 0.0 | true | Generous color-only onboarding; no frozen cells or walls. |
| 4 | original campaign design | 6×6 | 24 | 7;red, 9;purple | 0 / 0 / 2 | 99% / 100% / 100% | 0.0 | true | Generous color-only onboarding; no frozen cells or walls. |
| 5 | original campaign design | 6×6 | 24 | 8;red, 10;purple | 0 / 0 / 4 | 94% / 97% / 99% | 3.0 | true | Generous color-only onboarding; no frozen cells or walls. |
| 6 | original campaign design | 6×6 | 30 | 12;red, 14;purple | 0 / 0 / 6 | 92% / 100% / 98% | 0.0 | true | Practice silhouette 5 with chapter 1 collection pressure and terrain. |
| 7 | original campaign design | 7×7 | 30 | 13;purple, 15;green | 0 / 0 / 6 | 94% / 100% / 100% | 0.0 | true | Practice silhouette 6 with chapter 1 collection pressure and terrain. |
| 8 | adapted legacy 2 | 5×5 | 30 | 11;purple, 12;green | 0 / 0 / 4 | 91% / 95% / 97% | 5.0 | true | Practice silhouette 7 with chapter 1 collection pressure and terrain. |
| 9 | original campaign design | 9×9 | 30 | 15;purple, 17;green | 0 / 0 / 4 | 100% / 99% / 100% | 1.0 | true | Practice silhouette 8 with chapter 1 collection pressure and terrain. |
| 10 | original campaign design | 10×10 | 30 | 16;green, 18;yellow | 0 / 0 / 12 | 100% / 100% / 100% | 0.0 | true | Practice silhouette 9 with chapter 1 collection pressure and terrain. |
| 11 | original campaign design | 7×7 | 30 | 7;red, 9;purple, 7;green | 0 / 0 / 2 | 100% / 100% / 100% | 0.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 12 | original campaign design | 8×8 | 30 | 11;red, 13;purple, 11;green | 0 / 0 / 4 | 100% / 100% / 100% | 0.0 | true | Practice silhouette 1 with chapter 2 collection pressure and terrain. |
| 13 | original campaign design | 9×9 | 30 | 12;red, 14;purple, 12;green | 0 / 0 / 4 | 99% / 100% / 100% | 0.0 | true | Practice silhouette 2 with chapter 2 collection pressure and terrain. |
| 14 | original campaign design | 10×10 | 30 | 13;purple, 15;green, 13;yellow | 0 / 0 / 4 | 100% / 100% / 100% | 0.0 | true | Practice silhouette 3 with chapter 2 collection pressure and terrain. |
| 15 | original campaign design | 6×6 | 30 | 14;purple, 16;green, 14;yellow | 0 / 0 / 5 | 78% / 95% / 91% | 5.0 | true | Practice silhouette 4 with chapter 2 collection pressure and terrain. |
| 16 | adapted legacy 1 | 10×10 | 30 | 11;purple, 13;green, 11;yellow | 0 / 0 / 0 | 100% / 100% / 100% | 0.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 17 | original campaign design | 8×8 | 30 | 16;green, 18;yellow, 16;orange | 0 / 0 / 6 | 90% / 99% / 99% | 1.0 | true | Practice silhouette 6 with chapter 2 collection pressure and terrain. |
| 18 | original campaign design | 9×9 | 30 | 6;blue, 6;red, 1;flare | 0 / 0 / 4 | 100% / 100% / 100% | 0.0 | true | Introduce one stripe goal on open terrain with low color quotas and 30 moves. |
| 19 | original campaign design | 10×10 | 30 | 18;green, 20;yellow, 18;orange | 0 / 0 / 4 | 97% / 100% / 100% | 0.0 | true | Practice silhouette 8 with chapter 2 collection pressure and terrain. |
| 20 | original campaign design | 6×6 | 30 | 19;yellow, 21;orange, 19;blue | 0 / 0 / 8 | 26% / 58% / 62% | 42.0 | true | Practice silhouette 9 with chapter 2 collection pressure and terrain. |
| 21 | original campaign design | 8×8 | 30 | 9;purple, 11;green, 9;yellow | 0 / 0 / 2 | 100% / 100% / 100% | 0.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 22 | original campaign design | 9×9 | 30 | 14;purple, 16;green, 14;yellow | 3 / 0 / 4 | 99% / 100% / 100% | 0.0 | true | Practice silhouette 1 with chapter 3 collection pressure and terrain. |
| 23 | original campaign design | 10×10 | 30 | 15;purple, 17;green, 15;yellow | 4 / 0 / 4 | 100% / 100% / 100% | 0.0 | true | Practice silhouette 2 with chapter 3 collection pressure and terrain. |
| 24 | adapted legacy 5 | 5×5 | 30 | 10;green, 12;yellow, 10;orange | 0 / 0 / 10 | 76% / 81% / 86% | 19.0 | true | Practice silhouette 3 with chapter 3 collection pressure and terrain. |
| 25 | original campaign design | 7×7 | 30 | 17;green, 19;yellow, 17;orange | 3 / 0 / 4 | 70% / 96% / 97% | 4.0 | true | Practice silhouette 4 with chapter 3 collection pressure and terrain. |
| 26 | original campaign design | 8×8 | 30 | 13;green, 15;yellow, 13;orange | 0 / 0 / 8 | 98% / 100% / 100% | 0.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 27 | original campaign design | 9×9 | 30 | 19;yellow, 21;orange, 19;blue | 2 / 0 / 6 | 90% / 98% / 99% | 2.0 | true | Practice silhouette 6 with chapter 3 collection pressure and terrain. |
| 28 | original campaign design | 10×10 | 30 | 20;yellow, 22;orange, 20;blue | 3 / 0 / 4 | 97% / 100% / 99% | 0.0 | true | Practice silhouette 7 with chapter 3 collection pressure and terrain. |
| 29 | original campaign design | 6×6 | 30 | 19;yellow, 21;orange, 19;blue | 4 / 0 / 4 | 30% / 54% / 54% | 46.0 | true | Practice silhouette 8 with chapter 3 collection pressure and terrain. |
| 30 | original campaign design | 7×7 | 30 | 20;orange, 22;blue, 20;red | 2 / 0 / 10 | 42% / 61% / 67% | 39.0 | true | Practice silhouette 9 with chapter 3 collection pressure and terrain. |
| 31 | original campaign design | 9×9 | 30 | 11;green, 13;yellow, 11;orange | 0 / 0 / 2 | 100% / 100% / 100% | 0.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 32 | original campaign design | 10×10 | 29 | 17;green, 19;yellow, 17;orange | 3 / 0 / 4 | 97% / 100% / 100% | 0.0 | true | Practice silhouette 1 with chapter 4 collection pressure and terrain. |
| 33 | original campaign design | 6×6 | 29 | 18;green, 20;yellow, 18;orange | 4 / 0 / 2 | 34% / 60% / 73% | 40.0 | true | Practice silhouette 2 with chapter 4 collection pressure and terrain. |
| 34 | original campaign design | 7×7 | 29 | 19;yellow, 21;orange, 19;blue | 2 / 0 / 3 | 52% / 70% / 84% | 30.0 | true | Practice silhouette 3 with chapter 4 collection pressure and terrain. |
| 35 | original campaign design | 8×8 | 29 | 20;yellow, 22;orange, 20;blue | 3 / 0 / 4 | 59% / 90% / 93% | 10.0 | true | Practice silhouette 4 with chapter 4 collection pressure and terrain. |
| 36 | original campaign design | 9×9 | 30 | 15;yellow, 17;orange, 15;blue | 0 / 0 / 8 | 98% / 100% / 100% | 0.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 37 | original campaign design | 10×10 | 29 | 22;orange, 24;blue, 22;red | 2 / 0 / 6 | 80% / 97% / 100% | 3.0 | true | Practice silhouette 6 with chapter 4 collection pressure and terrain. |
| 38 | original campaign design | 6×6 | 29 | 19;orange, 20;blue, 19;red | 3 / 0 / 4 | 22% / 45% / 59% | 55.0 | true | Practice silhouette 7 with chapter 4 collection pressure and terrain. |
| 39 | original campaign design | 7×7 | 29 | 22;orange, 24;blue, 22;red, 1;flare | 4 / 0 / 4 | 24% / 49% / 66% | 51.0 | true | Practice silhouette 8 with chapter 4 collection pressure and terrain. |
| 40 | original campaign design | 8×8 | 29 | 25;blue, 27;red, 25;purple | 2 / 0 / 10 | 30% / 57% / 70% | 43.0 | true | Practice silhouette 9 with chapter 4 collection pressure and terrain. |
| 41 | original campaign design | 10×10 | 30 | 13;yellow, 15;orange, 13;blue | 0 / 0 / 2 | 100% / 100% / 100% | 0.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 42 | original campaign design | 6×6 | 29 | 16;yellow, 18;orange, 16;blue | 4 / 2 / 4 | 22% / 44% / 39% | 56.0 | true | Practice silhouette 1 with chapter 5 collection pressure and terrain. |
| 43 | original campaign design | 7×7 | 29 | 19;yellow, 21;orange, 19;blue | 5 / 2 / 3 | 26% / 52% / 62% | 48.0 | true | Practice silhouette 2 with chapter 5 collection pressure and terrain. |
| 44 | original campaign design | 8×8 | 29 | 22;orange, 24;blue, 22;red | 3 / 0 / 3 | 59% / 87% / 90% | 13.0 | true | Practice silhouette 3 with chapter 5 collection pressure and terrain. |
| 45 | original campaign design | 9×9 | 29 | 23;orange, 25;blue, 23;red | 4 / 2 / 6 | 57% / 81% / 91% | 19.0 | true | Practice silhouette 4 with chapter 5 collection pressure and terrain. |
| 46 | original campaign design | 10×10 | 30 | 17;orange, 19;blue, 17;red | 0 / 0 / 10 | 96% / 100% / 100% | 0.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 47 | original campaign design | 6×6 | 29 | 17;blue, 18;red, 17;purple | 3 / 0 / 6 | 52% / 69% / 76% | 31.0 | true | Practice silhouette 6 with chapter 5 collection pressure and terrain. |
| 48 | original campaign design | 7×7 | 29 | 17;blue, 19;red, 17;purple | 4 / 2 / 4 | 55% / 74% / 76% | 26.0 | true | Practice silhouette 7 with chapter 5 collection pressure and terrain. |
| 49 | original campaign design | 8×8 | 29 | 22;blue, 24;red, 22;purple, 1;flare | 5 / 2 / 4 | 46% / 66% / 78% | 34.0 | true | Practice silhouette 8 with chapter 5 collection pressure and terrain. |
| 50 | original campaign design | 9×9 | 29 | 28;red, 30;purple, 28;green | 3 / 0 / 12 | 26% / 50% / 76% | 50.0 | true | Practice silhouette 9 with chapter 5 collection pressure and terrain. |
| 51 | original campaign design | 6×6 | 30 | 15;orange, 17;blue, 15;red | 0 / 0 / 3 | 82% / 91% / 94% | 9.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 52 | original campaign design | 7×7 | 29 | 21;orange, 23;blue, 21;red | 4 / 2 / 5 | 27% / 50% / 56% | 50.0 | true | Practice silhouette 1 with chapter 6 collection pressure and terrain. |
| 53 | original campaign design | 8×8 | 29 | 22;orange, 24;blue, 22;red | 4 / 2 / 4 | 38% / 62% / 74% | 38.0 | true | Practice silhouette 2 with chapter 6 collection pressure and terrain. |
| 54 | original campaign design | 9×9 | 29 | 25;blue, 27;red, 25;purple | 3 / 0 / 5 | 50% / 80% / 92% | 20.0 | true | Practice silhouette 3 with chapter 6 collection pressure and terrain. |
| 55 | original campaign design | 10×10 | 29 | 26;blue, 28;red, 26;purple | 4 / 2 / 7 | 66% / 92% / 98% | 8.0 | true | Practice silhouette 4 with chapter 6 collection pressure and terrain. |
| 56 | adapted legacy 4 | 10×10 | 30 | 19;blue, 21;red, 19;purple | 2 / 0 / 16 | 96% / 100% / 100% | 0.0 | true | Legacy terrain combination with relaxed quotas; not a terrain recovery level. |
| 57 | original campaign design | 7×7 | 29 | 23;red, 24;purple, 23;green | 3 / 0 / 7 | 17% / 47% / 61% | 53.0 | true | Practice silhouette 6 with chapter 6 collection pressure and terrain. |
| 58 | original campaign design | 8×8 | 29 | 24;red, 25;purple, 24;green | 4 / 2 / 5 | 22% / 46% / 63% | 54.0 | true | Practice silhouette 7 with chapter 6 collection pressure and terrain. |
| 59 | original campaign design | 9×9 | 29 | 30;red, 32;purple, 30;green, 1;flare | 5 / 2 / 4 | 19% / 50% / 62% | 50.0 | true | Practice silhouette 8 with chapter 6 collection pressure and terrain. |
| 60 | original campaign design | 10×10 | 29 | 31;purple, 33;green, 31;yellow | 3 / 0 / 13 | 31% / 56% / 81% | 44.0 | true | Practice silhouette 9 with chapter 6 collection pressure and terrain. |
| 61 | original campaign design | 7×7 | 30 | 18;blue, 20;red, 18;purple | 0 / 0 / 3 | 76% / 94% / 97% | 6.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 62 | original campaign design | 8×8 | 28 | 21;blue, 23;red, 21;purple | 4 / 2 / 5 | 44% / 59% / 76% | 41.0 | true | Practice silhouette 1 with chapter 7 collection pressure and terrain. |
| 63 | original campaign design | 9×9 | 28 | 27;blue, 29;red, 27;purple | 6 / 2 / 5 | 22% / 58% / 65% | 42.0 | true | Practice silhouette 2 with chapter 7 collection pressure and terrain. |
| 64 | original campaign design | 10×10 | 28 | 28;red, 30;purple, 28;green | 4 / 0 / 5 | 46% / 82% / 92% | 18.0 | true | Practice silhouette 3 with chapter 7 collection pressure and terrain. |
| 65 | original campaign design | 6×6 | 28 | 16;red, 18;purple, 16;green | 4 / 2 / 5 | 26% / 36% / 46% | 64.0 | true | Practice silhouette 4 with chapter 7 collection pressure and terrain. |
| 66 | original campaign design | 7×7 | 30 | 21;red, 23;purple, 21;green | 0 / 0 / 6 | 43% / 69% / 84% | 31.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 67 | original campaign design | 8×8 | 28 | 25;purple, 27;green, 25;yellow | 4 / 0 / 7 | 26% / 62% / 65% | 38.0 | true | Practice silhouette 6 with chapter 7 collection pressure and terrain. |
| 68 | original campaign design | 9×9 | 28 | 29;purple, 31;green, 29;yellow | 5 / 2 / 4 | 19% / 61% / 69% | 39.0 | true | Practice silhouette 7 with chapter 7 collection pressure and terrain. |
| 69 | original campaign design | 10×10 | 28 | 33;purple, 35;green, 33;yellow, 1;flare | 6 / 2 / 5 | 24% / 56% / 62% | 44.0 | true | Practice silhouette 8 with chapter 7 collection pressure and terrain. |
| 70 | original campaign design | 6×6 | 28 | 19;green, 20;yellow, 19;orange | 4 / 0 / 9 | 13% / 25% / 32% | 75.0 | true | Practice silhouette 9 with chapter 7 collection pressure and terrain. |
| 71 | original campaign design | 8×8 | 30 | 20;red, 22;purple, 20;green | 0 / 0 / 4 | 67% / 90% / 97% | 10.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 72 | original campaign design | 9×9 | 28 | 27;red, 28;purple, 27;green | 5 / 2 / 6 | 24% / 58% / 68% | 42.0 | true | Practice silhouette 1 with chapter 8 collection pressure and terrain. |
| 73 | original campaign design | 10×10 | 28 | 30;red, 32;purple, 30;green | 6 / 2 / 6 | 40% / 70% / 83% | 30.0 | true | Practice silhouette 2 with chapter 8 collection pressure and terrain. |
| 74 | original campaign design | 6×6 | 28 | 18;purple, 19;green, 18;yellow | 4 / 0 / 4 | 35% / 66% / 63% | 34.0 | true | Practice silhouette 3 with chapter 8 collection pressure and terrain. |
| 75 | original campaign design | 7×7 | 28 | 18;purple, 19;green, 18;yellow | 5 / 2 / 6 | 41% / 62% / 61% | 38.0 | true | Practice silhouette 4 with chapter 8 collection pressure and terrain. |
| 76 | adapted legacy 3 | 10×10 | 30 | 21;purple, 23;green, 21;yellow | 2 / 10 / 17 | 30% / 58% / 61% | 42.0 | true | Legacy terrain combination with relaxed quotas; not a terrain recovery level. |
| 77 | original campaign design | 9×9 | 28 | 28;green, 29;yellow, 28;orange | 4 / 0 / 8 | 27% / 60% / 76% | 40.0 | true | Practice silhouette 6 with chapter 8 collection pressure and terrain. |
| 78 | original campaign design | 10×10 | 28 | 32;green, 34;yellow, 32;orange | 5 / 2 / 6 | 23% / 63% / 73% | 37.0 | true | Practice silhouette 7 with chapter 8 collection pressure and terrain. |
| 79 | original campaign design | 6×6 | 28 | 20;green, 21;yellow, 20;orange, 1;flare | 3 / 2 / 6 | 4% / 5% / 7% | 95.0 | true | Practice silhouette 8 with chapter 8 collection pressure and terrain. |
| 80 | original campaign design | 7×7 | 28 | 21;yellow, 22;orange, 21;blue | 4 / 0 / 12 | 18% / 33% / 45% | 67.0 | true | Practice silhouette 9 with chapter 8 collection pressure and terrain. |
| 81 | original campaign design | 9×9 | 30 | 22;purple, 24;green, 22;yellow | 0 / 0 / 4 | 80% / 99% / 100% | 1.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 82 | original campaign design | 10×10 | 28 | 32;purple, 34;green, 32;yellow | 6 / 3 / 6 | 30% / 53% / 64% | 47.0 | true | Practice silhouette 1 with chapter 9 collection pressure and terrain. |
| 83 | original campaign design | 6×6 | 28 | 19;purple, 20;green, 19;yellow | 3 / 3 / 4 | 12% / 14% / 11% | 86.0 | true | Practice silhouette 2 with chapter 9 collection pressure and terrain. |
| 84 | original campaign design | 7×7 | 28 | 19;green, 20;yellow, 19;orange | 5 / 0 / 5 | 52% / 80% / 80% | 20.0 | true | Practice silhouette 3 with chapter 9 collection pressure and terrain. |
| 85 | original campaign design | 8×8 | 28 | 23;green, 25;yellow, 23;orange | 5 / 3 / 6 | 15% / 40% / 54% | 60.0 | true | Practice silhouette 4 with chapter 9 collection pressure and terrain. |
| 86 | original campaign design | 9×9 | 30 | 25;green, 27;yellow, 25;orange | 0 / 0 / 9 | 48% / 83% / 93% | 17.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 87 | original campaign design | 10×10 | 28 | 30;yellow, 32;orange, 30;blue | 5 / 0 / 8 | 38% / 74% / 87% | 26.0 | true | Practice silhouette 6 with chapter 9 collection pressure and terrain. |
| 88 | original campaign design | 6×6 | 28 | 21;yellow, 22;orange, 21;blue | 3 / 3 / 6 | 1% / 1% / 2% | 99.0 | true | Practice silhouette 7 with chapter 9 collection pressure and terrain. |
| 89 | original campaign design | 7×7 | 28 | 22;yellow, 23;orange, 22;blue, 1;flare | 5 / 3 / 6 | 1% / 11% / 16% | 89.0 | true | Practice silhouette 8 with chapter 9 collection pressure and terrain. |
| 90 | original campaign design | 8×8 | 28 | 22;orange, 24;blue, 22;red | 5 / 0 / 12 | 30% / 65% / 68% | 35.0 | true | Practice silhouette 9 with chapter 9 collection pressure and terrain. |
| 91 | original campaign design | 10×10 | 30 | 24;green, 26;yellow, 24;orange | 0 / 0 / 4 | 82% / 97% / 100% | 3.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 92 | original campaign design | 6×6 | 27 | 20;green, 21;yellow, 20;orange | 2 / 3 / 7 | 0% / 3% / 5% | 97.0 | true | Practice silhouette 1 with chapter 10 collection pressure and terrain. |
| 93 | original campaign design | 7×7 | 27 | 20;green, 21;yellow, 20;orange | 5 / 3 / 5 | 19% / 19% / 32% | 81.0 | true | Practice silhouette 2 with chapter 10 collection pressure and terrain. |
| 94 | original campaign design | 8×8 | 27 | 25;yellow, 26;orange, 25;blue | 5 / 0 / 5 | 17% / 48% / 67% | 52.0 | true | Practice silhouette 3 with chapter 10 collection pressure and terrain. |
| 95 | original campaign design | 9×9 | 27 | 25;yellow, 26;orange, 25;blue | 6 / 3 / 8 | 14% / 48% / 58% | 52.0 | true | Practice silhouette 4 with chapter 10 collection pressure and terrain. |
| 96 | original campaign design | 10×10 | 30 | 27;yellow, 29;orange, 27;blue | 0 / 0 / 11 | 59% / 94% / 98% | 6.0 | true | Recovery: reduced quotas, generous moves and uncluttered terrain. |
| 97 | original campaign design | 6×6 | 27 | 22;orange, 24;blue, 22;red | 4 / 0 / 8 | 2% / 6% / 7% | 94.0 | true | Practice silhouette 6 with chapter 10 collection pressure and terrain. |
| 98 | original campaign design | 7×7 | 27 | 23;orange, 24;blue, 23;red | 5 / 3 / 5 | 6% / 8% / 7% | 92.0 | true | Practice silhouette 7 with chapter 10 collection pressure and terrain. |
| 99 | original campaign design | 8×8 | 27 | 24;orange, 25;blue, 24;red, 1;flare | 5 / 3 / 5 | 7% / 26% / 37% | 74.0 | true | Practice silhouette 8 with chapter 10 collection pressure and terrain. |
| 100 | original campaign design | 9×9 | 27 | 24;blue, 25;red, 24;purple | 5 / 0 / 14 | 37% / 64% / 85% | 36.0 | true | Practice silhouette 9 with chapter 10 collection pressure and terrain. |

Full seeds, failure reasons, actions and replay evidence: `level_validation_results.json`. Reproduce using `flutter test tool/validate_levels_test.dart --dart-define=TRIALS=100 --reporter expanded`, then `dart run tool/report_level_validation.dart`. SDK version and source hash are recorded in the readiness audit.
