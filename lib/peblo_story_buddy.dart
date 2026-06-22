import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/story_provider.dart';
import 'screens/home_screen.dart';
import 'utils/app_constants.dart';

class PebloApp extends StatelessWidget {
  const PebloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Create StoryProvider once at root; auto-disposed when app closes
      create: (_) => StoryProvider(),
      child: MaterialApp(
        title: 'Peblo Story Buddy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            background: AppColors.background,
          ),
          useMaterial3: true,
          fontFamily: 'Nunito',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
