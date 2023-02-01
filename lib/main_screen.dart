
import 'dart:async';

import 'package:bluetoothtranslate/permission_controller.dart';
import 'package:bluetoothtranslate/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
import 'package:bluetoothtranslate/speech.dart';
import 'package:flutter/material.dart';
import 'package:bluetoothtranslate/tranlsate_api.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';
import 'language_items.dart';

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
  LanguageItem currentTargetLanguageItem = languageItems[1];

  final List<DropdownMenuItem<String>> _languageMenuItems = [];
  @override
  void initState() {
    super.initState();
    _speech.initSpeechToText();
    for (var languageItem in languageItems) {
      _languageMenuItems.add(languageDropdownMenuItem(languageItem));
    }
    translateApi.initializeTranslateApi(currentSourceLanguageItem.translateLanguage!, currentTargetLanguageItem.translateLanguage!);
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
                children: <Widget>[
                  Expanded(
                    child: DropdownButton(
                      items: _languageMenuItems,
                      value: currentSourceLanguageItem.languageCode,
                      onChanged: (value) async{
                        await onChangedSourceDropdownMenuItem(value);
                        setState(() {
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: DropdownButton(
                      items: _languageMenuItems,
                      value: currentTargetLanguageItem.languageCode,
                      onChanged: (value) async{
                        await onChangedTargetDropdownMenuItem(value);
                        setState(() {
                        });
                      },
                    ),
                  ),

                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Center(
                child: Consumer<Speech>(
                  builder: (context, speech, child) {
                    inputTextEditController.text = speech.recongnizedText;
                    return TextField(
                      readOnly: true,
                      controller: inputTextEditController,
                      decoration: InputDecoration(
                        hintText: 'Input text',
                      ),
                    );
                  },
                ),
              ),
              Center(
                child: Consumer<Speech>(
                  builder: (context, speech, child) {
                    outputTextEditController.text = _lastTranslatedStr;
                    return TextField(
                      readOnly: true,
                      controller: outputTextEditController,
                      decoration: InputDecoration(
                        hintText: 'Output text',
                      ),
                    );
                  },
                ),
              ),

              SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
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

  onChangedSourceDropdownMenuItem(String? value) async {
    currentSourceLanguageItem = findLanguageItemByLanguageCode(value!);
  }
  onChangedTargetDropdownMenuItem(String? value) async {

    LanguageItem languageItem = findLanguageItemByLanguageCode(value!);

    final bool isDownloaded = await languageItem.getModelDownloaded();
    bool readyForTranslated = isDownloaded;
    print("선택시 download 상태 : $isDownloaded");

    if (!isDownloaded) {
      simpleLoadingDialog(context, "${languageItem.menuDisplayStr}을 다운로드 중입니다. 잠시 기다려주세요.");
      Object result = await languageItem.downloadModel(7);
      if(result is TimeoutException)
      {
        print("TimeoutException");
        readyForTranslated = false;
      }
      else{
        bool isDownloadSuccess = (result as bool);
        print(isDownloadSuccess == true ? "다운로드 성공!!" : "다운로드 실패!!");
        readyForTranslated = isDownloadSuccess;
      }
      Navigator.of(context).pop();
    }

    if(readyForTranslated)
    {
      currentTargetLanguageItem = languageItem;
      TranslateLanguage? targetTranslateLanguage = currentTargetLanguageItem.translateLanguage;
      if(targetTranslateLanguage == null)
      {
        throw('$targetTranslateLanguage is null');
      }
    }
  }


}


//
// ElevatedButton _translateBtn() {
//   return ElevatedButton(
//             child: Text('Translate'),
//             onPressed: () async {
//               String textToTranslate = inputTextEditController.text;
//               String translatedText = await _translateTextWithCurrentLanguage(textToTranslate);
//               setState(() {
//                 _translatedText = translatedText;
//               });
//             },
//           );
// }
