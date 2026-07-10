/// Centralized route path constants so screens never hardcode path strings.
///
/// Only coarse, role-level routes live here. Finer-grained state within a
/// role (e.g. a startup owner's create-profile vs pending-approval vs
/// verified views) is handled by that route's own widget switching on its
/// feature Bloc's state, not by additional go_router routes.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const roleSelection = '/role-selection';

  static const studentHome = '/student';
  static const startupHome = '/startup';
  static const adminHome = '/admin';
}
