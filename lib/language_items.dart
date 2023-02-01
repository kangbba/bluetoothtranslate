import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class LanguageItem {
  final modelManager = OnDeviceTranslatorModelManager();
  final String? languageCode;
  final String? menuDisplayStr;
  final String? arduinoUniqueId;
  final TranslateLanguage? translateLanguage;

  LanguageItem({this.languageCode, this.menuDisplayStr, this.arduinoUniqueId, this.translateLanguage});

  Future<bool> getModelDownloaded() async
  {
    if(translateLanguage == null)
    {
      throw("해당 LanguageItem은 translateLanguage 이 없음");
    }
    final bool response = await modelManager.isModelDownloaded(translateLanguage!.bcpCode);
    return response;
  }

  Future<bool> downloadModel() async
  {
    if(translateLanguage == null)
    {
      throw("해당 LanguageItem은 translateLanguage 이 없음");
    }
    bool isAlreadyDownloaded = await getModelDownloaded();
    if(isAlreadyDownloaded)
    {
      print("이미 있는 Language Item 이므로 다운로드 할 수 없음");
      return false;
    }
    final modelManager = OnDeviceTranslatorModelManager();
    final bool response = await modelManager.downloadModel(translateLanguage!.bcpCode);
    return response;
  }

  Future<bool> deleteModel() async
  {
    if(translateLanguage == null)
    {
      throw("해당 LanguageItem은 translateLanguage 이 없음");
    }
    bool isAlreadyDownloaded = await getModelDownloaded();
    if(!isAlreadyDownloaded)
    {
      print("이미 없는 Language Item 이므로 삭제할수 없음");
      return false;
    }
    final bool response = await modelManager.deleteModel(translateLanguage!.bcpCode);
    return response;
  }
}
LanguageItem findLanguageItemByLanguageCode(String languageCode) {
  return languageItems.firstWhere((item) => item.languageCode == languageCode, orElse: () => languageItems.last);
}
DropdownMenuItem<String> languageDropdownMenuItem(LanguageItem languageItem) {
  return DropdownMenuItem(
    value: languageItem.languageCode,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(languageItem.menuDisplayStr!),
        SizedBox(width: 10),
        FutureBuilder<bool>(
          future: languageItem.getModelDownloaded(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!) {
                return Icon(Icons.check, color: Colors.green);
              } else {
                return Icon(Icons.cloud_download, color: Colors.grey);
              }
            } else {
              return Container();
            }
          },
        ),
      ],
    ),
  );
}

List<LanguageItem> languageItems = [
  LanguageItem(languageCode: 'ko', menuDisplayStr: 'Korean', arduinoUniqueId: null, translateLanguage: TranslateLanguage.korean),
  LanguageItem(languageCode: 'zh', menuDisplayStr: 'Chinese', arduinoUniqueId: null, translateLanguage: TranslateLanguage.chinese),
  LanguageItem(languageCode: 'en', menuDisplayStr: 'English', arduinoUniqueId: null, translateLanguage: TranslateLanguage.english),
  LanguageItem(languageCode: 'fr', menuDisplayStr: 'French', arduinoUniqueId: null, translateLanguage: TranslateLanguage.french),
  LanguageItem(languageCode: 'de', menuDisplayStr: 'German', arduinoUniqueId: null, translateLanguage: TranslateLanguage.german),
  LanguageItem(languageCode: 'es', menuDisplayStr: 'Spanish', arduinoUniqueId: null, translateLanguage: TranslateLanguage.spanish),
  LanguageItem(languageCode: 'it', menuDisplayStr: 'Italian', arduinoUniqueId: null, translateLanguage: TranslateLanguage.italian),
  LanguageItem(languageCode: 'ja', menuDisplayStr: 'Japanese', arduinoUniqueId: null, translateLanguage: TranslateLanguage.japanese),
  LanguageItem(languageCode: 'ru', menuDisplayStr: 'Russian', arduinoUniqueId: null, translateLanguage: TranslateLanguage.russian),
  LanguageItem(languageCode: 'ar', menuDisplayStr: 'Arabic', arduinoUniqueId: null, translateLanguage: TranslateLanguage.arabic),
  LanguageItem(languageCode: 'hi', menuDisplayStr: 'Hindi', arduinoUniqueId: null, translateLanguage: TranslateLanguage.hindi),
  LanguageItem(languageCode: 'sv', menuDisplayStr: 'Swedish', arduinoUniqueId: null, translateLanguage: TranslateLanguage.swedish),
  LanguageItem(languageCode: 'no', menuDisplayStr: 'Norwegian', arduinoUniqueId: null, translateLanguage: TranslateLanguage.norwegian),
  LanguageItem(languageCode: 'da', menuDisplayStr: 'Danish', arduinoUniqueId: null, translateLanguage: TranslateLanguage.danish),
  LanguageItem(languageCode: 'nl', menuDisplayStr: 'Dutch', arduinoUniqueId: null, translateLanguage: TranslateLanguage.dutch),
  LanguageItem(languageCode: 'fi', menuDisplayStr: 'Finnish', arduinoUniqueId: null, translateLanguage: TranslateLanguage.finnish),
  LanguageItem(languageCode: 'id', menuDisplayStr: 'Indonesian', arduinoUniqueId: null, translateLanguage: TranslateLanguage.indonesian),
  LanguageItem(languageCode: 'ms', menuDisplayStr: 'Malay', arduinoUniqueId: null, translateLanguage: TranslateLanguage.malay),
  LanguageItem(languageCode: 'tr', menuDisplayStr: 'Turkish', arduinoUniqueId: null, translateLanguage: TranslateLanguage.turkish),
  LanguageItem(languageCode: 'th', menuDisplayStr: 'Thai', arduinoUniqueId: null, translateLanguage: TranslateLanguage.thai),
  LanguageItem(languageCode: 'vi', menuDisplayStr: 'Vietnamese', arduinoUniqueId: null, translateLanguage: TranslateLanguage.vietnamese),
];



