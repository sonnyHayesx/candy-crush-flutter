import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ads/ads_service.dart';
import '../animations/animation_chain.dart';
import '../animations/animation_combo_collapse.dart';
import '../animations/animation_combo_three.dart';
import '../animations/animation_swap_tiles.dart';
import '../bloc/bloc_provider.dart';
import '../bloc/game_bloc.dart';
import '../animations/model/animations_resolver.dart';
import '../compoents/crush_board.dart';
import '../model/array_2d.dart';
import '../model/audio.dart';
import '../model/combo.dart';
import '../model/level.dart';
import '../model/row_col.dart';
import '../model/tile.dart';
import '../panel/moves/game_moves_left_panel.dart';
import '../panel/objective/components/objective_panel.dart';
import '../splash/game_over_splash.dart';
import '../splash/game_reshuffling_splash.dart';
import '../splash/game_splash.dart';
import '../brand/brand_theme.dart';
import '../brand/progress.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.level});
  final Level level;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  OverlayEntry? _gameSplash;
  late GameBloc _gameBloc;
  bool _gestureEnabled = false;
  bool _background = false;
  bool _moveInProgress = false;
  bool get _allowGesture =>
      mounted &&
      _gestureEnabled &&
      !_background &&
      !_paused &&
      !_interrupted &&
      !_moveInProgress;
  set _allowGesture(bool value) => _gestureEnabled = value;
  final Set<OverlayEntry> _overlays = {};
  final Set<Completer<dynamic>> _pendingAnimations = {};
  final Set<Timer> _pendingDelays = {};

  Future<void> _delay(Duration duration) async {
    if (!mounted) return;
    final completer = _animationCompleter();
    late Timer timer;
    timer = Timer(duration, () {
      _pendingDelays.remove(timer);
      _finishAnimation(completer);
    });
    _pendingDelays.add(timer);
    await completer.future;
  }

  void _insertOverlay(OverlayEntry entry) {
    if (!mounted) {
      entry.dispose();
      return;
    }
    _overlays.add(entry);
    Overlay.of(context).insert(entry);
  }

  void _removeOverlay(OverlayEntry? entry) {
    if (entry == null || !_overlays.remove(entry)) return;
    entry.remove();
    entry.dispose();
  }

  Completer<dynamic> _animationCompleter() {
    final completer = Completer<dynamic>();
    _pendingAnimations.add(completer);
    return completer;
  }

  void _finishAnimation(Completer<dynamic> completer) {
    _pendingAnimations.remove(completer);
    if (!completer.isCompleted) completer.complete();
  }

  void _restoreInput() {
    if (!mounted) return;
    _allowGesture = !_gameBloc.isLevelOver;
    if (_interrupted &&
        !_background &&
        !_paused &&
        _gameSplash == null &&
        !_gameBloc.isLevelOver) {
      unawaited(_showPause());
    }
  }

  StreamSubscription? _gameOverSubscription;
  bool? _gameOverReceived;
  bool _paused = false;
  bool _initialized = false;
  bool _continuedThisAttempt = false;
  bool _continuing = false;
  bool _openingLevel = false;
  int _earnedGlow = 0;
  bool _interrupted = false;

  ///记录触发手势的糖果
  Tile? _gestureFromTile;

  ///记录触发手势的糖果位置，行和列
  RowCol? _gestureFromRowCol;

  ///记录手势的滑动距离
  Offset? _gestureOffsetStart;

  ///标记手势是否开始
  bool? _gestureStarted;
  static const double _minGestureDelta = 2.0;
  OverlayEntry? _overlayEntryFromTile;
  OverlayEntry? _overlayEntryAnimateSwapTiles;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gameOverReceived = false;
    WidgetsBinding.instance.addPostFrameCallback(_showGameStartSplash);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    // Now that the context is available, retrieve the gameBloc
    _gameBloc = BlocProvider.of<GameBloc>(context)!.bloc;
    // Reset the objectives
    _gameBloc.reset();
    // Listen to "game over" notification
    _gameOverSubscription = _gameBloc.gameIsOver.listen(_onGameOver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Audio.stop();
    _gameOverSubscription?.cancel();
    _gameOverSubscription = null;
    for (final timer in _pendingDelays) {
      timer.cancel();
    }
    _pendingDelays.clear();
    for (final entry in _overlays.toList()) {
      _removeOverlay(entry);
    }
    for (final completer in _pendingAnimations.toList()) {
      _finishAnimation(completer);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _background = state != AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed) {
      if (_interrupted &&
          mounted &&
          !_paused &&
          _gameSplash == null &&
          _gameOverReceived != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showPause();
        });
      }
    } else {
      _interrupted =
          _interrupted ||
          (!_paused && _gameSplash == null && _gameOverReceived != true);
      _removeOverlay(_overlayEntryFromTile);
      _overlayEntryFromTile = null;
      Audio.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValeBackdrop(
        child: Stack(
          children: [
            GestureDetector(
              onPanDown: (DragDownDetails details) => _onPanDown(details),
              onPanStart: _onPanStart,
              onPanEnd: _onPanEnd,
              onPanCancel: () => _onPanEnd(null),
              onPanUpdate: (DragUpdateDetails details) => _onPanUpdate(details),
              onTap: _onTap,
              onTapUp: _onPanEnd,
              child: Stack(children: [_buildBoard(), _buildTiles()]),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width:
                      MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? 280
                      : double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            IconButton.filledTonal(
                              tooltip: 'Pause game',
                              onPressed: _showPause,
                              icon: const Icon(Icons.pause_rounded),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Glade ${widget.level.index}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            StreamBuilder<int>(
                              stream: _gameBloc.scoreChanges,
                              initialData: _gameBloc.score,
                              builder: (context, snapshot) => Text(
                                '${snapshot.data ?? 0} pts',
                                style: const TextStyle(color: Brand.gold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMovesLeftPanel(),
                            const SizedBox(width: 8),
                            Expanded(child: _buildObjectivePanel()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovesLeftPanel() => const GameMovesLeftPanel();

  Widget _buildObjectivePanel() => const ObjectivePanel();

  Future<void> _showPause() async {
    if (!mounted ||
        _paused ||
        _gameOverReceived == true ||
        _gameSplash != null) {
      return;
    }
    _interrupted = false;
    _paused = true;
    _allowGesture = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Trail paused'),
        content: const Text(
          'Your current glade will reset if you return to the map.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Trail map'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Keep playing'),
          ),
        ],
      ),
    );
    _paused = false;
    if (mounted && _gameOverReceived != true && _gameSplash == null) {
      _allowGesture = true;
    }
  }

  // Builds the game board
  Widget _buildBoard() {
    final landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Padding(
      padding: EdgeInsets.only(right: landscape ? 12 : 0),
      child: Align(
        alignment: MediaQuery.of(context).orientation == Orientation.portrait
            ? const Alignment(0, 0.28)
            : Alignment.centerRight,
        child: CrushBoard(level: widget.level),
      ),
    );
  }

  // Builds the tiles
  Widget _buildTiles() {
    return StreamBuilder<bool>(
      stream: _gameBloc.outReadyToDisplayTiles,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.data != null && snapshot.hasData) {
          List<Widget> tiles = <Widget>[];
          Array2d<Tile> grid = _gameBloc.gameController.grid;

          for (int row = 0; row < widget.level.numberOfRows; row++) {
            for (int col = 0; col < widget.level.numberOfCols; col++) {
              final Tile tile = grid[row][col];
              if (tile.type != TileType.empty &&
                  tile.type != TileType.forbidden &&
                  tile.visible) {
                // Make sure the widget is correctly positioned
                tile.setPosition();
                tiles.add(
                  Positioned(left: tile.x, top: tile.y, child: tile.widget),
                );
              }
            }
          }

          return Stack(children: tiles);
        }
        // If nothing is ready, simply return an empty container
        return Container();
      },
    );
  }

  //
  // Gesture
  //

  RowCol _rowColFromGlobalPosition(Offset globalPosition) {
    final double top = globalPosition.dy - widget.level.boardTop;
    final double left = globalPosition.dx - widget.level.boardLeft;
    return RowCol(
      col: (left / widget.level.tileWidth).floor(),
      row:
          widget.level.numberOfRows -
          (top / widget.level.tileHeight).floor() -
          1,
    );
  }

  //
  // The pointer touches the screen
  //
  void _onPanDown(DragDownDetails details) {
    if (!_allowGesture) return;
    _removeOverlay(_overlayEntryFromTile);
    _overlayEntryFromTile = null;
    _gestureFromTile = null;
    _gestureStarted = false;
    _gestureOffsetStart = null;
    _gestureFromRowCol = null;

    // Determine the [row,col] from touch position
    RowCol rowCol = _rowColFromGlobalPosition(details.globalPosition);

    // Ignore if we touched outside the grid
    if (rowCol.row < 0 ||
        rowCol.row >= widget.level.numberOfRows ||
        rowCol.col < 0 ||
        rowCol.col >= widget.level.numberOfCols) {
      return;
    }

    // Check if the [row,col] corresponds to a possible swap
    Tile? selectedTile = _gameBloc.gameController.grid[rowCol.row][rowCol.col];
    bool canBePlayed = false;

    // Reset
    _gestureFromTile = null;
    _gestureStarted = false;
    _gestureOffsetStart = null;
    _gestureFromRowCol = null;

    if (selectedTile != null) {
      //TODO: Condition no longer necessary
      canBePlayed = selectedTile.canMove;
    }

    if (canBePlayed) {
      Audio.playAsset(AudioType.select);
      _gestureFromTile = selectedTile;
      _gestureFromRowCol = rowCol;

      //
      // Let's position the tile on the Overlay and inflate it a bit to make it more visible
      //
      _overlayEntryFromTile = OverlayEntry(
        opaque: false,
        builder: (BuildContext context) {
          return Positioned(
            left: _gestureFromTile!.x,
            top: _gestureFromTile!.y,
            child: Transform.scale(scale: 1.1, child: _gestureFromTile!.widget),
          );
        },
      );
      _insertOverlay(_overlayEntryFromTile!);
    }
  }

  //
  // The pointer starts to move
  //
  void _onPanStart(DragStartDetails details) {
    if (!_allowGesture) return;
    if (_gestureFromTile != null) {
      _gestureStarted = true;
      _gestureOffsetStart = details.globalPosition;
    }
  }

  //
  // The user releases the pointer from the screen
  //
  void _onPanEnd(_) {
    _gestureStarted = false;
    _gestureOffsetStart = null;
    _removeOverlay(_overlayEntryFromTile);
    _overlayEntryFromTile = null;
  }

  //
  // The pointer has been moved since its last "start"
  //
  void _onPanUpdate(DragUpdateDetails details) {
    if (!_allowGesture) return;
    if (_gestureStarted == true) {
      // Try to determine the move type (up, down, left, right)
      Offset delta = details.globalPosition - _gestureOffsetStart!;
      int deltaRow = 0;
      int deltaCol = 0;
      bool test = false;
      if (delta.dx.abs() > delta.dy.abs() &&
          delta.dx.abs() > _minGestureDelta) {
        // horizontal move
        deltaCol = delta.dx.floor().sign;
        test = true;
      } else if (delta.dy.abs() > _minGestureDelta) {
        // vertical move
        deltaRow = -delta.dy.floor().sign;
        test = true;
      }

      if (test == true) {
        RowCol rowCol = RowCol(
          row: _gestureFromRowCol!.row + deltaRow,
          col: _gestureFromRowCol!.col + deltaCol,
        );
        if (rowCol.col < 0 ||
            rowCol.col == widget.level.numberOfCols ||
            rowCol.row < 0 ||
            rowCol.row == widget.level.numberOfRows) {
          // Not possible, outside the boundaries
        } else {
          Tile? destTile =
              _gameBloc.gameController.grid[rowCol.row][rowCol.col];
          bool canBePlayed = false;

          if (destTile != null) {
            //TODO:  Condition no longer necessary
            canBePlayed = destTile.canMove || destTile.type == TileType.empty;
          }

          if (canBePlayed) {
            // We need to test the swap
            bool swapAllowed = _gameBloc.gameController.swapContains(
              _gestureFromTile!,
              destTile!,
            );
            if (!swapAllowed) Audio.playAsset(AudioType.invalid);
            if (swapAllowed && GameProgress.instance.hapticsEnabled) {
              unawaited(HapticFeedback.selectionClick());
            }

            // Do not allow the gesture recognition during the animation
            _allowGesture = false;
            _moveInProgress = true;

            // 1. Remove the expanded tile
            _removeOverlay(_overlayEntryFromTile);
            _overlayEntryFromTile = null;

            // 2. Generate the up/down tiles
            Tile upTile = _gestureFromTile!.cloneForAnimation();
            Tile downTile = destTile.cloneForAnimation();

            // 3. Remove both tiles from the game grid
            _gameBloc.gameController.grid[rowCol.row][rowCol.col].visible =
                false;
            _gameBloc
                    .gameController
                    .grid[_gestureFromRowCol!.row][_gestureFromRowCol!.col]
                    .visible =
                false;

            setState(() {});
            // 4. Animate both tiles
            _overlayEntryAnimateSwapTiles = OverlayEntry(
              opaque: false,
              builder: (BuildContext context) {
                return AnimationSwapTiles(
                  upTile: upTile,
                  downTile: downTile,
                  swapAllowed: swapAllowed,
                  onComplete: () async {
                    if (!mounted) return;
                    // 5. Put back the tiles in the game grid
                    _gameBloc
                            .gameController
                            .grid[rowCol.row][rowCol.col]
                            .visible =
                        true;
                    _gameBloc
                            .gameController
                            .grid[_gestureFromRowCol!.row][_gestureFromRowCol!
                                .col]
                            .visible =
                        true;

                    // 6. Remove the overlay Entry
                    _removeOverlay(_overlayEntryAnimateSwapTiles);
                    _overlayEntryAnimateSwapTiles = null;

                    if (swapAllowed == true) {
                      // Remember if the tile we move is a bomb
                      bool isSourceTileABomb = Tile.isBomb(
                        _gestureFromTile!.type!,
                      );

                      // Swap the 2 tiles，交换目标糖果和原糖果的位置和坐标信息
                      _gameBloc.gameController.swapTiles(
                        _gestureFromTile!,
                        destTile,
                      );

                      // Get the tiles that need to be removed, following the swap
                      // We need to get the tiles from all possible combos
                      Combo comboOne = _gameBloc.gameController.getCombo(
                        _gestureFromTile!.row,
                        _gestureFromTile!.col,
                      );
                      Combo comboTwo = _gameBloc.gameController.getCombo(
                        destTile.row,
                        destTile.col,
                      );

                      /// Wait for both animations to complete
                      await Future.wait([
                        _animateCombo(comboOne),
                        _animateCombo(comboTwo),
                      ]);
                      if (!mounted) return;

                      // Resolve the combos
                      _gameBloc.gameController.resolveCombo(
                        comboOne,
                        _gameBloc,
                      );
                      _gameBloc.gameController.resolveCombo(
                        comboTwo,
                        _gameBloc,
                      );

                      // If the tile we moved is a bomb, we need to process the explosion
                      if (isSourceTileABomb) {
                        _gameBloc.gameController.proceedWithExplosion(
                          Tile(
                            row: _gestureFromTile!.row,
                            col: _gestureFromTile!.col,
                            type: _gestureFromTile!.type,
                          ),
                          _gameBloc,
                        );
                      }

                      /// Proceed with the falling tiles
                      await _playAllAnimations();
                      if (!mounted) return;

                      /// Once this is all done, we need to recalculate all the possible swaps
                      _gameBloc.gameController.identifySwaps();

                      // Record the fact that we have played a move
                      _gameBloc.playMove();

                      if (!_gameBloc.isLevelOver &&
                          !_gameBloc.gameController.stillMovesToPlay()) {
                        // No moves left
                        await _showReshufflingSplash();
                        if (!mounted) return;
                        _gameBloc.gameController.reshuffling();
                        setState(() {});
                      }
                      // Make sure there is a correct delay before refreshing the screen
                      await _delay(const Duration(milliseconds: 300));
                      if (!mounted) return;
                    }

                    // 7. Reset
                    _moveInProgress = false;
                    _restoreInput();
                    _onPanEnd(null);
                    if (mounted) {
                      setState(() {});
                    }
                  },
                );
              },
            );
            _insertOverlay(_overlayEntryAnimateSwapTiles!);
          }
        }
      }
    }
  }

  /// The user tap on a tile, is this a bomb ?
  /// If yes make it explode
  void _onTap() {
    if (!_allowGesture) return;
    if (_gestureFromTile != null && Tile.isBomb(_gestureFromTile!.type!)) {
      // Prevent the user from playing during the animation
      _allowGesture = false;
      _moveInProgress = true;
      // Play explosion
      Audio.playAsset(AudioType.bomb);
      if (GameProgress.instance.hapticsEnabled) {
        unawaited(HapticFeedback.lightImpact());
      }

      // Proceed with explosion
      _gameBloc.gameController.proceedWithExplosion(
        _gestureFromTile!,
        _gameBloc,
      );

      // Rebuild the board and proceed with animations
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        // Proceed with the falling tiles
        await _playAllAnimations();
        if (!mounted) return;

        // Once this is all done, we need to recalculate all the possible swaps
        _gameBloc.gameController.identifySwaps();

        // The user may now play
        // Record the fact that we have played a move
        _gameBloc.playMove();

        // Check if there are still moves to play
        if (!_gameBloc.isLevelOver &&
            !_gameBloc.gameController.stillMovesToPlay()) {
          // No moves left
          await _showReshufflingSplash();
          if (!mounted) return;
          _gameBloc.gameController.reshuffling();
          setState(() {});
        }
        _moveInProgress = false;
        _restoreInput();
      });
    }
  }

  /// Show/hide the tiles related to a Combo.
  /// This is used just before starting an animation
  void _showComboTilesForAnimation(Combo combo, bool visible) {
    for (final tile in combo.tiles) {
      tile.visible = visible;
    }
    setState(() {});
  }

  /// Launch an Animation which returns a Future when completed
  Future<dynamic> _animateCombo(Combo combo) async {
    if (!mounted) return;
    final completer = _animationCompleter();
    OverlayEntry? overlayEntry;

    switch (combo.type) {
      case ComboType.three:
        // Hide the tiles before starting the animation
        _showComboTilesForAnimation(combo, false);

        // Launch the animation for a chain of 3 tiles
        overlayEntry = OverlayEntry(
          opaque: false,
          builder: (BuildContext context) {
            return AnimationComboThree(
              combo: combo,
              onComplete: () {
                _removeOverlay(overlayEntry);
                overlayEntry = null;
                _finishAnimation(completer);
              },
            );
          },
        );

        // Play sound
        unawaited(Audio.playAsset(AudioType.move_down));
        if (mounted) {
          _insertOverlay(overlayEntry!);
        } else {
          overlayEntry!.dispose();
          _finishAnimation(completer);
        }
        break;

      case ComboType.none:
      case ComboType.one:
      case ComboType.two:
        // These type of combos are not possible, therefore directly return
        _finishAnimation(completer);
        break;

      default:
        // Hide the tiles before starting the animation
        _showComboTilesForAnimation(combo, false);

        // We need to create the resulting tile
        Tile? resultingTile = Tile(
          col: combo.commonTile!.col,
          row: combo.commonTile!.row,
          type: combo.resultingTileType,
          level: widget.level,
          depth: 0,
        );
        resultingTile.build();

        // Launch the animation for a chain more than 3 tiles
        overlayEntry = OverlayEntry(
          opaque: false,
          builder: (BuildContext context) {
            return AnimationComboCollapse(
              combo: combo,
              resultingTile: resultingTile!,
              onComplete: () {
                resultingTile = null;
                _removeOverlay(overlayEntry);
                overlayEntry = null;

                _finishAnimation(completer);
              },
            );
          },
        );

        // Play sound
        unawaited(Audio.playAsset(AudioType.swap));
        if (mounted) {
          _insertOverlay(overlayEntry!);
        } else {
          overlayEntry!.dispose();
          _finishAnimation(completer);
        }
        break;
    }
    return completer.future;
  }

  //
  // Routine that launches all animations, resulting from a combo
  //
  Future<dynamic> _playAllAnimations() async {
    if (!mounted) return;

    /// Determine all animations (and sequence of animations) that
    /// need to be played as a consequence of a combo
    final animationResolver = AnimationsResolver(
      gameBloc: _gameBloc,
      level: widget.level,
    );
    animationResolver.resolve();

    /// Determine the list of cells that are involved in the animation(s)
    /// and make them invisible
    if (animationResolver.involvedCells.isEmpty) {
      return null;
    }

    // Obtain the animation sequences
    final sequences = animationResolver.getAnimationsSequences();
    if (sequences.isEmpty) return;
    final completer = _animationCompleter();
    int pendingSequences = sequences.length;

    /// Make all involved cells invisible
    for (final rowCol in animationResolver.involvedCells) {
      _gameBloc.gameController.grid[rowCol.row][rowCol.col].visible = false;
    }

    /// Make a refresh of the board and the end of which we will play the animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      /// As the board is now refreshed, it is time to start playing
      /// all the animations
      final overlayEntries = <OverlayEntry>[];
      for (final animationSequence in sequences) {
        /// Prepare all the animations at once.
        /// This is important to avoid having multiple rebuild
        /// when we are going to put them all on the Overlay
        overlayEntries.add(
          OverlayEntry(
            opaque: false,
            builder: (BuildContext context) {
              return AnimationChain(
                level: widget.level,
                animationSequence: animationSequence,
                onComplete: () {
                  if (!mounted) return;
                  // Decrement the number of pending animations
                  pendingSequences--;

                  //
                  // When all have finished, we need to "rebuild" the board,
                  // refresh the screen and yied the hand back
                  //
                  if (pendingSequences == 0) {
                    // Remove all OverlayEntries
                    for (final entry in overlayEntries) {
                      _removeOverlay(entry);
                    }
                    _gameBloc.gameController.refreshGridAfterAnimations(
                      animationResolver.resultingGridInTermsOfTileTypes,
                      animationResolver.involvedCells,
                    );

                    // We now need to proceed with a final rebuild and yield the hand
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Finally, yield the hand
                      if (!completer.isCompleted) {
                        _finishAnimation(completer);
                      }
                    });
                    setState(() {});
                  }
                },
              );
            },
          ),
        );
      }
      for (final entry in overlayEntries) {
        _insertOverlay(entry);
      }
    });

    setState(() {});
    return completer.future;
  }

  //
  // The game is over
  //
  // We need to show the adequate splash (win/lost)
  //
  void _onGameOver(bool success) async {
    // Prevent from bubbling
    if (_gameOverReceived == true) {
      return;
    }
    _gameOverReceived = true;
    _allowGesture = false;
    if (GameProgress.instance.hapticsEnabled && success) {
      unawaited(HapticFeedback.mediumImpact());
    }
    if (success) {
      _earnedGlow = await GameProgress.instance.complete(
        widget.level.index,
        _gameBloc.numberOfLevels,
        score: _gameBloc.score,
        movesLeft: widget.level.movesLeft,
      );
    }
    unawaited(Audio.playAsset(success ? AudioType.win : AudioType.lost));

    // Since some animations could still be ongoing, let's wait a bit
    // before showing the user that the game is won
    await _delay(const Duration(seconds: 1));
    if (!mounted) return;

    // No gesture detection during the splash
    _allowGesture = false;

    // Show the splash
    _gameSplash = OverlayEntry(
      opaque: false,
      builder: (BuildContext context) {
        return GameOverSplash(
          success: success,
          level: widget.level,
          score: _gameBloc.score,
          glowEarned: _earnedGlow,
          onExit: () {
            _removeOverlay(_gameSplash);
            _gameSplash = null;
            Navigator.of(context).pop();
          },
          onRetry: () => _openResultLevel(widget.level.index),
          onNext: widget.level.index < _gameBloc.numberOfLevels
              ? () => _openResultLevel(widget.level.index + 1)
              : null,
          onContinue: !success && !_continuedThisAttempt
              ? _continueWithAd
              : null,
        );
      },
    );

    _insertOverlay(_gameSplash!);
  }

  Future<void> _continueWithAd() async {
    if (_continuing || _continuedThisAttempt) return;
    _continuing = true;
    final earned = await AdsService.instance.showRewarded();
    _continuing = false;
    if (!mounted || !earned) return;
    _continuedThisAttempt = true;
    _gameBloc.addMoves(3);
    _removeOverlay(_gameSplash);
    _gameSplash = null;
    _gameOverReceived = false;
    _interrupted = false;
    _allowGesture = true;
    setState(() {});
  }

  Future<void> _openResultLevel(int number) async {
    if (_openingLevel || !mounted) return;
    _openingLevel = true;
    _removeOverlay(_gameSplash);
    _gameSplash = null;
    final next = await _gameBloc.setLevel(number);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => GamePage(level: next)),
    );
  }

  //
  // SplashScreen to be displayed when the game starts
  // to show the user the objectives
  //
  void _showGameStartSplash(_) {
    if (!mounted) return;
    // No gesture detection during the splash
    _allowGesture = false;

    // Show the splash
    _gameSplash = OverlayEntry(
      opaque: false,
      builder: (BuildContext context) {
        return GameSplash(
          level: widget.level,
          onComplete: () {
            _removeOverlay(_gameSplash);
            _gameSplash = null;

            // allow gesture detection
            _restoreInput();
          },
        );
      },
    );

    _insertOverlay(_gameSplash!);
  }

  //
  // SplashScreen to indicate that there is no more moves
  // and a reshuffling is going to happen
  //
  Future<void> _showReshufflingSplash() async {
    if (!mounted) return;
    final completer = _animationCompleter();

    // No gesture detection during the splash
    _allowGesture = false;

    // Show the splash
    _gameSplash = OverlayEntry(
      opaque: false,
      builder: (BuildContext context) {
        return GameReshufflingSplash(
          onComplete: () {
            _removeOverlay(_gameSplash);
            _gameSplash = null;

            // allow gesture detection
            _restoreInput();

            // gives the hand back
            _finishAnimation(completer);
          },
        );
      },
    );

    _insertOverlay(_gameSplash!);

    return completer.future;
  }
}
