import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speech/flutter_speech.dart';
class SpeechRecognitionControl extends ChangeNotifier {

  // Platform messages are asynchronous, so we initialize in an async method.
  void activateSpeechRecognizer() {
    isCompleted = false;
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

  // bool _speechRecognitionAvailable = false;
  bool _isCompleted = false;
  bool get isCompleted {
    return _isCompleted;
  }
  set isCompleted(dynamic value)
  {
    _isCompleted = value;
    notifyListeners();
  }

  // bool _isError = false;
  // bool get isError {
  //   return _isError;
  // }
  // set isError(dynamic value)
  // {
  //   _isError = value;
  //   notifyListeners();
  // }
  //

  //
  // bool _isListening = false;
  // bool get isListening {
  //   return _isListening;
  // }
  // set isListening(dynamic value)
  // {
  //   _isListening = value;
  //   notifyListeners();
  // }
  String _transcription = '';
  String get transcription{
    return _transcription;
  }
  set transcription(String s)
  {
    _transcription = s;
    notifyListeners();
  }

  String _langCode = '';
  void start(String langCode) {
    isCompleted = false;
    _langCode = langCode;
    _speech.activate(langCode).then((_) {
    return _speech.listen().then((result) {
      print('_MyAppState.start => result $result');
      });
    });
  }

  void cancel() =>
      _speech.cancel().then((_) {

      }
      );

  void stop() => _speech.stop().then((_) {
    isCompleted = true;
  });

  void onSpeechAvailability(bool result) {
  // _speechRecognitionAvailable = result;
  }


  void onCurrentLocale(String locale) {
    // print('_MyAppState.onCurrentLocale... $locale');
    // selectedLang = languages.firstWhere((l) => l.code == locale;
  }

  void onRecognitionStarted() {
  }

  void onRecognitionComplete(String text) {
    print('_MyAppState.onRecognitionComplete... $text');
    transcription = text;
    isCompleted = transcription.isNotEmpty;
  }

  void onRecognitionResult(String text) {
    print('_MyAppState.onRecognitionResult... $text');
    transcription = text;
  }

  void errorHandler() {
    if(isCompleted){
      print("////수집 끝!");
    }
    else{
      print("///수집도중 에러");
      start(_langCode);
    }
  }
}