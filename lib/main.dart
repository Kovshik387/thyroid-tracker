import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/app/app_router.dart';
import 'src/app/app_scope.dart';
import 'src/app/app_state.dart';
import 'src/app/app_theme.dart';
import 'src/core/notifications/notification_service.dart';
import 'src/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ThyroidTrackerApp());
}

class ThyroidTrackerApp extends StatefulWidget {
  const ThyroidTrackerApp({
    this.appState,
    super.key,
  });

  final AppState? appState;

  @override
  State<ThyroidTrackerApp> createState() => _ThyroidTrackerAppState();
}

class _ThyroidTrackerAppState extends State<ThyroidTrackerApp> {
  late final AppState _appState = widget.appState ?? AppState();
  late final bool _ownsState = widget.appState == null;

  @override
  void initState() {
    super.initState();
    if (_ownsState) {
      _appState.addListener(_syncNotifications);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _appState,
      child: MaterialApp.router(
        title: 'ТироДневник',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: appRouter,
        locale: const Locale('ru'),
        supportedLocales: const [
          Locale('ru'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          final state = AppScope.watch(context);
          if (!state.isLoaded) {
            return _StartupLoadingScreen(
              appState: state,
            );
          }
          if (state.loadError != null) {
            return _StandaloneNavigator(
              child: _StartupErrorScreen(
                error: state.loadError!,
                onReset: () => state.resetToDefaults(),
              ),
            );
          }
          if (!state.hasCompletedOnboarding) {
            return const _StandaloneNavigator(
              child: OnboardingScreen(),
            );
          }
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  void dispose() {
    if (_ownsState) {
      _appState.removeListener(_syncNotifications);
      _appState.dispose();
    }
    super.dispose();
  }

  void _syncNotifications() {
    if (!_appState.isLoaded) {
      return;
    }
    unawaited(
      NotificationService.instance
          .syncMedicationReminders(
        plans: _appState.medicationPlans,
        enabled: _appState.medicationNotificationsEnabled,
      )
          .catchError((Object error, StackTrace stackTrace) {
        debugPrint('Notification sync failed: $error');
      }),
    );
  }
}

class _StartupLoadingScreen extends StatefulWidget {
  const _StartupLoadingScreen({required this.appState});

  final AppState appState;

  @override
  State<_StartupLoadingScreen> createState() => _StartupLoadingScreenState();
}

class _StartupLoadingScreenState extends State<_StartupLoadingScreen> {
  var _isTakingTooLong = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 10), () {
      if (mounted && !widget.appState.isLoaded) {
        setState(() => _isTakingTooLong = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTakingTooLong) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.hourglass_disabled_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Загрузка заняла слишком много времени',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  'Скорее всего, приложение зависло на открытии локальной базы. '
                  'Откройте лог Flutter и найдите строку "AppState load failed".',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: widget.appState.resetToDefaults,
                  child: const Text('Сбросить локальные данные'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({
    required this.error,
    required this.onReset,
  });

  final Object error;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Не удалось запустить ТироДневник',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onReset,
                  child: const Text('Сбросить локальные данные'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StandaloneNavigator extends StatelessWidget {
  const _StandaloneNavigator({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage<void>(
          child: child,
        ),
      ],
      onDidRemovePage: (_) {},
    );
  }
}
