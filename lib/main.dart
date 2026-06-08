import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/screens/home_screen.dart';
import 'package:habit_tracker/services/hive_services.dart';
import 'package:habit_tracker/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // STEP 1 - SETUP TIME ZONE
  tz.initializeTimeZones();
  _setLocalTimezone();


  // STEP 2 - INIT HIVE
  await HiveServices().init();

  // STEP 2 - INIT NOTIFICATION
  await NotificationService().init();

  runApp(
    ChangeNotifierProvider(
        create: (_) => HabitProvider(),
        child: MyApp()
    )
  );
}

void _setLocalTimezone() {
  // Get device's UTC offset
  final Duration offset = DateTime.now().timeZoneOffset;
  // Find matching timezone from database
  for (final location in tz.timeZoneDatabase.locations.values) {
    if (location.currentTimeZone.offset == offset.inMilliseconds) {
      tz.setLocalLocation(location);
      return;
    }
  }
  // Fallback to UTC if no match
  tz.setLocalLocation(tz.UTC);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F1E),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          surface: Color(0xFF1A1A2E),
        ),

        fontFamily: 'Poppins',

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),

        cardTheme: const CardThemeData(
          color: Color(0xFF1A1A2E),
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

