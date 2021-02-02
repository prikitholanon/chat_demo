import 'package:chat_demo/const.dart';
import 'package:chat_demo/utils.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  HomeScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Future<bool> onBackPress() {
    testPrint();
    // openDialog();
    dtPrint('home', 'onBackPress');
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat MAIN',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: WillPopScope(
          onWillPop: onBackPress,
          child: Container()),
    );
  }
}
