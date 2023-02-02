import 'package:bluetoothtranslate/language_datas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechControl extends ChangeNotifier{
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _recongnizedText = '';
  String currentLocaleId = '';

  initSpeechToText(LanguageItem languageItem)
  {
    _speechToText.initialize();
    changeCurrentLocal(languageItem.speechLocaleId!);
  }
  startListening() async{
    print("startListening");
    _isListening = true;
    notifyListeners();
    await _speechToText.listen(
        localeId: currentLocaleId,
        onResult: (result) async {
          _recongnizedText = result.recognizedWords;
          print("SpeechToText Result : $result");

          if(result.finalResult)
          {
            await stopListening();
          }
          else{
            print("듣는중");
          }
          notifyListeners();
        }
      );
  }

  stopListening() async{
    print("endListening");
    _isListening = false;
    notifyListeners();
    await _speechToText.stop();
  }

  String get recongnizedText => _recongnizedText;
  bool get isListening => _isListening;

  void changeCurrentLocal(String speechLocaleId) {
    currentLocaleId = speechLocaleId;
  }
}