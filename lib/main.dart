import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await Supabase.initialize(
    url: const String.fromEnvironment('https://buwwoyzplluslpijzped.supabase.co',
        defaultValue: 'https://buwwoyzplluslpijzped.supabase.co'),
    anonKey: const String.fromEnvironment('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1d3dveXpwbGx1c2xwaWp6cGVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5Nzc5MDQsImV4cCI6MjA4ODU1MzkwNH0._SwScJcVqynLRl6G1xojfrcYDBEJCr_oltytsFPWfr4',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ1d3dveXpwbGx1c2xwaWp6cGVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5Nzc5MDQsImV4cCI6MjA4ODU1MzkwNH0._SwScJcVqynLRl6G1xojfrcYDBEJCr_oltytsFPWfr4'),
  );

  runApp(const ProviderScope(child: LuxeBookApp()));
}