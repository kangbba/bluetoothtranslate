
import 'dart:async';

import 'package:bluetoothtranslate/bluetooth_control.dart';
import 'package:bluetoothtranslate/permission_controller.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
import 'package:bluetoothtranslate/simple_snackbar.dart';
import 'package:bluetoothtranslate/sizes.dart';
import 'package:bluetoothtranslate/speech_to_text_control.dart';
import 'package:bluetoothtranslate/text_to_speech_control.dart';
import 'package:bluetoothtranslate/translage_by_papagoserver.dart';
import 'package:bluetoothtranslate/translate_by_googleserver.dart';
import 'package:flutter/material.dart';
import 'package:bluetoothtranslate/translate_by_googledevice.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
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
  BluetoothControl bluetoothControl = BluetoothControl();

  TranslateByGoogleServer translateByGoogleServer = TranslateByGoogleServer();
  TranslateByGoogleDevice translateByGoogleDevice = TranslateByGoogleDevice();
  TranslateByPapagoServer translateByPapagoServer = TranslateByPapagoServer();
  final SpeechToTextControl speechToTextControl = SpeechToTextControl();
  final TextToSpeechControl textToSpeechControl = TextToSpeechControl();


  String _lastTranslatedStr = '';
  LanguageItem? _lastTranslatedLanguageItem = null;
  TextEditingController inputTextEditController = TextEditingController();
  TextEditingController outputTextEditController = TextEditingController();
  TextEditingController translateToolEditController = TextEditingController();


  late LanguageItem currentSourceLanguageItem;
  late LanguageItem currentTargetLanguageItem;



  @override
  void initState() {
    super.initState();
    languageDatas.initializeLanguageDatas();
    bluetoothControl.initializeBluetoothControl();

    currentSourceLanguageItem = languageDatas.languageItems[0];
    currentTargetLanguageItem = languageDatas.languageItems[2];
    onSelectedSourceDropdownMenuItem(currentSourceLanguageItem);
    onSelectedTargetDropdownMenuItem(currentTargetLanguageItem);

    speechToTextControl.initSpeechToText(currentSourceLanguageItem);
    textToSpeechControl.initTextToSpeech();

    translateByGoogleDevice.initializeTranslateByGoogleDevice();
    translateByGoogleServer.initializeTranslateByGoogleServer();
    translateByPapagoServer.initializeTranslateByPapagoServer();

  }
  @override
  void dispose() {
    // TODO: implement dispose
    inputTextEditController.dispose();
    outputTextEditController.dispose();
    translateToolEditController.dispose();
    translateByGoogleDevice.disposeTranslateApi();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return MultiProvider(
      providers: [
        ListenableProvider<SpeechToTextControl>(
          create: (_) => speechToTextControl,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Align(alignment : Alignment.center, child: Text('Translate Demo')),
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
              Stack(
                  children:[
                    _translateFieldOutput(screenSize.height/4),
                    _textToSpeechBtn(),
                  ]
              ),
              _separator(height : 1, top : 0, bottom: 0),
              _translateToolField(10),
              SizedBox(
                height: 20.0,
              ),
              blootoothDeviceSelectBtn(context),
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
      child: Consumer<SpeechToTextControl>(
        builder: (context, speech, child) {
          return TextField(
            readOnly: true,
            controller: inputTextEditController,
            decoration: InputDecoration(
              border : InputBorder.none,
              hintText: speechToTextControl.isListening? "녹음중입니다" : "",
            ),
          );
        },
      ),
    );
  }

  Widget _textToSpeechBtn()
  {
    if (outputTextEditController.text.isNotEmpty) {
      return Positioned(
        bottom: 8,
        left: 8,
        child: Container(
          height: 24,
          width: 24,
          child: ElevatedButton(
            onPressed: () {
              textToSpeechControl.speak(outputTextEditController.text);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                padding: EdgeInsets.zero,
                shape: CircleBorder()),
            child: Icon(
              Icons.play_circle_outline_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else{
         return Container();
    }
  }
  Widget _translateFieldOutput(double height) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Consumer<SpeechToTextControl>(
            builder: (context, speech, child) {
              return TextField(
                readOnly: true,
                controller: outputTextEditController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: speechToTextControl.isListening ? "Recording..." : "",
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _translateToolField(double height) {
    return SizedBox(
      height : height,
      child: Consumer<SpeechToTextControl>(
        builder: (context, speech, child) {
          return Container(
            alignment: Alignment.centerRight,
            height: height,
            child: TextField(
              textAlign: TextAlign.end,
              readOnly: true,
              controller: translateToolEditController,
              style: TextStyle(fontSize: 10),
              decoration: InputDecoration(
                border : InputBorder.none,
                contentPadding: EdgeInsets.only(right: 10),
              ),
            ),
          );
        },
      ),
    );
  }

  Consumer<SpeechToTextControl> _audioRecordBtn(BuildContext context) {
    return Consumer<SpeechToTextControl>(
      builder: (context, speechToTextControl, child) {
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
              speechToTextControl.isListening ? Icons.stop : Icons.mic,
            ),
          ),
          onPressed: () async{
            bool hasPermission = await PermissionController.checkIfVoiceRecognitionPermisionGranted();
            if (!hasPermission) {
              PermissionController.showNoPermissionSnackBar(context);
            }
            else {
              if (speechToTextControl.isListening) {
                await stopListening();
              } else {
                await startListening();
              }
              setState(() {});
            }
          },
        );
      },
    );
  }
  startListening() async{

    inputTextEditController.text = '';
    outputTextEditController.text = '';
    speechToTextControl.recentRecognizedWords = '';

    print("startListening");
    speechToTextControl.isListening = true;
    await speechToTextControl.speechToText.listen(
      localeId: speechToTextControl.currentLocaleId,
      onResult: (result) async {
        speechToTextControl.recentRecognizedWords = result.recognizedWords;
        print("SpeechToText 듣는중 : $result");
        if(result.finalResult)
        {
          await stopListening();
          await whenSpeechEnd(speechToTextControl.recentRecognizedWords);
        }
        else{
          inputTextEditController.text = speechToTextControl.recentRecognizedWords;
        }
      },
    );
  }
  stopListening() async{
    print("endListening");
    speechToTextControl.isListening = false;
    await speechToTextControl.speechToText.stop();
  }
  whenSpeechEnd(String recentRecognizedWords) async
  {
    inputTextEditController.text = recentRecognizedWords;
    LanguageItem sourceLanguageItemToUse = currentSourceLanguageItem;
    LanguageItem targetLanguageItemToUse = currentTargetLanguageItem;

    bool isContainChina = (sourceLanguageItemToUse.translateLanguage == TranslateLanguage.chinese) || (targetLanguageItemToUse.translateLanguage == TranslateLanguage.chinese);
    TranslateTool translateToolToUse = isContainChina ? TranslateTool.papagoServer : TranslateTool.googleServer;

    _lastTranslatedStr = await _translateTextWithCurrentLanguage(recentRecognizedWords, translateToolToUse);
    _lastTranslatedLanguageItem = targetLanguageItemToUse;

    print("_lastTranslatedStr : $_lastTranslatedStr");
    outputTextEditController.text = _lastTranslatedStr;
    translateToolEditController.text = "출처 : " + translateToolToUse.toString();
    await textToSpeechControl.changeLanguage(targetLanguageItemToUse.speechLocaleId!);
    setState(() {

    });
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
    speechToTextControl.currentLocaleId = (languageItem.speechLocaleId!);
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

  Widget blootoothDeviceSelectBtn(BuildContext context) {
    return ElevatedButton(
      child: Text("Scan for Devices"),
      onPressed: () async {

        bool hasPermission = await PermissionController.checkIfBluetoothPermissionsGranted();
        if (!hasPermission) {
          PermissionController.showNoPermissionSnackBar(context);
        }
        else{
          await bluetoothControl.scanningDevices(context);
        }
      },
    );
  }
}

