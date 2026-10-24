# Production engine analysis

The game is an adjacent-swap match-three game, not a tap-to-clear cluster game. Inspection covers `lib/controller/game_controller.dart`, `lib/model/{level,tile,chain,combo,array_2d}.dart`, `lib/animations/model/animations_resolver.dart`, `lib/bloc/game_bloc.dart`, and the move orchestration in `lib/pages/game_page.dart`.

## Level schema and coordinates

JSON grid rows run top to bottom. `Level.fromJson` reverses them: engine row zero is the bottom. `1` is a normal random-colored tile; `2` is a random-colored tile frozen at depth one (cannot be swapped until thawed); `X` is absent board space; `W` is a permanent wall. Walls are not clearable objectives. A normal match or explosion removes one frozen layer before the tile can be removed. Some legacy cascade code treats frozen tiles differently from immediate matches; simulations deliberately reuse that production code rather than assert an idealized rule.

The legacy Array2d API names its axes inconsistently with controller call sites. This campaign uses square dimensions only, from 5 to 10; masks provide rectangular-looking, asymmetric and other shapes without invoking unsupported rectangular storage behavior. Fully void columns are guarded in the refill entry lookup.

## Matching and specials

Six normal colors (red, green, blue, orange, purple, yellow) are equally likely per random draw. Initial construction rejects immediate horizontal/vertical triples and retries until a legal swap exists, capped at 1,000 attempts. Legal swaps are orthogonally adjacent, movable tiles, and normally must make a run of at least three equal exact TileTypes. Specials can also be tapped or swapped. A source special explodes after a swap; the legacy UI does not symmetrically explode a destination special. The solver follows that actual directional rule.

A three-match removes tiles. Four distinct matched tiles create a colored line special; five create wrapped; six create bomb; seven or more create fireball. Intersecting horizontal/vertical chains are counted by their union, not just longest line. The line-special orientation is perpendicular to the four-match line. Specials do not match as their underlying normal color.

Bomb explosion covers Manhattan radius two; wrapped covers Manhattan radius three; line specials clear their row/column within the existing ten-cell offsets; flare's own cross footprint has radius one. Chained explosions are supported. The previously generated fireball had no explosion entry and could consume moves without clearing itself; it now uses the existing wrapped footprint so generated specials remain usable.

## Objectives, moves and result

Color objectives count production tile events, mostly removals. Immediate special creation and special removal both emit events, so a special objective is an event target, not a count of taps alone. Legacy `flare` objectives were unreachable because four-matches create colored stripe TileTypes. Stripe events now normalize to `flare`. `bomb` remains the six-tile combination or its later removal; wrapped is not silently treated as bomb. Cascade-created specials now emit creation events consistently with immediate combos.

A valid swap or special tap consumes one move after all cascades finish. Invalid swaps do not consume moves. Victory is checked before zero-move defeat, so completing objectives with the final move wins. No boosts, ad rewards or added moves are used in validation. The production score stream is irrelevant to the solver.

## Falling, cascades and random state

The animation resolver is also the physics engine: it computes vertical falls, diagonal avalanches around obstacles, refills, subsequent combos and objective events before visual animations run. Refills avoid repeating the immediately previously inserted color within each insertion batch, but cascades can still occur. Refill enters the highest nonvoid cell of a column; top walls block normal entry. The controller fills residual empty cells during final commit, matching existing gameplay. A no-move board is automatically reshuffled without spending an extra move; normal cells are regenerated and frozen template cells may freeze again. This guarantees available actions only when reshuffling succeeds, not winnability within the remaining budget.

The controller formerly used a separate unseeded generator from the resolver. Both now share the controller RNG, optional constructor injection preserves ordinary random play. `GameBloc.simulation(definition,seed)` builds the same production objects synchronously. Seeds are reproducible on the installed Dart SDK; cross-SDK pseudorandom compatibility is not promised. No changes to player randomness favor a solver trace.

Diagonal avalanche column coordinates and post-avalanche involved-cell registration were corrected so settled tiles retain correct logical positions. The all-void-column entry scan now bounds-checks. These fixes are exercised by irregular campaign board simulations.

## Validation implementation and limits

`tool/level_solver.dart` drives the exact same initial combo resolution, explosions, AnimationsResolver, final refresh, move accounting, and reshuffle order as GamePage. It skips rendering/waiting, not game rules. Legal actions are deterministically sorted. One-ply heuristic search scores visible objective matches, specials, and frozen layers; it does not peek at refill RNG. Beginner and average approximations mix random legal actions with the heuristic (65% and 20% respectively); strategic always uses the heuristic and values special creation more. They are uncalibrated synthetic policies, not measured human skill levels.

`tool/validate_levels_test.dart` defaults to 100 fixed seeds per policy per level (300 trials per level). The seed formula is `100000 + levelId + trialIndex * 1009`. It records successes, failures, moves, reshuffles, remaining objectives and a complete winning action trace; each witness is replayed through a fresh production state. A winning trace proves that seeded trajectory only. Rates do not establish universal solvability, a minimum move count, or player enjoyment. Human device playtesting remains necessary.

Progress/loading/UI integration is documented and tested separately in the campaign progress tests and level reordering report.
