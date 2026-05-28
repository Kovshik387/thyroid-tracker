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
import '../shared/presentation/animated_branch_container.dart';
import '../shared/presentation/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: AppRoute.overview.path,
  routes: [
    StatefulShellRoute(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      navigatorContainerBuilder: (context, navigationShell, children) {
        return AnimatedBranchContainer(
          currentIndex: navigationShell.currentIndex,
          children: children,
        );
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
        return _cupertinoBackPage(state, const DoctorScreen());
      },
    ),
    GoRoute(
      path: AppRoute.media.path,
      name: AppRoute.media.name,
      pageBuilder: (context, state) {
        return _cupertinoBackPage(state, const MediaScreen());
      },
    ),
    GoRoute(
      path: AppRoute.knowledge.path,
      name: AppRoute.knowledge.name,
      pageBuilder: (context, state) {
        return _cupertinoBackPage(state, const KnowledgeScreen());
      },
    ),
    GoRoute(
      path: AppRoute.settings.path,
      name: AppRoute.settings.name,
      pageBuilder: (context, state) {
        return _cupertinoBackPage(state, const SettingsScreen());
      },
    ),
    GoRoute(
      path: AppRoute.sleep.path,
      name: AppRoute.sleep.name,
      pageBuilder: (context, state) {
        return _cupertinoBackPage(state, const SleepScreen());
      },
    ),
    GoRoute(
      path: AppRoute.weight.path,
      name: AppRoute.weight.name,
      pageBuilder: (context, state) {
        return _cupertinoBackPage(state, const WeightScreen());
      },
    ),
    GoRoute(
      path: AppRoute.report.path,
      name: AppRoute.report.name,
      pageBuilder: (context, state) {
        return _cupertinoBackPage(state, const DoctorReportScreen());
      },
    ),
  ],
);

Page<void> _cupertinoBackPage(GoRouterState state, Widget child) {
  return MaterialPage(
    key: state.pageKey,
    name: state.name,
    child: child,
  );
}

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
