// Entry point for the Peblo Story Buddy app.
// Provider is registered at the root so the entire tree can access StoryProvider.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peblo_story_buddy_app/peblo_story_buddy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait — standard for children's apps
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Immersive UI — hide status bar on supported devices
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PebloApp());
}
