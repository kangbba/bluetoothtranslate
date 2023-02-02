
import 'dart:async';

import 'package:bluetoothtranslate/permission_controller.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
import 'package:bluetoothtranslate/simple_snackbar.dart';
import 'package:bluetoothtranslate/sizes.dart';
import 'package:bluetoothtranslate/speech.dart';
import 'package:bluetoothtranslate/translage_by_papagoserver.dart';
import 'package:bluetoothtranslate/translate_by_googleserver.dart';
import 'package:flutter/material.dart';
import 'package:bluetoothtranslate/translate_by_googledevice.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';

import 'language_datas.dart';

enum TranslateTool
{
  googleServer,
  papagoServer,
  googleDevice,
}
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  LanguageDatas languageDatas = LanguageDatas();
  TranslateByGoogleServer translateByGoogleServer = TranslateByGoogleServer();
  TranslateByGoogleDevice translateByGoogleDevice = TranslateByGoogleDevice();
  TranslateByPapagoServer translateByPapagoServer = TranslateByPapagoServer();
  final SpeechControl speechControl = SpeechControl();

  String _lastTranslatedStr = '';
  TextEditingController inputTextEditController = TextEditingController();
  TextEditingController outputTextEditController = TextEditingController();


  late LanguageItem currentSourceLanguageItem;
  late LanguageItem currentTargetLanguageItem;

  @override
  void initState() {
    super.initState();
    languageDatas.initializeLanguageDatas();

    currentSourceLanguageItem = languageDatas.languageItems[0];
    currentTargetLanguageItem = languageDatas.languageItems[2];
    onSelectedSourceDropdownMenuItem(currentSourceLanguageItem);
    onSelectedTargetDropdownMenuItem(currentTargetLanguageItem);

    speechControl.initSpeechToText(currentSourceLanguageItem);
    translateByGoogleDevice.initializeTranslateByGoogleDevice();
    translateByGoogleServer.initializeTranslateByGoogleServer();
    translateByPapagoServer.initializeTranslateByPapagoServer();

  }
  @override
  void dispose() {
    // TODO: implement dispose
    inputTextEditController.dispose();
    outputTextEditController.dispose();
    translateByGoogleDevice.disposeTranslateApi();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return MultiProvider(
      providers: [
        ListenableProvider<SpeechControl>(
          create: (_) => speechControl,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('Translate'),
          backgroundColor: Colors.indigo,
        ),
        floatingActionButton:
        _audioRecordBtn(context),

        body: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _dropdownMenuInput(),
                  SizedBox(
                    width: 20.0,
                  ),
                  _dropdownMenuOutput(),

                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              _translateFieldInput(screenSize.height/4),
              _separator(height : 1, top : 0, bottom: 0),
              _translateFieldOutput(screenSize.height/4),
              _separator(height : 1, top : 0, bottom: 0),
              SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Container _separator({double height = 1, double top = 0, double bottom = 0}) {
    return Container(
      height: height,
      margin: EdgeInsets.only(top: top, bottom: bottom),
      color: Colors.grey[300],
    );
  }



  Widget _translateFieldInput(double height) {
    return SizedBox(
      height: height,
      child: Consumer<SpeechControl>(
        builder: (context, speech, child) {
          inputTextEditController.text = speech.recongnizedText;
          return TextField(
            readOnly: true,
            controller: inputTextEditController,
            decoration: InputDecoration(
              border : InputBorder.none,
              hintText: speechControl.isListening? "녹음중입니다" : "",
            ),
          );
        },
      ),
    );
  }

  Widget _translateFieldOutput(double height) {
    return SizedBox(
      height : height,
      child: Consumer<SpeechControl>(
        builder: (context, speech, child) {
          outputTextEditController.text = _lastTranslatedStr;
          return TextField(
            readOnly: true,
            controller: outputTextEditController,
            decoration: InputDecoration(
              border : InputBorder.none,
              hintText: speechControl.isListening? "녹음중입니다" : "",
            ),
          );
        },
      ),
    );
  }

  ElevatedButton _audioRecordBtn(BuildContext context) {
    return ElevatedButton(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: Icon(
          speechControl.isListening ? Icons.stop : Icons.mic,
          key: ValueKey(speechControl.isListening),
        ),
      ),
      onPressed: () async{
        bool isOn = false;
        bool hasPermission = await PermissionController.checkIfVoiceRecognitionPermisionGranted();
        if (!hasPermission) {
          PermissionController.showNoPermissionSnackBar(context);
        }
        else {
          if (speechControl.isListening) {
            isOn = false;
            speechControl.stopListening();
          } else {
            isOn = true;
            speechControl.startListening();
          }
        }

        if(!isOn)
        {
          bool isContainChina = (currentSourceLanguageItem.translateLanguage == TranslateLanguage.chinese) || (currentTargetLanguageItem.translateLanguage == TranslateLanguage.chinese);
          TranslateTool TranslateToolToUse = isContainChina ? TranslateTool.papagoServer : TranslateTool.googleServer;
          _lastTranslatedStr = await _translateTextWithCurrentLanguage(inputTextEditController.text, TranslateToolToUse);
          print("_lastTranslatedStr : $_lastTranslatedStr");
        }

        setState(() {
        });

      },
    );
  }
  Future<String> _translateTextWithCurrentLanguage(String inputStr, TranslateTool translateTool) async
  {
    print("translateTool $translateTool 를 이용해 번역 시도합니다.");
    String finalStr = "";
    switch(translateTool)
    {
      case TranslateTool.googleDevice:
        translateByGoogleDevice.changeTranslateApiLanguage(currentSourceLanguageItem.translateLanguage, currentTargetLanguageItem.translateLanguage);
        final translatedText = await translateByGoogleDevice.textTranslate(inputStr);
        finalStr = translatedText;
        break;
      case TranslateTool.papagoServer:
        final translatedText = await  translateByPapagoServer.textTranslate(inputStr, currentSourceLanguageItem.langCodeByPapagoServer!, currentTargetLanguageItem.langCodeByPapagoServer!);
        finalStr = translatedText;
        break;
      case TranslateTool.googleServer:
        String from =  currentSourceLanguageItem.langCodeByGoogleTranslateByServer!;
        String to =  currentTargetLanguageItem.langCodeByGoogleTranslateByServer!;
        TranslationModel translationModel = await translateByGoogleServer.getTranslationModel(inputStr, from, to);
        finalStr = translationModel.translatedText;
        break;
    }
    return finalStr;
  }

  onSelectedSourceDropdownMenuItem(LanguageItem languageItem) {

    speechControl.changeCurrentLocal(languageItem.speechLocaleId!);
    setState(() {
      currentSourceLanguageItem = languageItem;
    });
  }
  onSelectedTargetDropdownMenuItem(LanguageItem languageItem){
    setState(() {
      currentTargetLanguageItem = languageItem;
    });
  }

//
// LanguageItem languageItem = languageDatas.findLanguageItemByMenuDisplayStr(value!);
// bool readyForTranslate = await downloadLanguageIfNeeded(languageItem);
// if(readyForTranslate) {
//

  Expanded _dropdownMenuInput() {
    return Expanded(
      child: DropdownButton(
        items: languageDatas.languageMenuItems,
        value: currentSourceLanguageItem.menuDisplayStr,
        onChanged: (value) async{
          LanguageItem languageItem = languageDatas.findLanguageItemByMenuDisplayStr(value!);
          await onSelectedSourceDropdownMenuItem(languageItem);
          setState(() {
          });
        },
        icon: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.arrow_drop_down,
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }
  Expanded _dropdownMenuOutput() {
    return Expanded(
      child: DropdownButton(
        items: languageDatas.languageMenuItems,
        value: currentTargetLanguageItem.menuDisplayStr,
        onChanged: (value) async{
          LanguageItem languageItem = languageDatas.findLanguageItemByMenuDisplayStr(value!);
          onSelectedTargetDropdownMenuItem(languageItem);
          setState(() {});
        },
        icon: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.arrow_drop_down,
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
    );
  }
}

