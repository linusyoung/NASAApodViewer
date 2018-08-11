import 'package:flutter/material.dart';

import 'package:apod_viewer/src/home_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NASA APOD Viewer',
      theme: new ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(
        title: 'NASA APOD Viewer',
      ),
    );
  }
}
