import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/di/injection_container.dart' as di;
import 'core/auth/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/viewmodels/auth_view_model.dart';
import 'presentation/viewmodels/badge_view_model.dart';
import 'presentation/viewmodels/places_view_model.dart';
import 'presentation/viewmodels/post_view_model.dart';
import 'presentation/viewmodels/story_view_model.dart';
import 'presentation/viewmodels/trip_view_model.dart';
import 'presentation/viewmodels/chat_view_model.dart';

import 'providers/community_provider.dart';
import 'providers/trip_local_provider.dart';
import 'providers/voucher_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must complete before runApp so TokenStorage.instance.isAuthenticated is usable in SplashScreen
  await TokenStorage.instance.initialize();
  await di.init();
  runApp(const KemoraApp());
}

class KemoraApp extends StatelessWidget {
  const KemoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => di.sl<AuthViewModel>()),
        ChangeNotifierProvider(create: (context) => di.sl<PlacesViewModel>()),
        ChangeNotifierProvider(create: (context) => di.sl<TripViewModel>()),
        ChangeNotifierProvider(create: (context) => di.sl<PostViewModel>()),
        ChangeNotifierProvider(create: (context) => di.sl<StoryViewModel>()),
        ChangeNotifierProvider(create: (context) => di.sl<BadgeViewModel>()),
        ChangeNotifierProvider(create: (context) => di.sl<ChatViewModel>()),

        ChangeNotifierProvider(create: (context) => CommunityProvider()),
        ChangeNotifierProvider(create: (context) => TripLocalProvider()),
        ChangeNotifierProvider(create: (context) => VoucherProvider()),
      ],
      child: MaterialApp(
        title: 'Kemora Travel Guide',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        // SplashScreen is always the first widget.
        // It reads TokenStorage (already initialized) and routes to:
        //   • HomeScreen  — if a valid token exists (returning authenticated user)
        //   • OnboardingScreen — if no token AND first launch
        //   • LoginScreen — if no token AND onboarding already completed
        home: const SplashScreen(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
      ),
    );
  }
}
