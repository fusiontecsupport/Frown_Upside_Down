import 'package:flutter/material.dart';
import 'pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frown Upside Down',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashPage(palette: SplashPalette.colorhunt),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/splash/logo.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 10),
            const Text('Frown Upside Down'),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Welcome to Frown Upside Down!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
