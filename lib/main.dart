import 'dart:async';

import 'package:prismleaf_vale/pages/home_page.dart';
import 'package:flutter/material.dart';

import 'ads/ads_service.dart';
import 'bloc/bloc_provider.dart';
import 'bloc/game_bloc.dart';
import 'brand/brand_theme.dart';
import 'brand/progress.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StartupApp());
}

/// Keep storage failures recoverable instead of leaving the native splash visible.
class StartupApp extends StatefulWidget {
  const StartupApp({super.key, this.loadProgress, this.initializeAds});
  final Future<void> Function()? loadProgress;
  final Future<void> Function()? initializeAds;

  @override
  State<StartupApp> createState() => _StartupAppState();
}

class _StartupAppState extends State<StartupApp> {
  late Future<void> _loading;

  @override
  void initState() {
    super.initState();
    _loading = _load();
  }

  Future<void> _load() async {
    await (widget.loadProgress ?? GameProgress.instance.load)();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited((widget.initializeAds ?? AdsService.instance.initialize)());
      }
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _loading,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          !snapshot.hasError) {
        return const MyApp();
      }
      return MaterialApp(
        theme: Brand.theme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: snapshot.hasError
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Your saved progress could not be opened. Please try again.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => setState(() {
                            _loading = _load();
                          }),
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      );
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GameBloc _gameBloc = GameBloc();

  @override
  void dispose() {
    _gameBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameBloc>(
      bloc: _gameBloc,
      child: MaterialApp(
        title: Brand.name,
        debugShowCheckedModeBanner: false,
        theme: Brand.theme,
        home: const HomePage(),
      ),
    );
  }
}
