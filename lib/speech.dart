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
  startListening() {
    print("startListening");
    _isListening = true;
    _speechToText.listen(localeId: currentLocaleId, onResult: (result) {
      _recongnizedText = result.recognizedWords;
      notifyListeners();
      print("SpeechToText Result : $result");
    });
  }

  stopListening() {
    print("endListening");
    _isListening = false;
    _speechToText.stop();
    notifyListeners();
  }

  String get recongnizedText => _recongnizedText;
  bool get isListening => _isListening;

  void changeCurrentLocal(String speechLocaleId) {
    currentLocaleId = speechLocaleId;
  }
}