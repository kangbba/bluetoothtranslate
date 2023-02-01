import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslateApi {
  final TranslateLanguage sourceTranslateLanguage;
  final TranslateLanguage targetTranslateLanguage;

  final OnDeviceTranslator _onDeviceTranslator;

  TranslateApi({required this.sourceTranslateLanguage, required this.targetTranslateLanguage})
      : _onDeviceTranslator = OnDeviceTranslator(sourceLanguage: sourceTranslateLanguage, targetLanguage: targetTranslateLanguage);

  Future<String> translate(String textToTranslate) async {
    final result = await _onDeviceTranslator.translateText(textToTranslate);
    if (result.isNotEmpty) {
      return result;
    } else {
      return 'Failed to translate text';
    }
  }
}