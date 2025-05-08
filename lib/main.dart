import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main/app.dart';  // Import the MyApp from the main folder

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}