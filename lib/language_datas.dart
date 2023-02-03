

import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class LanguageItem {
  final TranslateLanguage? translateLanguage;
  final String? menuDisplayStr;
  final String? speechLocaleId;
  final String? textToSpeechId;
  final String? langCodeByGoogleTranslateByServer;
  final String? langCodeByPapagoServer;
  final int? arduinoUniqueId;

  LanguageItem(
      {this.translateLanguage,this.menuDisplayStr, this.speechLocaleId, this.textToSpeechId, this.langCodeByGoogleTranslateByServer, this.langCodeByPapagoServer, this.arduinoUniqueId});
}
class LanguageDatas {
  List<LanguageItem> languageItems = [
    LanguageItem(translateLanguage: TranslateLanguage.korean, menuDisplayStr: 'Korean',  speechLocaleId : 'ko_KR',
        langCodeByGoogleTranslateByServer : 'ko', langCodeByPapagoServer: 'ko', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.english, menuDisplayStr: 'English',  speechLocaleId : 'en_US',
        langCodeByGoogleTranslateByServer : 'en', langCodeByPapagoServer: 'en', arduinoUniqueId: 1),
    LanguageItem(translateLanguage: TranslateLanguage.japanese, menuDisplayStr: 'Japanese',  speechLocaleId : 'ja_JP',
        langCodeByGoogleTranslateByServer : 'ja', langCodeByPapagoServer: 'ja', arduinoUniqueId: 2),
    LanguageItem(translateLanguage: TranslateLanguage.chinese, menuDisplayStr: 'Chinese',  speechLocaleId : 'zh_CN',
        langCodeByGoogleTranslateByServer : 'zh-CN', langCodeByPapagoServer: 'zh-CN', arduinoUniqueId: 3),
    LanguageItem(translateLanguage: TranslateLanguage.french, menuDisplayStr: 'French',  speechLocaleId : 'fr_FR',
        langCodeByGoogleTranslateByServer : 'fr', langCodeByPapagoServer: 'fr', arduinoUniqueId: 4),
    LanguageItem(translateLanguage: TranslateLanguage.german, menuDisplayStr: 'German',  speechLocaleId : 'de_DE',
        langCodeByGoogleTranslateByServer : 'de', langCodeByPapagoServer: 'de', arduinoUniqueId: 5),
    LanguageItem(translateLanguage: TranslateLanguage.italian, menuDisplayStr: 'Italian',  speechLocaleId : 'it_IT',
        langCodeByGoogleTranslateByServer : 'it', langCodeByPapagoServer: 'it', arduinoUniqueId: 6),
    LanguageItem(translateLanguage: TranslateLanguage.spanish, menuDisplayStr: 'Spanish',  speechLocaleId : 'es_ES',
        langCodeByGoogleTranslateByServer : 'es', langCodeByPapagoServer: 'es', arduinoUniqueId: 7),
    LanguageItem(translateLanguage: TranslateLanguage.russian, menuDisplayStr: 'Russian',  speechLocaleId : 'ru_RU',
        langCodeByGoogleTranslateByServer : 'ru', langCodeByPapagoServer: 'ru', arduinoUniqueId: 8),
    LanguageItem(translateLanguage: TranslateLanguage.portuguese, menuDisplayStr: 'Portuguese',  speechLocaleId : 'pt_PT',
        langCodeByGoogleTranslateByServer : 'pt', langCodeByPapagoServer: 'pt', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.arabic, menuDisplayStr: 'Arabic',  speechLocaleId : 'ar_AR',
        langCodeByGoogleTranslateByServer : 'ar', langCodeByPapagoServer: 'ar', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.dutch, menuDisplayStr: 'Dutch',  speechLocaleId : 'nl_NL',
        langCodeByGoogleTranslateByServer : 'nl', langCodeByPapagoServer: 'unk', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.polish, menuDisplayStr: 'Polish',  speechLocaleId : 'pl_PL',
        langCodeByGoogleTranslateByServer : 'pl', langCodeByPapagoServer: 'unk', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.indonesian, menuDisplayStr: 'Indonesian',  speechLocaleId : 'id_ID',
        langCodeByGoogleTranslateByServer : 'id', langCodeByPapagoServer: 'id', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.thai, menuDisplayStr: 'Thai',  speechLocaleId : 'th_TH',
        langCodeByGoogleTranslateByServer : 'th', langCodeByPapagoServer: 'th', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.turkish, menuDisplayStr: 'Turkish',  speechLocaleId : 'tr_TR',
        langCodeByGoogleTranslateByServer : 'tr', langCodeByPapagoServer: 'unk', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.vietnamese, menuDisplayStr: 'Vietnamese',  speechLocaleId : 'vi_VN',
        langCodeByGoogleTranslateByServer : 'vi', langCodeByPapagoServer: 'vi', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.malay, menuDisplayStr: 'Malay',  speechLocaleId : 'ms_MY',
        langCodeByGoogleTranslateByServer : 'ms', langCodeByPapagoServer: 'unk', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.ukrainian, menuDisplayStr: 'Ukrainian',  speechLocaleId : 'uk_UA',
        langCodeByGoogleTranslateByServer : 'uk', langCodeByPapagoServer: 'unk', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.swedish, menuDisplayStr: 'Swedish',  speechLocaleId : 'sv_SE',
        langCodeByGoogleTranslateByServer : 'sv', langCodeByPapagoServer: 'unk', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.norwegian, menuDisplayStr: 'Norwegian',  speechLocaleId : 'nb_NO',
        langCodeByGoogleTranslateByServer : 'nb', langCodeByPapagoServer: 'unk', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.danish, menuDisplayStr: 'Danish',  speechLocaleId : 'da_DK',
        langCodeByGoogleTranslateByServer : 'da', langCodeByPapagoServer: 'unk', arduinoUniqueId: 0),
    LanguageItem(translateLanguage: TranslateLanguage.finnish, menuDisplayStr: 'Finnish',  speechLocaleId : 'fi_FI',
        langCodeByGoogleTranslateByServer : 'fi', langCodeByPapagoServer: 'unk', arduinoUniqueId: 0)
  ];


  List<DropdownMenuItem> languageMenuItems = [];

  // TODO: 기본함수
  void initializeLanguageDatas() {
    for (var languageItem in languageItems) {
      languageMenuItems.add(languageDropdownMenuItem(languageItem));
    }
  }

    // TODO: 드랍다운 메뉴 아이템들 관리
  DropdownMenuItem<String> languageDropdownMenuItem(LanguageItem languageItem) {
    return DropdownMenuItem(
      value: languageItem.menuDisplayStr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(languageItem.menuDisplayStr!),
          SizedBox(width: 10),
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
}