import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/doctor/presentation/doctor_screen.dart';
import '../features/knowledge/presentation/knowledge_screen.dart';
import '../features/labs/presentation/labs_screen.dart';
import '../features/media/presentation/media_screen.dart';
import '../features/medication/presentation/medication_screen.dart';
import '../features/more/presentation/more_screen.dart';
import '../features/overview/presentation/overview_screen.dart';
import '../features/report/presentation/doctor_report_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/sleep/presentation/sleep_screen.dart';
import '../features/weight/presentation/weight_screen.dart';
import '../shared/presentation/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: AppRoute.overview.path,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        _branch(AppRoute.overview, const OverviewScreen()),
        _branch(AppRoute.labs, const LabsScreen()),
        _branch(AppRoute.medication, const MedicationScreen()),
        _branch(AppRoute.more, const MoreScreen()),
      ],
    ),
    GoRoute(
      path: AppRoute.doctor.path,
      name: AppRoute.doctor.name,
      pageBuilder: (context, state) {
        return const NoTransitionPage(child: DoctorScreen());
      },
    ),
    GoRoute(
      path: AppRoute.media.path,
      name: AppRoute.media.name,
      pageBuilder: (context, state) {
        return const NoTransitionPage(child: MediaScreen());
      },
    ),
    GoRoute(
      path: AppRoute.knowledge.path,
      name: AppRoute.knowledge.name,
      pageBuilder: (context, state) {
        return const NoTransitionPage(child: KnowledgeScreen());
      },
    ),
    GoRoute(
      path: AppRoute.settings.path,
      name: AppRoute.settings.name,
      pageBuilder: (context, state) {
        return const NoTransitionPage(child: SettingsScreen());
      },
    ),
    GoRoute(
      path: AppRoute.sleep.path,
      name: AppRoute.sleep.name,
      pageBuilder: (context, state) {
        return const NoTransitionPage(child: SleepScreen());
      },
    ),
    GoRoute(
      path: AppRoute.weight.path,
      name: AppRoute.weight.name,
      pageBuilder: (context, state) {
        return const NoTransitionPage(child: WeightScreen());
      },
    ),
    GoRoute(
      path: AppRoute.report.path,
      name: AppRoute.report.name,
      pageBuilder: (context, state) {
        return const NoTransitionPage(child: DoctorReportScreen());
      },
    ),
  ],
);

StatefulShellBranch _branch(AppRoute route, Widget screen) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: route.path,
        name: route.name,
        pageBuilder: (context, state) => NoTransitionPage(child: screen),
      ),
    ],
  );
}

enum AppRoute {
  overview('/'),
  labs('/labs'),
  medication('/medication'),
  more('/more'),
  doctor('/doctor'),
  media('/media'),
  knowledge('/knowledge'),
  settings('/settings'),
  sleep('/sleep'),
  weight('/weight'),
  report('/report');

  const AppRoute(this.path);

  final String path;
}
