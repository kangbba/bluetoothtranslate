
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetoothtranslate/bluetooth_control.dart';
import 'package:bluetoothtranslate/permission_controller.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
import 'package:bluetoothtranslate/simple_separator.dart';
import 'package:bluetoothtranslate/simple_snackbar.dart';
import 'package:bluetoothtranslate/sizes.dart';
import 'package:bluetoothtranslate/speech_to_text_control.dart';
import 'package:bluetoothtranslate/test_screen.dart';
import 'package:bluetoothtranslate/text_to_speech_control.dart';
import 'package:bluetoothtranslate/translage_by_papagoserver.dart';
import 'package:bluetoothtranslate/translate_by_googleserver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bluetoothtranslate/translate_by_googledevice.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';

import 'device_select_screen.dart';
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

  BluetoothControl _bluetoothControl = BluetoothControl();

  LanguageDatas languageDatas = LanguageDatas();

  TranslateByGoogleServer translateByGoogleServer = TranslateByGoogleServer();
  TranslateByGoogleDevice translateByGoogleDevice = TranslateByGoogleDevice();
  TranslateByPapagoServer translateByPapagoServer = TranslateByPapagoServer();
  final SpeechToTextControl speechToTextControl = SpeechToTextControl();
  final TextToSpeechControl textToSpeechControl = TextToSpeechControl();


  String _lastTranslatedStr = '';
  LanguageItem? _lastTranslatedLanguageItem = null;
  TranslateTool? _lastTranslatedTool = null;
  TextEditingController inputTextEditController = TextEditingController();
  TextEditingController outputTextEditController = TextEditingController();


  late LanguageItem currentSourceLanguageItem;
  late LanguageItem currentTargetLanguageItem;



  @override
  void initState() {
    super.initState();
    languageDatas.initializeLanguageDatas();
    _bluetoothControl.initializeBluetoothControl();

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
        ListenableProvider<BluetoothControl>(
          create: (_) => _bluetoothControl,
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              bluetoothDeviceSelectBtn(context),
              SizedBox(width: 8,),
              currentDeviceStateRamp()
            ],
          ),
          backgroundColor: Colors.indigo,
        ),
        floatingActionButton:
        _audioRecordBtn(context),

        body: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              _translateFieldInput(screenSize.height / 5),
              SimpleSeparator(color: Colors.grey, height: 1, top: 0, bottom: 0),
              _translatedTextDescriptions(),
              _translateFieldOutput(screenSize.height / 5),
              SimpleSeparator(color: Colors.grey,height: 1, top: 5, bottom: 0),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _dropdownMenuInput(),
                  InkWell(
                    onTap: (){
                      var tmp = currentSourceLanguageItem;
                      currentSourceLanguageItem = currentTargetLanguageItem;
                      currentTargetLanguageItem = tmp;

                      onSelectedSourceDropdownMenuItem(currentSourceLanguageItem);
                      onSelectedTargetDropdownMenuItem(currentTargetLanguageItem);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, size: 14,),
                        Icon(Icons.arrow_forward, size: 14,),
                      ],
                    ),
                  ),
                  _dropdownMenuOutput(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _sendHelloTest(BuildContext context)
  {
    return ElevatedButton(
        onPressed: () async {
          await _bluetoothControl.sendMessage("0:ThisIsTest;");
        },
        child: Text("TEST"));
  }



  Widget _translatedTextDescriptions()
  {
    return SizedBox(
      height: 30,
      child: Stack(
        children: [
          Positioned(left: 2, top: 4, child: _textToSpeechBtn()),
          Positioned(right : 0, top: 8, child: _translateToolField()),
        ]
      ),
    );
  }
  Widget _textToSpeechBtn()
  {
    if (outputTextEditController.text.isNotEmpty) {
      return SizedBox(
        width: 22,
        height: 18,
        child: ElevatedButton(
          onPressed: () {
            _onClickedTextToSpeechBtn();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigoAccent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(6.0))),
          child: Icon(
            Icons.play_arrow,
            size: 14,
            color: Colors.white,
          ),
        ),
      );
    } else{
         return Container();
    }
  }

  Widget _translateFieldInput(double height) {
    return SizedBox(
      height: height,
      child: Consumer<SpeechToTextControl>(
        builder: (context, speech, child) {
          return TextField(
            readOnly: true,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
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
  Widget _translateFieldOutput(double height) {
    return SizedBox(
      height: height,
      child: Consumer<SpeechToTextControl>(
        builder: (context, speech, child) {
          return TextField(
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            readOnly: true,
            controller: outputTextEditController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: speechToTextControl.isListening ? "Recording..." : "",
            ),
          );
        },
      ),
    );
  }

  Widget _translateToolField() {
    String translateToolStr;
    switch (_lastTranslatedTool) {
      case TranslateTool.googleServer:
        translateToolStr = "Google Server";
        break;
      case TranslateTool.googleDevice:
        translateToolStr = "Google Device";
        break;
      case TranslateTool.papagoServer:
        translateToolStr = "Papago Server";
        break;
      default:
        translateToolStr = "없음";
        break;
    }
    if (_lastTranslatedTool != null) {
      return Text("출처 : $translateToolStr", style: TextStyle(fontSize: 8),);
    } else {
      return Container();
    }
  }

  Consumer<SpeechToTextControl> _audioRecordBtn(BuildContext context) {
    return Consumer<SpeechToTextControl>(
      builder: (context, speechToTextControl, child) {
        return ElevatedButton(
          style: standardBtnStyle(),
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
    print(speechToTextControl.speechToText);
    await speechToTextControl.speechToText.listen(
      localeId: speechToTextControl.currentLocaleId,
      onResult: (result) async {
        speechToTextControl.recentRecognizedWords = result.recognizedWords;
        print("SpeechToText 듣는중 : $result");
        if(result.finalResult)
        {
          await whenSpeechEnd(speechToTextControl.recentRecognizedWords);
        }
        else{
          inputTextEditController.text = speechToTextControl.recentRecognizedWords;
        }
      },
    ).then((value) => stopListening());
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

    String translatedWords = await _translateTextWithCurrentLanguage(recentRecognizedWords, translateToolToUse);

    print("_lastTranslatedStr : $translatedWords");
    outputTextEditController.text = translatedWords;

    _lastTranslatedStr = translatedWords;
    _lastTranslatedLanguageItem = targetLanguageItemToUse;
    _lastTranslatedTool = translateToolToUse;

    int arduinoUniqueId = targetLanguageItemToUse.arduinoUniqueId!;
    String msg = translatedWords;
    String fullMsgToSend = '$arduinoUniqueId:$msg;';

    setState(() {

    });
    try {
      var result = await _bluetoothControl.sendMessage(fullMsgToSend);
      if (!result) {
        throw Exception("Failed to send message");
      }
    } catch (e) {
      print(e);
    }
    await textToSpeechControl.changeLanguage(targetLanguageItemToUse.speechLocaleId!);
    _onClickedTextToSpeechBtn();

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

  Widget _dropdownMenuInput() {
    return DropdownButton(
      items: languageDatas.languageMenuItems,
      value: currentSourceLanguageItem.menuDisplayStr,
      onChanged: (value) async{
        LanguageItem languageItem = languageDatas.findLanguageItemByMenuDisplayStr(value!);
        await onSelectedSourceDropdownMenuItem(languageItem);
        setState(() {
        });
      },
    );
  }
  Widget _dropdownMenuOutput() {
    return DropdownButton(
      items: languageDatas.languageMenuItems,
      value: currentTargetLanguageItem.menuDisplayStr,
      onChanged: (value) async{
        LanguageItem languageItem = languageDatas.findLanguageItemByMenuDisplayStr(value!);
        onSelectedTargetDropdownMenuItem(languageItem);
        setState(() {});
      },
    );
  }

  ButtonStyle standardBtnStyle()
  {
    return ElevatedButton.styleFrom(
        backgroundColor: Colors.indigoAccent,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(6.0)));
  }

  void _onClickedTextToSpeechBtn() {
    textToSpeechControl.speak(outputTextEditController.text);
  }

  //TODO : 블루투스 관련 기능
  Widget bluetoothDeviceSelectBtn(BuildContext context) {
    return ElevatedButton(
      child: Icon(Icons.bluetooth_searching),
      style: standardBtnStyle(),
      onPressed: () async {
        _bluetoothControl.startScan();
        bool hasPermission = await PermissionController.checkIfBluetoothPermissionsGranted();
        if (!hasPermission) {
          print("권한에 문제가있음");
        }
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return DeviceSelectScreen(bluetoothControl: _bluetoothControl);
          },
        );
      },
    );
  }
  Widget currentDeviceStateRamp() {
    return Consumer<BluetoothControl>(
      builder: (context, bluetoothControl, _) {
        return StreamBuilder<BluetoothDeviceState>(
          stream: bluetoothControl.recentBluetoothDevice?.state,
          builder: (context, snapshot) {
            Color rampColor;
            String deviceName = bluetoothControl.recentBluetoothDevice?.name ?? "";
            double iconSize = 15;
            if (snapshot.hasData) {
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  rampColor = Colors.lightGreenAccent;
                  break;
                case BluetoothDeviceState.disconnected:
                  rampColor = Colors.red;
                  break;
                default:
                  rampColor = Colors.orange;
              }
            } else {
              rampColor = Colors.yellow;
            }
            return Column(
              children: [
                bluetoothControl.recentBluetoothDevice != null ? SizedBox(height: 2,) : Container(),
                Icon(Icons.circle, color: rampColor, size: iconSize,),
                bluetoothControl.recentBluetoothDevice != null ? SizedBox(height: 2,) : Container(),
                bluetoothControl.recentBluetoothDevice != null ? Text(deviceName, style: TextStyle(fontSize: 8, color: Colors.white), textAlign: TextAlign.center,): Container(),
              ],
            );
          },
        );
      },
    );
  }
}

