import 'package:google_cloud_translation/google_cloud_translation.dart';

class TranslateByGoogleServer
{
  final String apiKey = "AIzaSyBlraqGv_3DXKqEsUD3Pce8sTPEzLbRb6U";
  late Translation _translation;

  final String _text =
      'Toda persona tiene derecho a la educación. La educación debe ser gratuita, al menos en lo concerniente a la instrucción elemental y fundamental. La instrucción elemental será obligatoria. La instrucción técnica y profesional habrá de ser generalizada; el acceso a los estudios superiores será igual para todos, en función de los méritos respectivos.';
  TranslationModel _translated = TranslationModel(translatedText: '', detectedSourceLanguage: '');
  TranslationModel _detected = TranslationModel(translatedText: '', detectedSourceLanguage: '');

  initializeTranslateByGoogleServer()
  {
    _translation = Translation( apiKey: apiKey,);
  }

  Future<TranslationModel> getTranslationModel (String inputStr, String from, String to) async {
    TranslationModel translationModel = await _translation.translate(text: inputStr, to: to);
    return translationModel;
  }
}