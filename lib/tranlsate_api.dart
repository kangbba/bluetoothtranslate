import 'package:bluetoothtranslate/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'language_items.dart';

class TranslateApi {
  late TranslateLanguage _sourceTranslateLanguage;
  late TranslateLanguage _targetTranslateLanguage;
  late OnDeviceTranslator _onDeviceTranslator;

  initializeTranslateApi(TranslateLanguage sourceTranslateLanguage, TranslateLanguage targetTranslateLanguage)
  {
    changeTranslateApiLanguage(sourceTranslateLanguage,targetTranslateLanguage);
  }

  changeTranslateApiLanguage(TranslateLanguage? sourceTranslateLanguage, TranslateLanguage? targetTranslateLanguage)
  {
    if(sourceTranslateLanguage == null || targetTranslateLanguage == null)
    {
      throw("sourceTranslateLanguage or targetTranslateLanguage NULL");
    }
    _sourceTranslateLanguage = sourceTranslateLanguage;
    _targetTranslateLanguage = targetTranslateLanguage;
    _onDeviceTranslator = OnDeviceTranslator(sourceLanguage: sourceTranslateLanguage, targetLanguage: targetTranslateLanguage);
  }

  disposeTranslateApi()
  {
    _onDeviceTranslator.close();
  }
  Future<String> translate(String textToTranslate) async {
    final result = await _onDeviceTranslator.translateText(textToTranslate);
    if (result.isNotEmpty) {
      return result;
    } else {
      return 'Failed to translate text';
    }
  }

}