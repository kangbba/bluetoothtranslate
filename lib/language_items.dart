import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class LanguageItem {
  final String? languageCode;
  final String? menuDisplayStr;
  final String? arduinoUniqueId;
  final TranslateLanguage? translateLanguage;

  LanguageItem({this.languageCode, this.menuDisplayStr, this.arduinoUniqueId, this.translateLanguage});

}
LanguageItem findLanguageItemByLanguageCode(String languageCode) {
  return languageItems.firstWhere((item) => item.languageCode == languageCode, orElse: () => LanguageItem());
}

DropdownMenuItem<String> languageDropdownMenuItem(LanguageItem languageItem) {
  return DropdownMenuItem(
    value: languageItem.languageCode,
    child: Text(languageItem.menuDisplayStr!),
  );
}

List<LanguageItem> languageItems = [
  LanguageItem(languageCode: 'en', menuDisplayStr: 'English', arduinoUniqueId: null, translateLanguage: TranslateLanguage.english),
  LanguageItem(languageCode: 'fr', menuDisplayStr: 'French', arduinoUniqueId: null, translateLanguage: TranslateLanguage.french),
  LanguageItem(languageCode: 'de', menuDisplayStr: 'German', arduinoUniqueId: null, translateLanguage: TranslateLanguage.german),
  LanguageItem(languageCode: 'es', menuDisplayStr: 'Spanish', arduinoUniqueId: null, translateLanguage: TranslateLanguage.spanish),
  LanguageItem(languageCode: 'it', menuDisplayStr: 'Italian', arduinoUniqueId: null, translateLanguage: TranslateLanguage.italian),
  LanguageItem(languageCode: 'ja', menuDisplayStr: 'Japanese', arduinoUniqueId: null, translateLanguage: TranslateLanguage.japanese),
  LanguageItem(languageCode: 'ko', menuDisplayStr: 'Korean', arduinoUniqueId: null, translateLanguage: TranslateLanguage.korean),
  LanguageItem(languageCode: 'ru', menuDisplayStr: 'Russian', arduinoUniqueId: null, translateLanguage: TranslateLanguage.russian),
  LanguageItem(languageCode: 'zh', menuDisplayStr: 'Chinese', arduinoUniqueId: null, translateLanguage: TranslateLanguage.chinese),
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



