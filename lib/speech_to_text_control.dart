import 'package:bluetoothtranslate/language_datas.dart';
import 'package:bluetoothtranslate/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextControl extends ChangeNotifier{


  final SpeechToText _speechToText = SpeechToText();
  String _recentRecognizedWords = '';
  bool _isListening = false;
  String _currentLocaleId = '';

  initSpeechToText(LanguageItem languageItem)
  {
    _speechToText.initialize();
    _currentLocaleId = (languageItem.speechLocaleId!);
  }

  SpeechToText get speechToText => _speechToText;

  bool get isListening => _isListening;
  set isListening(bool value) {
    _isListening = value;
    notifyListeners();
  }

  String get recentRecognizedWords => _recentRecognizedWords;
  set recentRecognizedWords(String value) {
    _recentRecognizedWords = value;
    notifyListeners();
  }

  String get currentLocaleId => _currentLocaleId;
  set currentLocaleId(String value) {
    _currentLocaleId = value;
    notifyListeners();
  }
}