import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speech/flutter_speech.dart';
class SpeechRecognitionControl extends ChangeNotifier {

  // Platform messages are asynchronous, so we initialize in an async method.
  void activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.setErrorHandler(errorHandler);
    // _speech.activate('fr_FR').then((res) {
    //   setState(() => _speechRecognitionAvailable = res);
    // });
  }
  late SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false;
  bool _isCompleted = false;
  bool get isCompleted {
    return _isCompleted;
  }
  set isCompleted(dynamic value)
  {
    _isCompleted = value;
    notifyListeners();
  }

  bool _isListening = false;
  bool get isListening {
    return _isListening;
  }
  set isListening(dynamic value)
  {
    _isListening = value;
    notifyListeners();
  }
  String _transcription = '';
  String get transcription{
    return _transcription;
  }
  set transcription(String s)
  {
    _transcription = s;
    notifyListeners();
  }

  void start(String langCode) {
    _isCompleted = false;
    _speech.activate(langCode).then((_) {
    return _speech.listen().then((result) {
      print('_MyAppState.start => result $result');
      isListening = result;
      });
    });
  }

  void cancel() =>
      _speech.cancel().then((_) {
        isCompleted = true;
        isListening = false;}
      );

  void stop() => _speech.stop().then((_) {
    isCompleted = true;
    isListening = false;
  });

  void onSpeechAvailability(bool result) =>
      _speechRecognitionAvailable = result;

  void onCurrentLocale(String locale) {
    // print('_MyAppState.onCurrentLocale... $locale');
    // selectedLang = languages.firstWhere((l) => l.code == locale;
  }

  void onRecognitionStarted() {
    isCompleted = false;
    isListening = true;
  }

  void onRecognitionResult(String text) {
    print('_MyAppState.onRecognitionResult... $text');
    transcription = text;
  }

  void onRecognitionComplete(String text) {
    print('_MyAppState.onRecognitionComplete... $text');
    transcription = text;
    isListening = false;
    isCompleted = true;
    notifyListeners();
  }

  void errorHandler() { print("에러발생!");
  isCompleted = true; isListening = false; activateSpeechRecognizer();}
}