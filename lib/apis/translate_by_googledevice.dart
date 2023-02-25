
import 'package:bluetoothtranslate/helper/simple_loading_dialog.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';


class TranslateByGoogleDevice {
  late OnDeviceTranslator _onDeviceTranslator;
  final modelManager = OnDeviceTranslatorModelManager();

  // TODO: 기본함수
  initializeTranslateByGoogleDevice()
  {
    downloadLanguageIfNeeded(TranslateLanguage.chinese);
  }

  Future<bool> downloadLanguageIfNeeded(TranslateLanguage translateLanguage) async
  {
    final bool isDownloaded = await getLanguageDownloaded(translateLanguage);
    bool readyForTranslated = isDownloaded;
    print("선택시 download 상태 : $isDownloaded");

    if (!isDownloaded) {
      String resultStr = await downloadLanguage(translateLanguage, 10);
      switch (resultStr) {
        case "SUCCESS" :
          readyForTranslated = true;
          print("다운로드 성공!!");
          break;
        case "FAIL" :
          readyForTranslated = false;
          print("다운로드 실패!!");
          break;
        case "ALREADY_EXIST" :
          readyForTranslated = true;
          print("이미 다운로드 됨");
          break;
        default:
          readyForTranslated = false;
          print(resultStr);
          break;
      }
    }
    return readyForTranslated;
  }
  changeTranslateApiLanguage(TranslateLanguage? sourceTranslateLanguage, TranslateLanguage? targetTranslateLanguage)
  {
    if(sourceTranslateLanguage == null || targetTranslateLanguage == null)
    {
      throw("sourceTranslateLanguage or targetTranslateLanguage NULL");
    }
    _onDeviceTranslator = OnDeviceTranslator(sourceLanguage: sourceTranslateLanguage, targetLanguage: targetTranslateLanguage);
  }

  disposeTranslateApi()
  {
    _onDeviceTranslator.close();
  }

  // TODO: Translate 관련 함수들
  Future<String?> textTranslate(String textToTranslate) async {
    final result = await _onDeviceTranslator.translateText(textToTranslate);
    if (result.isNotEmpty) {
      return result;
    } else {
      'Failed to translate text';
      return null;
    }
  }
  Future<bool> getLanguageDownloaded(TranslateLanguage translateLanguage) async
  {
    if(translateLanguage == null)
    {
      throw("해당 LanguageItem은 translateLanguage 이 없음");
    }
    final bool response = await modelManager.isModelDownloaded(translateLanguage!.bcpCode);
    return response;
  }

  Future<String> downloadLanguage(TranslateLanguage translateLanguage, int timeoutSeconds) async {
    if (translateLanguage == null) {
      throw("해당 LanguageItem은 translateLanguage 이 없음");
    }
    bool isAlreadyDownloaded = await getLanguageDownloaded(translateLanguage);
    if (isAlreadyDownloaded) {
      print("이미 있는 Language Item 이므로 다운로드 할 수 없음");
      return "ALREADY_EXIST";
    }
    else{
      print("$translateLanguage 다운로드 시작..!");
      final modelManager = OnDeviceTranslatorModelManager();
      try {
        final bool response = await modelManager.downloadModel(
            translateLanguage!.bcpCode).timeout(
            Duration(seconds: timeoutSeconds));
        print("$translateLanguage 다운로드 완료 결과 : $response..!");
        return response ? "SUCCESS" : "FAIL";
      } catch (e) {
        return "TIMEOUT";
      }
    }
  }
  Future<bool> deleteLanguage(TranslateLanguage translateLanguage, int timeoutSeconds) async
  {
    if(translateLanguage == null)
    {
      throw("해당 LanguageItem은 translateLanguage 이 없음");
    }
    bool isAlreadyDownloaded = await getLanguageDownloaded(translateLanguage);
    if(!isAlreadyDownloaded)
    {
      print("이미 없는 Language Item 이므로 삭제할수 없음");
      return false;
    }
    print("$translateLanguage 삭제 시작..!");
    final bool response = await modelManager.deleteModel(translateLanguage!.bcpCode);
    print("$translateLanguage 삭제 완료 결과 : $response..!");
    return response;
  }




}