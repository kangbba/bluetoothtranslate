import 'package:bluetoothtranslate/language_select_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';



class LanguageItem {
  late final TranslateLanguage? translateLanguage;
  late final String? menuDisplayStr;
  late final String? speechLocaleId;
  late final String? langCodeGoogleServer;
  late final String? langCodePapagoServer;
  late final int? langCodeArduino;

  LanguageItem({
    this.translateLanguage,
    this.menuDisplayStr,
    this.speechLocaleId,
    this.langCodeGoogleServer,
    this.langCodePapagoServer,
    this.langCodeArduino,
  });
}
class LanguageSelectControl with ChangeNotifier{

  late TranslateLanguage initialMyTranslateLanguage = TranslateLanguage.korean;
  late TranslateLanguage initialYourTranslateLanguage = TranslateLanguage.english;

  late LanguageItem _nowMyLanguageItem = findLanguageItemByTranslateLanguage(initialMyTranslateLanguage);
  LanguageItem get nowMyLanguageItem{
    return _nowMyLanguageItem;
  }
  set nowMyLanguageItem(LanguageItem value){
    _nowMyLanguageItem = value;
    notifyListeners();
  }
  late LanguageItem _nowYourLanguageItem = findLanguageItemByTranslateLanguage(initialYourTranslateLanguage);
  LanguageItem get nowYourLanguageItem{
    return _nowYourLanguageItem;
  }
  set nowYourLanguageItem(LanguageItem value){
    _nowYourLanguageItem = value;
    notifyListeners();
  }

// TODO: LanguageItem 관리
  LanguageItem findLanguageItemByTranslateLanguage(TranslateLanguage translateLanguage) {
  return languageDataList.firstWhere((item) => item.translateLanguage == translateLanguage, orElse: () => LanguageItem());
  }
  LanguageItem findLanguageItemByMenuDisplayStr(String menuDisplayStr) {
  return languageDataList.firstWhere((item) => item.menuDisplayStr == menuDisplayStr, orElse: () => LanguageItem());
  }
  initializeLanguageSelectControl(){

    late LanguageItem initialMyLanguageItem = findLanguageItemByTranslateLanguage(initialMyTranslateLanguage);
    late LanguageItem initialYourLanguageItem = findLanguageItemByTranslateLanguage(initialYourTranslateLanguage);

  }


