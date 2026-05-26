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
      NotificationService.instance.initialize().then((_) {
        _syncNotifications();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _appState,
      child: MaterialApp.router(
        title: 'Thyroid Tracker',
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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!state.hasCompletedOnboarding) {
            return const OnboardingScreen();
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
    NotificationService.instance.syncMedicationReminders(
      plans: _appState.medicationPlans,
      enabled: _appState.medicationNotificationsEnabled,
    );
  }
}
