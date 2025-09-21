import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../views/splash/splash_view.dart';
import '../../views/auth/login_view.dart';
import '../../views/auth/register_view.dart';
import '../../views/home/home_view.dart';
import '../../views/home/widgets/plan_trip_section.dart';
import '../../views/profile/edit_profile_view.dart';
import '../../views/settings/settings_view.dart';
import '../../views/trips/my_trips_view.dart';
import '../../views/places/places_list_view.dart';
import '../../views/places/place_detail_view.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/plan-trip',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Plan Your Trip'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
          ),
          body: const PlanTripSection(),
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileView(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: '/my-trips',
        builder: (context, state) => const MyTripsView(),
      ),
      GoRoute(
        path: '/places',
        builder: (context, state) => const PlacesListView(),
      ),
      GoRoute(
        path: '/places/:id',
        builder: (context, state) {
          final placeId = state.pathParameters['id']!;
          return PlaceDetailView(placeId: placeId);
        },
      ),
    ],
  );
}
