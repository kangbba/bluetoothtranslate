import 'dart:async';
import 'package:google_cloud_translation/google_cloud_translation.dart';

class TranslateByGoogleServer {
  final String apiKey = "AIzaSyBlraqGv_3DXKqEsUD3Pce8sTPEzLbRb6U";
  late Translation _translation;
  late Completer<TranslationModel> _completer;

  initializeTranslateByGoogleServer() {
    _translation = Translation(apiKey: apiKey);
  }

  Future<TranslationModel> getTranslationModel(String inputStr, String from, String to) {
    _completer = Completer();
    _translation.translate(text: inputStr, to: to).then((translationModel) {
      if (!_completer.isCompleted) {
        _completer.complete(translationModel);
      }
    });
    return _completer.future;
  }

  Future<String?> textTranslate(String inputStr, String from, String to, int timeoutMilliSec) async {
    try {
      var translationModel = await Future.any([
        getTranslationModel(inputStr, from, to),
        Future.delayed(Duration(milliseconds: timeoutMilliSec)).then((_) => throw TimeoutException('Translation request timed out'))
      ]);
      return translationModel.translatedText;
    } on TimeoutException catch (_) {
      if (!_completer.isCompleted) {
        _completer.completeError(TimeoutException('Translation request timed out'));
      }
      return null;
    }
  }
}
