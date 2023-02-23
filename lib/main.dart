
import 'package:bluetoothtranslate/test_speech.dart';
import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs : prefs));
}
class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  MyApp({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: ThemeData(
      //   fontFamily: 'NotoSans-Regular',
      // ),
      home: MainScreen(prefs: prefs,),
    );
  }
}
