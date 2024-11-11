import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app_flutter/home.dart';
import 'package:weather_app_flutter/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final username = prefs.getString('username');

  runApp(MyApp(username: username));
}

class MyApp extends StatelessWidget {
  final String? username;

  MyApp({this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: username == null ? LoginPage() : WeatherPage(),
    );
  }
}
