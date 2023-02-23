import 'package:bluetoothtranslate/language_datas.dart';
import 'package:bluetoothtranslate/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextControl extends ChangeNotifier{


  final SpeechToText _speechToText = SpeechToText();
  String _recentRecognizedWords = '';
  bool _isFinalResultReturned = false;
  bool get isFinalResultReturned{
    return _isFinalResultReturned;
  }
  set isFinalResultReturned (bool value)
  {
    _isFinalResultReturned = value;
    notifyListeners();
  }

  String get recentRecognizedWords => _recentRecognizedWords;
  set recentRecognizedWords(String value) {
    _recentRecognizedWords = value;
    notifyListeners();
  }
  initSpeechToText()
  {
    _speechToText.initialize();
  }

  SpeechToText get speechToText => _speechToText;


  startListening(String currentLocaleID) async{
    _isFinalResultReturned = false;
    notifyListeners();
    await speechToText.listen(
      localeId: currentLocaleID,
      listenMode: ListenMode.dictation,
      onResult: (result) async {
        String? recognizedWords = result.recognizedWords;
        print("SpeechToText 듣는중 : $result");
        _recentRecognizedWords = recognizedWords;
        notifyListeners();
        if(result.finalResult)
        {
          print("끝났어");
          _isFinalResultReturned = true;
          notifyListeners();
          stopListening();
        }
      },
    ).onError((error, stackTrace) {
      print("error $error");
    });
  }
  stopListening() async{
    print("endListening");
    speechToText.stop();
    notifyListeners();
  }

}