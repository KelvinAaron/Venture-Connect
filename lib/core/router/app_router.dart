import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import 'app_routes.dart';

/// Route table. Step 2 will extend this with auth/signup routes and a
/// `redirect` callback driven by AuthBloc (unauthenticated -> login,
/// authenticated -> role-appropriate home).
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
  ],
);
