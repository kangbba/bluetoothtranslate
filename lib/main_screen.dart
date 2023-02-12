
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetoothtranslate/bluetooth_control.dart';
import 'package:bluetoothtranslate/permission_controller.dart';
import 'package:bluetoothtranslate/simple_ask_dialog.dart';
import 'package:bluetoothtranslate/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/simple_loading_dialog.dart';
import 'package:bluetoothtranslate/simple_separator.dart';
import 'package:bluetoothtranslate/simple_snackbar.dart';
import 'package:bluetoothtranslate/sizes.dart';
import 'package:bluetoothtranslate/speech_to_text_control.dart';
import 'package:bluetoothtranslate/test_screen.dart';
import 'package:bluetoothtranslate/text_to_speech_control.dart';
import 'package:bluetoothtranslate/translage_by_papagoserver.dart';
import 'package:bluetoothtranslate/translate_by_googleserver.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
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

  TranslateTool? _lastTranslatedTool;
  TextEditingController inputTextEditController = TextEditingController();
  TextEditingController outputTextEditController = TextEditingController();


  late LanguageItem currentSourceLanguageItem = languageDatas.languageItems[11];
  late LanguageItem currentTargetLanguageItem = languageDatas.languageItems[0];



  void refresh() {
    setState(() {});
  }
  @override
  void initState() {
    super.initState();

    languageDatas.initializeLanguageDatas();
    _bluetoothControl.initializeBluetoothControl();

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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              bluetoothDeviceSelectBtn(context),
              SizedBox(width: 8,),
              currentDeviceStateRamp()
            ],
          ),
          toolbarHeight: 70,
          backgroundColor: Colors.deepPurple[900],
        ),

        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
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
                          _dropdownMenuSwitchBtn(),
                          _dropdownMenuOutput(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: _audioRecordBtn(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdownMenuSwitchBtn() {
    return SizedBox(
      height: 30,
      child: InkWell(
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
    );
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
            backgroundColor: Colors.deepPurpleAccent,
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
        return Stack(
          children: [
            Align(
              alignment: Alignment.center,
                child: Icon(Icons.circle, color: Colors.indigo, size: 60,)),
            Align(
              alignment: Alignment.center,
                child: InkWell(
                    onTap: () async{
                      if (await ConnectivityWrapper.instance.isConnected) {
                        bool hasPermission = await PermissionController.checkIfVoiceRecognitionPermisionGranted();
                        if (!hasPermission) {
                          PermissionController.showNoPermissionSnackBar(context);
                        }
                        else {
                          if(_bluetoothControl.selectedDeviceForm == null) {
                            await simpleConfirmDialog(context, "블루투스 기기 연결이 안되었습니다.", "먼저 블루투스 기기에 연결해주세요.");
                          }
                          else{
                            if (speechToTextControl.isListening) {
                            await stopListening();
                            } else {
                            await startListening();
                            }
                            setState(() {});
                          }
                        }
                      }
                      else{
                        showSimpleSnackBar(context, "인터넷 연결 안되었어요", 1);
                      }
                    },
                    child: Icon(speechToTextControl.isListening ? Icons.stop : Icons.mic, color: Colors.white,))),
          ],
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

    int realTimeCounter = 0;
    await speechToTextControl.speechToText.listen(
      listenFor: Duration(seconds: 10),
      localeId: speechToTextControl.currentLocaleId,
      onResult: (result) async {
        String? recognizedWords = result.recognizedWords;
        print("SpeechToText 듣는중 : $result");


        if(speechToTextControl.recentRecognizedWords != recognizedWords)
        {
          realTimeCounter++;
          inputTextEditController.text = recognizedWords;
          speechToTextControl.recentRecognizedWords = recognizedWords;
        }
        if(result.finalResult)
        {
          stopListening();
        }
      },
    ).then((value) async{
    }).onError((error, stackTrace) {
      print("error $error");
      stopListening();
    });
  }
  stopListening() async{
    print("endListening");
    speechToTextControl.isListening = false;
    await speechToTextControl.speechToText.stop();
    await whenSpeechEnd(speechToTextControl.recentRecognizedWords);
  }
  whenSpeechEnd(String recentRecognizedWords) async
  {
    if(_bluetoothControl.selectedDeviceForm == null)
    {
      bool? response = await simpleAskDialog(context, "기기 연결이 안되어있습니다", "블루투스 기기에 연결하시겠습니까?");
      if(response == true)
      {
        await onClickedOpenDeviceSelectScreen();
      }
    }
    else{
      await trySendMsgToDevice(recentRecognizedWords);
      setState(() {

      });
     // await sendMessageToDevice(targetLanguageItemToUse, translatedWords);
    }
  }

  Future<String?> _translateTextWithCurrentLanguage(String inputStr, TranslateTool translateTool) async
  {
    print("translateTool $translateTool 를 이용해 번역 시도합니다.");
    String? finalStr;
    switch(translateTool!)
    {
      case TranslateTool.googleDevice:
        simpleLoadingDialog(context, "Device 언어 다운로드중");
        finalStr = await translateByGoogleDevice.textTranslate(inputStr);
        Navigator.of(context).pop();
        break;
      case TranslateTool.papagoServer:
        String? from = currentSourceLanguageItem.langCodePapagoServer;
        String? to =  currentTargetLanguageItem.langCodePapagoServer;
        //papago str이 비어있으면 구글것을 활용해줌.
        String sourceStr = (from != null && from!.isNotEmpty) ? from! : currentSourceLanguageItem.langCodeGoogleServer!;
        String targetStr = (to != null && from!.isNotEmpty) ? to! : currentTargetLanguageItem.langCodeGoogleServer!;
        //해석시작
        finalStr = await translateByPapagoServer.textTranslate(inputStr, sourceStr, targetStr);
        break;
      case TranslateTool.googleServer:
        String from =  currentSourceLanguageItem.langCodeGoogleServer!;
        String to =  currentTargetLanguageItem.langCodeGoogleServer!;
        TranslationModel translationModel = await translateByGoogleServer.getTranslationModel(inputStr, from, to);
        finalStr = translationModel.translatedText;
        break;
    }
    return (finalStr == null) ? null : finalStr;
  }

  onSelectedSourceDropdownMenuItem(LanguageItem languageItem) {
    speechToTextControl.currentLocaleId = (languageItem.speechLocaleId!);
    currentSourceLanguageItem = languageItem;
    translateByGoogleDevice.changeTranslateApiLanguage(languageItem.translateLanguage, currentTargetLanguageItem.translateLanguage);

    setState(() {
    });
  }
  onSelectedTargetDropdownMenuItem(LanguageItem languageItem){
    currentTargetLanguageItem = languageItem;
    translateByGoogleDevice.changeTranslateApiLanguage(currentSourceLanguageItem.translateLanguage, languageItem.translateLanguage);
    setState(() {
    });
  }

//
// LanguageItem languageItem = languageDatas.findLanguageItemByMenuDisplayStr(value!);
// bool readyForTranslate = await downloadLanguageIfNeeded(languageItem);
// if(readyForTranslate) {
//

  Widget _dropdownMenuInput() {
    return SizedBox(
      width: 100,
      child: DropdownButton(
        isExpanded: true,
        items: languageDatas.languageMenuItems,
        value: currentSourceLanguageItem.menuDisplayStr,
        onChanged: (value) async{
          LanguageItem languageItem = languageDatas.findLanguageItemByMenuDisplayStr(value!);
          await onSelectedSourceDropdownMenuItem(languageItem);
          setState(() {
          });
        },
      ),
    );
  }
  Widget _dropdownMenuOutput() {
    return SizedBox(
      width: 100,
      child: DropdownButton(
        isExpanded: true,
        items: languageDatas.languageMenuItems,
        value: currentTargetLanguageItem.menuDisplayStr,
        onChanged: (value) async{
          LanguageItem languageItem = languageDatas.findLanguageItemByMenuDisplayStr(value!);

          onSelectedTargetDropdownMenuItem(languageItem);
          setState(() {});
        },
      ),
    );
  }

  ButtonStyle standardBtnStyle()
  {
    return ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
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
        await onClickedOpenDeviceSelectScreen();
      },
    );
  }
  Widget currentDeviceStateRamp() {
    return Consumer<BluetoothControl>(
      builder: (context, bluetoothControl, _) {
        return StreamBuilder<BluetoothDeviceState>(
          stream: bluetoothControl.selectedDeviceForm?.device.state,
          builder: (context, snapshot) {
            Color rampColor;
            String deviceName = bluetoothControl.selectedDeviceForm?.device.name ?? "";
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
                bluetoothControl.selectedDeviceForm != null ? SizedBox(height: 2,) : Container(),
                Icon(Icons.circle, color: rampColor, size: iconSize,),
                bluetoothControl.selectedDeviceForm != null ? SizedBox(height: 2,) : Container(),
                bluetoothControl.selectedDeviceForm != null ? Text(deviceName, style: TextStyle(fontSize: 8, color: Colors.white), textAlign: TextAlign.center,): Container(),
              ],
            );
          },
        );
      },
    );
  }

  String getFullMsg(LanguageItem targetLanguageItemToUse, String translatedMsg)
  {
    int arduinoUniqueId = targetLanguageItemToUse.langCodeArduino!;
    String fullMsgToSend = '$arduinoUniqueId:$translatedMsg;';
    return fullMsgToSend;
  }
  trySendMsgToDevice (String recognizedWords) async{

    print("-----------------------번역시도------------------------");
    bool isContainChina =
        (currentSourceLanguageItem.translateLanguage == TranslateLanguage.chinese) || (currentTargetLanguageItem.translateLanguage == TranslateLanguage.chinese);


    //빈도조절 추가.
    textToSpeechControl.changeLanguage(currentTargetLanguageItem.speechLocaleId!);

    List<TranslateTool> trToolsOrderStandard = [TranslateTool.googleServer, TranslateTool.papagoServer, TranslateTool.googleDevice];
    List<TranslateTool> trToolsOrderChina = [TranslateTool.papagoServer, TranslateTool.googleDevice, TranslateTool.googleServer];

    String? translatedWords;
    TranslateTool? trToolConfirmed;
    List<TranslateTool> trToolsToUse = isContainChina ? trToolsOrderChina : trToolsOrderStandard;
    for(int i = 0 ; i < trToolsToUse.length ; i++)
    {
      TranslateTool translateTool = trToolsToUse[i];
      String? response = await _translateTextWithCurrentLanguage(recognizedWords, translateTool);
      if(response != null && response!.isNotEmpty)
      {
        translatedWords = response!;
        trToolConfirmed = translateTool;
        break;
      }
    }
    print("-----------------------번역 끝------------------------");
    if(trToolConfirmed != null && translatedWords != null)
    {
      outputTextEditController.text = translatedWords;
      String fullMsg = getFullMsg(currentTargetLanguageItem ,translatedWords);
      await sendMessageToSelectedDevice(fullMsg);
    }
    print("-----------------------전송 끝------------------------");
    _onClickedTextToSpeechBtn();
  }
  sendMessageToSelectedDevice(String fullMsgToSend) async{
    try {
      await _bluetoothControl.sendMessage(_bluetoothControl.selectedDeviceForm!.device, fullMsgToSend);
    } catch (e) {
      throw Exception("메세지 전송 실패 이유 : $e");
    }
  }

  onClickedOpenDeviceSelectScreen() async{
    bool hasPermission = await PermissionController.checkIfBluetoothPermissionsGranted();
    if (!hasPermission) {
      print("권한에 문제가있음");
      return;
    }
    _bluetoothControl.startScan();
    showModalBottomSheet(
      useSafeArea: true,
      isDismissible: false,
      context: context,
      builder: (context) {
        return DeviceSelectScreen(bluetoothControl: _bluetoothControl);
      },
    );
  }
}

