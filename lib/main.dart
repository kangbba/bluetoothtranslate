
import 'package:bluetoothtranslate/test/test_screen.dart';
import 'package:bluetoothtranslate/test/test_speech.dart';
import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData(
      //   fontFamily: 'NotoSans-Regular',
      // ),
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}
