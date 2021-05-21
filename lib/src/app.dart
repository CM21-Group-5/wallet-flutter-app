import 'package:cm_pratical_assignment_2/src/views/ui/home.dart';
import 'package:flutter/material.dart';

class CMApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Wallet',
      theme: new ThemeData(scaffoldBackgroundColor: Colors.white),
      home: Home(title: 'My Wallet'),
    );
  }
}
