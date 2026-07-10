import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/models/user_role.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/role_selection_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/home/admin_home_screen.dart';
import '../../screens/home/student_home_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/startup_profile/startup_gate.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';

GoRouter buildAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) => _redirect(authBloc, state),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.signup, builder: (context, state) => const SignupScreen()),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentHome,
        builder: (context, state) => const StudentHomeScreen(),
      ),
      GoRoute(path: AppRoutes.startupHome, builder: (context, state) => const StartupGate()),
      GoRoute(path: AppRoutes.adminHome, builder: (context, state) => const AdminHomeScreen()),
    ],
  );
}

/// Coarse, role-level redirect only. Finer-grained state within a role
/// (e.g. a startup owner's create-profile vs pending vs verified views)
/// is handled inside that route's own widget (see StartupGate), not here.
String? _redirect(AuthBloc authBloc, GoRouterState state) {
  final authState = authBloc.state;
  final loc = state.matchedLocation;
  final onAuthPages = loc == AppRoutes.login || loc == AppRoutes.signup;

  if (authState is AuthInitial || authState is AuthLoading) {
    // Don't yank the user off the login/signup form while a login/sign-up
    // attempt is resolving (authStateChanges fires -> brief AuthLoading
    // -> AuthAuthenticated); only force the splash screen at cold start.
    return (loc == AppRoutes.splash || onAuthPages) ? null : AppRoutes.splash;
  }

  if (authState is AuthUnauthenticated || authState is AuthFailure) {
    return onAuthPages ? null : AppRoutes.login;
  }

  if (authState is AuthNeedsRoleSelection) {
    return loc == AppRoutes.roleSelection ? null : AppRoutes.roleSelection;
  }

  if (authState is AuthAuthenticated) {
    final onEntryPoint = loc == AppRoutes.splash || onAuthPages;
    if (!onEntryPoint) return null;
    switch (authState.user.role) {
      case UserRole.student:
        return AppRoutes.studentHome;
      case UserRole.startup:
        return AppRoutes.startupHome;
      case UserRole.admin:
        return AppRoutes.adminHome;
    }
  }

  return null;
}
