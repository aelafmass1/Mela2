import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/equb_creation_sceen.dart';
import 'package:transaction_mobile_app/presentation/screens/login_screen/login_screen.dart';
import 'package:transaction_mobile_app/presentation/screens/signup_screen/signup_screen.dart';
import 'package:transaction_mobile_app/presentation/screens/splash_screen/splash_screen.dart';

import '../presentation/screens/home_screen/home_screen.dart';

class RouteName {
  static const splash = 'splash_screen';
  static const home = 'home_screen';
  static const login = 'login_screen';
  static const signup = 'signup_screen';
  static const equbCreation = 'equb_creation_screen';
}

final goRouting = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: RouteName.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
        path: '/home',
        name: RouteName.home,
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'equb_creation',
            name: RouteName.equbCreation,
            builder: (context, state) => const EqubCreationScreen(),
          )
        ]),
    GoRoute(
      path: '/login',
      name: RouteName.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: RouteName.signup,
      builder: (context, state) => const SignupScreen(),
    ),
  ],
);
