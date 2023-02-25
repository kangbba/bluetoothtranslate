import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';


class TextToSpeechControl extends ChangeNotifier{

  FlutterTts flutterTts = FlutterTts();
  initTextToSpeech() async
  {
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }
  changeLanguage(String langCode) async
  {
    List<String> separated = langCode.split('_');
    String manuplatedLangCode = "${separated[0]}-${separated[1]}";
    await flutterTts.setLanguage(manuplatedLangCode);
  }
  speak(String str) async {
    await flutterTts.speak(str);
  }
}