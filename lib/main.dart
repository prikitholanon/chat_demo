import 'package:chat_demo/login.dart';
import 'package:chat_demo/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const myTitle = 'Chat Demo';

  @override
  Widget build(BuildContext context) {
    dsPrint('run');
    return MaterialApp(
      title: myTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(title: myTitle),
      debugShowCheckedModeBanner: false,
    );
  }
}
