
import 'dart:async';

import 'package:bluetoothtranslate/permission_controller.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
import 'package:bluetoothtranslate/simple_snackbar.dart';
import 'package:bluetoothtranslate/speech.dart';
import 'package:flutter/material.dart';
import 'package:bluetoothtranslate/tranlsate_api.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  TranslateApi translateApi = TranslateApi();
  final Speech _speech = Speech();

  String _lastTranslatedStr = '';
  TextEditingController inputTextEditController = TextEditingController();
  TextEditingController outputTextEditController = TextEditingController();

  LanguageItem currentSourceLanguageItem = languageItems[0];
  LanguageItem currentTargetLanguageItem = languageItems[2];

  @override
  void initState() {
    super.initState();
    _speech.initSpeechToText();
    translateApi.initializeTranslateApi(currentSourceLanguageItem.translateLanguage!, currentTargetLanguageItem.translateLanguage!);

    onSelectedSourceDropdownMenuItem(currentSourceLanguageItem);
    onSelectedTargetDropdownMenuItem(currentTargetLanguageItem);

  }
  @override
  void dispose() {
    // TODO: implement dispose
    inputTextEditController.dispose();
    outputTextEditController.dispose();
    translateApi.disposeTranslateApi();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider<Speech>(
          create: (_) => _speech,
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
              _translateFieldInput(),
              _separator(height : 1, top : 0, bottom: 0),
              _translateFieldOutput(),
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



  Widget _translateFieldInput() {
    return SizedBox(
      height: 300,
      child: Consumer<Speech>(
        builder: (context, speech, child) {
          inputTextEditController.text = speech.recongnizedText;
          return TextField(
            readOnly: true,
            controller: inputTextEditController,
            decoration: InputDecoration(
              border : InputBorder.none,
              hintText: _speech.isListening? "녹음중입니다" : "",
            ),
          );
        },
      ),
    );
  }

  Widget _translateFieldOutput() {
    return SizedBox(
      height : 300,
      child: Consumer<Speech>(
        builder: (context, speech, child) {
          outputTextEditController.text = _lastTranslatedStr;
          return TextField(
            readOnly: true,
            controller: outputTextEditController,
            decoration: InputDecoration(
              border : InputBorder.none,
              hintText: _speech.isListening? "녹음중입니다" : "",
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
          _speech.isListening ? Icons.stop : Icons.mic,
          key: ValueKey(_speech.isListening),
        ),
      ),
      onPressed: () async{
        bool isOn = false;
        bool hasPermission = await PermissionController.checkIfVoiceRecognitionPermisionGranted();
        if (!hasPermission) {
          PermissionController.showNoPermissionSnackBar(context);
        }
        else {
          if (_speech.isListening) {
            isOn = false;
            _speech.stopListening();
          } else {
            isOn = true;
            _speech.startListening();
          }
        }

        if(!isOn)
        {
          _lastTranslatedStr = await _translateTextWithCurrentLanguage(inputTextEditController.text);
          print("_lastTranslatedStr : $_lastTranslatedStr");
        }

        setState(() {
        });

      },
    );
  }
  Future<String> _translateTextWithCurrentLanguage(String inputText) async
  {
    translateApi.changeTranslateApiLanguage(currentSourceLanguageItem.translateLanguage, currentTargetLanguageItem.translateLanguage);
    final translatedText = await translateApi.translate(inputText);
    return translatedText;
  }

  onSelectedSourceDropdownMenuItem(LanguageItem languageItem) {
    setState(() {
      currentSourceLanguageItem = languageItem;
    });
  }
  Future<bool> downloadLanguageIfNeeded(LanguageItem languageItem) async
  {
    TranslateLanguage translateLanguage = languageItem.translateLanguage!;
    final bool isDownloaded = await translateApi.getLanguageDownloaded(translateLanguage);
    bool readyForTranslated = isDownloaded;
    print("선택시 download 상태 : $isDownloaded");

    if (!isDownloaded) {
      simpleLoadingDialog(
          context, "${languageItem.menuDisplayStr}을 다운로드 중입니다. 잠시 기다려주세요.");
      String resultStr = await translateApi.downloadLanguage(translateLanguage, 10);
      switch(resultStr)
      {
        case "SUCCESS" :
          readyForTranslated = true;
          languageItem.isDownloaded = true;
          showSimpleSnackBar(context, "다운로드 성공!!", 1);
          break;
        case "FAIL" :
          readyForTranslated = false;
          showSimpleSnackBar(context, "다운로드 실패!!", 1);
          break;
        case "ALREADY_EXIST" :
          readyForTranslated = true;
          showSimpleSnackBar(context, "이미 다운로드 됨", 1);
          break;
        default:
          readyForTranslated = false;
          print(resultStr);
          break;
      }
      Navigator.of(context).pop();
    }
    return readyForTranslated;
  }
  onSelectedTargetDropdownMenuItem(LanguageItem languageItem){

    setState(() {
      currentTargetLanguageItem = languageItem;
    });
  }

  Expanded _dropdownMenuInput() {
    return Expanded(
      child: DropdownButton(
        items: translateApi.languageMenuItems,
        value: currentSourceLanguageItem.menuDisplayStr,
        onChanged: (value) async{
          LanguageItem languageItem = translateApi.findLanguageItemByMenuDisplayStr(value!);
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
        items: translateApi.languageMenuItems,
        value: currentTargetLanguageItem.menuDisplayStr,
        onChanged: (value) async{
          LanguageItem languageItem = translateApi.findLanguageItemByMenuDisplayStr(value!);
          bool readyForTranslate = await downloadLanguageIfNeeded(languageItem);
          if(readyForTranslate) {
            onSelectedTargetDropdownMenuItem(languageItem);
          }
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

