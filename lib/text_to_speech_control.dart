import 'package:flutter/cupertino.dart';
import 'package:text_to_speech/text_to_speech.dart';

import 'language_datas.dart';

class TextToSpeechControl extends ChangeNotifier{

  final TextToSpeech textToSpeech = TextToSpeech();
  initTextToSpeech()
  {

  }
  void speak(String str, LanguageItem? languageItem) {
    textToSpeech.setVolume(1);
    textToSpeech.setRate(1);
    if (languageItem != null && languageItem.speechLocaleId != null && languageItem.speechLocaleId != '') {
      textToSpeech.setLanguage(languageItem.speechLocaleId!);
    }
    textToSpeech.setPitch(1);
    textToSpeech.speak(str);
  }
}