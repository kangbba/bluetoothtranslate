import 'package:bluetoothtranslate/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class LanguageItem {
  final TranslateLanguage? translateLanguage;
  final String? menuDisplayStr;
  final String? arduinoUniqueId;
  final String?  languageUniqueCode;
  bool isDownloaded = false;

  LanguageItem({this.translateLanguage, this.menuDisplayStr, this.arduinoUniqueId, this.languageUniqueCode});
}

List<LanguageItem> languageItems = [
  LanguageItem(translateLanguage: TranslateLanguage.korean, languageUniqueCode: 'ko', menuDisplayStr: 'Korean', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.chinese, languageUniqueCode: 'zh', menuDisplayStr: 'Chinese', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.english, languageUniqueCode: 'en', menuDisplayStr: 'English', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.french, languageUniqueCode: 'fr', menuDisplayStr: 'French', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.german, languageUniqueCode: 'de', menuDisplayStr: 'German', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.spanish, languageUniqueCode: 'es', menuDisplayStr: 'Spanish', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.italian, languageUniqueCode: 'it', menuDisplayStr: 'Italian', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.japanese, languageUniqueCode: 'ja', menuDisplayStr: 'Japanese', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.russian, languageUniqueCode: 'ru', menuDisplayStr: 'Russian', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.arabic, languageUniqueCode: 'ar', menuDisplayStr: 'Arabic', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.hindi, languageUniqueCode: 'hi', menuDisplayStr: 'Hindi', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.swedish, languageUniqueCode: 'sv', menuDisplayStr: 'Swedish', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.norwegian, languageUniqueCode: 'no', menuDisplayStr: 'Norwegian', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.danish, languageUniqueCode: 'da', menuDisplayStr: 'Danish', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.dutch, languageUniqueCode: 'nl', menuDisplayStr: 'Dutch', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.finnish, languageUniqueCode: 'fi', menuDisplayStr: 'Finnish', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.indonesian, languageUniqueCode: 'id', menuDisplayStr: 'Indonesian', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.malay, languageUniqueCode: 'ms', menuDisplayStr: 'Malay', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.turkish, languageUniqueCode: 'tr', menuDisplayStr: 'Turkish', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.thai, languageUniqueCode: 'th', menuDisplayStr: 'Thai', arduinoUniqueId: null),
  LanguageItem(translateLanguage: TranslateLanguage.vietnamese, languageUniqueCode: 'vi', menuDisplayStr: 'Vietnamese', arduinoUniqueId: null),
];

class TranslateApi {
  late OnDeviceTranslator _onDeviceTranslator;
  final modelManager = OnDeviceTranslatorModelManager();
  List<DropdownMenuItem> languageMenuItems = [];

  // TODO: 기본함수
  initializeTranslateApi(TranslateLanguage sourceTranslateLanguage, TranslateLanguage targetTranslateLanguage)
  {
    makeDropdownMenuItems();
    changeTranslateApiLanguage(sourceTranslateLanguage,targetTranslateLanguage);
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


  // TODO: 드랍다운 메뉴 아이템들 관리
  List<DropdownMenuItem> makeDropdownMenuItems() {
    for (var languageItem in languageItems) {
      languageMenuItems.add(languageDropdownMenuItem(languageItem));
    }
    return languageMenuItems;
  }
  DropdownMenuItem<String> languageDropdownMenuItem(LanguageItem languageItem) {
    bool isDownloaded = false;

    return DropdownMenuItem(
      value: languageItem.menuDisplayStr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(languageItem.menuDisplayStr!),
          SizedBox(width: 10),
          if (!isDownloaded)
            Icon(Icons.cloud_download),
        ],
      ),
    );
  }

  // TODO: LanguageItem 관리
  LanguageItem findLanguageItemByTranslateLanguage(TranslateLanguage translateLanguage) {
    return languageItems.firstWhere((item) => item.translateLanguage == translateLanguage, orElse: () => LanguageItem());
  }
  LanguageItem findLanguageItemByMenuDisplayStr(String menuDisplayStr) {
    return languageItems.firstWhere((item) => item.menuDisplayStr == menuDisplayStr, orElse: () => LanguageItem());
  }


  // TODO: Translate 관련 함수들
  Future<String> translate(String textToTranslate) async {
    final result = await _onDeviceTranslator.translateText(textToTranslate);
    if (result.isNotEmpty) {
      return result;
    } else {
      return 'Failed to translate text';
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