import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Speech extends ChangeNotifier{
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _recongnizedText = '';

  initSpeechToText()
  {
    _speechToText.initialize();
  }
  startListening() {
    print("startListening");
    _isListening = true;
    _speechToText.listen(onResult: (result) {
      _recongnizedText = result.recognizedWords;
      notifyListeners();
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
}