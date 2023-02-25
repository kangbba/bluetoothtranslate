import 'package:bluetoothtranslate/translage_by_papagoserver.dart';
import 'package:bluetoothtranslate/translate_by_googledevice.dart';
import 'package:bluetoothtranslate/translate_by_googleserver.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';

import 'language_datas.dart';
import 'simple_ask_dialog.dart';

enum TranslateTool
{
  googleServer,
  papagoServer,
  googleDevice,
}
class TranslateControl with ChangeNotifier
{
  TranslateByGoogleServer translateByGoogleServer = TranslateByGoogleServer();
  TranslateByGoogleDevice translateByGoogleDevice = TranslateByGoogleDevice();
  TranslateByPapagoServer translateByPapagoServer = TranslateByPapagoServer();

  void initializeTranslateControl()
  {
    translateByGoogleDevice.initializeTranslateByGoogleDevice();
    translateByGoogleServer.initializeTranslateByGoogleServer();
    translateByPapagoServer.initializeTranslateByPapagoServer();
  }
  Future<String?> getTranslatedWordsByTranslateTool(String inputStr, LanguageItem fromLanguageItem, LanguageItem toLanguageItem, TranslateTool translateTool) async
  {
    print("translateTool $translateTool 를 이용해 번역 시도합니다.");
    String? finalStr;
    switch(translateTool!)
    {
      case TranslateTool.googleDevice:
        bool isModelDownloaded = await translateByGoogleDevice.getLanguageDownloaded(toLanguageItem.translateLanguage!);
        if(!isModelDownloaded)
        {
          // bool? response = await simpleAskDialog(context, "서버 번역을 사용할수 없습니다.", "디바이스 번역을위해 언어를 다운로드하시겠습니까?");
          translateByGoogleDevice.changeTranslateApiLanguage(fromLanguageItem.translateLanguage, toLanguageItem.translateLanguage);
          finalStr = await translateByGoogleDevice.textTranslate(inputStr);
        }
        break;
      case TranslateTool.papagoServer:
        String? from = fromLanguageItem.langCodePapagoServer;
        String? to =  toLanguageItem.langCodePapagoServer;
        //papago str이 비어있으면 구글것을 활용해줌.
        String sourceStr = (from != null && from!.isNotEmpty) ? from! : fromLanguageItem.langCodeGoogleServer!;
        String targetStr = (to != null && from!.isNotEmpty) ? to! : toLanguageItem.langCodeGoogleServer!;
        //해석시작
        finalStr = await translateByPapagoServer.textTranslate(inputStr, sourceStr, targetStr);
        break;
      case TranslateTool.googleServer:
        String from =  fromLanguageItem.langCodeGoogleServer!;
        String to =  toLanguageItem.langCodeGoogleServer!;
        finalStr = await translateByGoogleServer.textTranslate(inputStr, from, to);
        break;
    }
    return (finalStr == null) ? null : finalStr;
  }


  Future<String> translateByAvailableTranslateTools (String recognizedWords, LanguageItem fromLanguageItem, LanguageItem toLanguageItem) async{

    bool isContainChina = (fromLanguageItem.translateLanguage == TranslateLanguage.chinese) || (toLanguageItem.translateLanguage == TranslateLanguage.chinese);

    List<TranslateTool> trToolsOrderStandard = [TranslateTool.googleServer, TranslateTool.papagoServer];
    List<TranslateTool> trToolsOrderChina = [TranslateTool.papagoServer, TranslateTool.googleServer];

    String? translatedWords;
    TranslateTool? trToolConfirmed;
    List<TranslateTool> trToolsToUse = isContainChina ? trToolsOrderChina : trToolsOrderStandard;
    for(int i = 0 ; i < trToolsToUse.length ; i++)
    {
      TranslateTool translateTool = trToolsToUse[i];
      String? response = await getTranslatedWordsByTranslateTool(recognizedWords, fromLanguageItem, toLanguageItem, translateTool);
      if(response != null && response!.isNotEmpty)
      {
        translatedWords = response!;
        trToolConfirmed = translateTool;
        break;
      }
    }
    if(trToolConfirmed != null && translatedWords != null)
    {
      return translatedWords;
    }
    return "";
  }
}
