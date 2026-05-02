import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/map/map_screen.dart';
import '../presentation/screens/feed/feed_screen.dart';
import '../presentation/screens/analytics/analytics_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/',    builder: (c, s) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/map', builder: (c, s) => const MapScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/feed', builder: (c, s) => const FeedScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/analytics', builder: (c, s) => const AnalyticsScreen()),
        ]),
      ],
    ),
  ],
);

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),     selectedIcon: Icon(Icons.home),           label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_outlined),      selectedIcon: Icon(Icons.map),            label: 'Map'),
          NavigationDestination(icon: Icon(Icons.feed_outlined),     selectedIcon: Icon(Icons.feed),           label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart),     label: 'Analytics'),
        ],
      ),
    );
  }
}