  List<LanguageItem> languageDataList = [
    LanguageItem(translateLanguage: TranslateLanguage.english, menuDisplayStr: "English", speechLocaleId: "en_US", langCodeGoogleServer: "en", langCodePapagoServer: "en", langCodeArduino: 1),
    LanguageItem(translateLanguage: TranslateLanguage.spanish, menuDisplayStr: "Spanish", speechLocaleId: "es_ES", langCodeGoogleServer: "es", langCodePapagoServer: "es", langCodeArduino: 2),
    LanguageItem(translateLanguage: TranslateLanguage.french, menuDisplayStr: "French", speechLocaleId: "fr_FR", langCodeGoogleServer: "fr", langCodePapagoServer: "fr", langCodeArduino: 3),
    LanguageItem(translateLanguage: TranslateLanguage.german, menuDisplayStr: "German", speechLocaleId: "de_DE", langCodeGoogleServer: "de", langCodePapagoServer: "de", langCodeArduino: 4),
    LanguageItem(translateLanguage: TranslateLanguage.chinese, menuDisplayStr: "Chinese", speechLocaleId: "zh_CN", langCodeGoogleServer: "zh-CN", langCodePapagoServer: "zh-CN", langCodeArduino: 5),
    LanguageItem(translateLanguage: TranslateLanguage.arabic, menuDisplayStr: "Arabic", speechLocaleId: "ar_AR", langCodeGoogleServer: "ar", langCodePapagoServer: "", langCodeArduino: 6),
    LanguageItem(translateLanguage: TranslateLanguage.russian, menuDisplayStr: "Russian", speechLocaleId: "ru_RU", langCodeGoogleServer: "ru", langCodePapagoServer: "", langCodeArduino: 7),
    LanguageItem(translateLanguage: TranslateLanguage.portuguese, menuDisplayStr: "Portuguese", speechLocaleId: "pt_PT", langCodeGoogleServer: "pt", langCodePapagoServer: "", langCodeArduino: 8),
    LanguageItem(translateLanguage: TranslateLanguage.italian, menuDisplayStr: "Italian", speechLocaleId: "it_IT", langCodeGoogleServer: "it", langCodePapagoServer: "", langCodeArduino: 9),
    LanguageItem(translateLanguage: TranslateLanguage.japanese, menuDisplayStr: "Japanese", speechLocaleId: "ja_JP", langCodeGoogleServer: "ja", langCodePapagoServer: "ja", langCodeArduino: 10),
    LanguageItem(translateLanguage: TranslateLanguage.dutch, menuDisplayStr: "Dutch", speechLocaleId: "nl_NL", langCodeGoogleServer: "nl", langCodePapagoServer: "", langCodeArduino: 11),
    LanguageItem(translateLanguage: TranslateLanguage.korean, menuDisplayStr: "Korean", speechLocaleId: "ko_KR", langCodeGoogleServer: "ko", langCodePapagoServer: "", langCodeArduino: 12),
    LanguageItem(translateLanguage: TranslateLanguage.swedish, menuDisplayStr: "Swedish", speechLocaleId: "sv_SE", langCodeGoogleServer: "sv", langCodePapagoServer: "", langCodeArduino: 13),
    LanguageItem(translateLanguage: TranslateLanguage.turkish, menuDisplayStr: "Turkish", speechLocaleId: "tr_TR", langCodeGoogleServer: "tr", langCodePapagoServer: "", langCodeArduino: 14),
    LanguageItem(translateLanguage: TranslateLanguage.polish, menuDisplayStr: "Polish", speechLocaleId: "pl_PL", langCodeGoogleServer: "pl", langCodePapagoServer: "", langCodeArduino: 15),
    LanguageItem(translateLanguage: TranslateLanguage.danish, menuDisplayStr: "Danish", speechLocaleId: "da_DK", langCodeGoogleServer: "da", langCodePapagoServer: "", langCodeArduino: 16),
    LanguageItem(translateLanguage: TranslateLanguage.norwegian, menuDisplayStr: "Norwegian", speechLocaleId: "nb_NO", langCodeGoogleServer: "no", langCodePapagoServer: "", langCodeArduino: 17),
    LanguageItem(translateLanguage: TranslateLanguage.finnish, menuDisplayStr: "Finnish", speechLocaleId: "fi_FI", langCodeGoogleServer: "fi", langCodePapagoServer: "", langCodeArduino: 18),
    LanguageItem(translateLanguage: TranslateLanguage.czech, menuDisplayStr: "Czech", speechLocaleId: "cs_CZ", langCodeGoogleServer: "cs", langCodePapagoServer: "", langCodeArduino: 19),
    LanguageItem(translateLanguage: TranslateLanguage.thai, menuDisplayStr: "Thai", speechLocaleId: "th_TH", langCodeGoogleServer: "th", langCodePapagoServer: "th", langCodeArduino: 20),
    LanguageItem(translateLanguage: TranslateLanguage.greek, menuDisplayStr: "Greek", speechLocaleId: "el_GR", langCodeGoogleServer: "el", langCodePapagoServer: "", langCodeArduino: 21),
    LanguageItem(translateLanguage: TranslateLanguage.hungarian, menuDisplayStr: "Hungarian", speechLocaleId: "hu_HU", langCodeGoogleServer: "hu", langCodePapagoServer: "hu", langCodeArduino: 22),
    LanguageItem(translateLanguage: TranslateLanguage.hebrew, menuDisplayStr: "Hebrew", speechLocaleId: "he_IL", langCodeGoogleServer: "he", langCodePapagoServer: "he", langCodeArduino: 23),
    LanguageItem(translateLanguage: TranslateLanguage.romanian, menuDisplayStr: "Romanian", speechLocaleId: "ro_RO", langCodeGoogleServer: "ro", langCodePapagoServer: "ro", langCodeArduino: 24),
    LanguageItem(translateLanguage: TranslateLanguage.ukrainian, menuDisplayStr: "Ukrainian", speechLocaleId: "uk_UA", langCodeGoogleServer: "uk", langCodePapagoServer: "uk", langCodeArduino: 25),
    LanguageItem(translateLanguage: TranslateLanguage.vietnamese, menuDisplayStr: "Vietnamese", speechLocaleId: "vi_VN", langCodeGoogleServer: "vi", langCodePapagoServer: "vi", langCodeArduino: 26),
    LanguageItem(translateLanguage: TranslateLanguage.icelandic, menuDisplayStr: "Icelandic", speechLocaleId: "is_IS", langCodeGoogleServer: "is", langCodePapagoServer: "", langCodeArduino: 27),
    LanguageItem(translateLanguage: TranslateLanguage.bulgarian, menuDisplayStr: "Bulgarian", speechLocaleId: "bg_BG", langCodeGoogleServer: "bg", langCodePapagoServer: "bg", langCodeArduino: 28),
    LanguageItem(translateLanguage: TranslateLanguage.lithuanian, menuDisplayStr: "Lithuanian", speechLocaleId: "lt_LT", langCodeGoogleServer: "lt", langCodePapagoServer: "lt", langCodeArduino: 29),
    LanguageItem(translateLanguage: TranslateLanguage.latvian, menuDisplayStr: "Latvian", speechLocaleId: "lv_LV", langCodeGoogleServer: "lv", langCodePapagoServer: "lv", langCodeArduino: 30),
    LanguageItem(translateLanguage: TranslateLanguage.slovenian, menuDisplayStr: "Slovenian", speechLocaleId: "sl_SI", langCodeGoogleServer: "sl", langCodePapagoServer: "sl", langCodeArduino: 31),
    LanguageItem(translateLanguage: TranslateLanguage.croatian, menuDisplayStr: "Croatian", speechLocaleId: "hr_HR", langCodeGoogleServer: "hr", langCodePapagoServer: "hr", langCodeArduino: 32),
    // LanguageItem(translateLanguage: TranslateLanguage.estonian, menuDisplayStr: "Estonian", speechLocaleId: "et_EE", langCodeGoogleServer: "et", langCodePapagoServer: "", langCodeArduino: 33),
    // LanguageItem(translateLanguage: TranslateLanguage. , menuDisplayStr: "Serbian", speechLocaleId: "sr_RS", langCodeGoogleServer: "sr", langCodePapagoServer: "", langCodeArduino: 34),
    // LanguageItem(translateLanguage: TranslateLanguage.slovak, menuDisplayStr: "Slovak", speechLocaleId: "sk_SK", langCodeGoogleServer: "sk", langCodePapagoServer: "", langCodeArduino: 35),
    // LanguageItem(translateLanguage: TranslateLanguage.georgian, menuDisplayStr: "Georgian", speechLocaleId: "ka_GE", langCodeGoogleServer: "ka", langCodePapagoServer: "", langCodeArduino: 36),
    // LanguageItem(translateLanguage: TranslateLanguage.catalan, menuDisplayStr: "Catalan", speechLocaleId: "ca_ES", langCodeGoogleServer: "ca", langCodePapagoServer: "", langCodeArduino: 37),
    // LanguageItem(translateLanguage: TranslateLanguage.bengali, menuDisplayStr: "Bengali", speechLocaleId: "bn_IN", langCodeGoogleServer: "bn", langCodePapagoServer: "", langCodeArduino: 38),
    // LanguageItem(translateLanguage: TranslateLanguage.persian, menuDisplayStr: "Persian", speechLocaleId: "fa_IR", langCodeGoogleServer: "fa", langCodePapagoServer: "", langCodeArduino: 39),
    // LanguageItem(translateLanguage: TranslateLanguage.marathi, menuDisplayStr: "Marathi", speechLocaleId: "mr_IN", langCodeGoogleServer: "mr", langCodePapagoServer: "", langCodeArduino: 40),

  ];

}