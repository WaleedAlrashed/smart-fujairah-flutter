import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../screens/home_screen.dart';
import '../../screens/category_services_screen.dart';
import '../../screens/service_detail_screen.dart';
import '../../screens/service_request_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/search_screen.dart';
import '../../screens/shell_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'category/:id',
                    builder: (context, state) => CategoryServicesScreen(
                      categoryId: int.parse(state.pathParameters['id']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'service/:serviceId',
                        builder: (context, state) => ServiceDetailScreen(
                          serviceId: int.parse(state.pathParameters['serviceId']!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Full-screen routes (outside shell)
      GoRoute(
        path: '/request/:serviceId',
        builder: (context, state) => ServiceRequestScreen(
          serviceId: int.parse(state.pathParameters['serviceId']!),
        ),
      ),
    ],
  );
});
