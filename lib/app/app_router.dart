import 'package:go_router/go_router.dart';
import 'package:medication_reminder/features/medication/screens/home_screen.dart';
import 'package:medication_reminder/features/medication/screens/add_med_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/add-med',
      builder: (context, state) => const AddMedScreen(),
    ),
  ],
);
