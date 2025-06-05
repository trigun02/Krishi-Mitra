import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Screens/homescreen.dart';
import 'providers/dataprovider.dart';
import 'providers/predictionprovider.dart';
import 'dart:io';
void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

// Custom HttpOverrides class
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
      ],
      child: MaterialApp(
        title: 'KrishiMitra',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
