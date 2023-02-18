
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
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

import 'audio_wave_effect.dart';
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
  late LanguageItem currentTargetLanguageItem = languageDatas.languageItems[4];

  bool isDropdownAnimating = false;



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
    _bluetoothControl.onDisposeBluetoothControl();

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
          title: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 35,),
                Text("banGawer", style: TextStyle(color: Colors.white, fontSize: 25),),
                Column(
                  children: [
                    bluetoothDeviceSelectBtn(context),
                  ],
                ),
              ],
            ),
          ),
          toolbarHeight: 90,
          backgroundColor: Colors.indigo[900],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height : 30, child: Container()),
              Expanded(
                  flex: 1, child: _translateFieldInput()),
              const SimpleSeparator(color: Colors.grey, height: 1, top: 0, bottom: 0),
              SizedBox(height : 30, child: _translatedTextDescriptions()),
              Expanded(
                flex: 1,
                child: _translateFieldOutput()),
              const SimpleSeparator(color: Colors.grey,height: 1, top: 5, bottom: 0),
              currentDeviceStateRamp(),
              SizedBox(
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(width: 20,),
                    _dropdownMenuInput(),
                    _dropdownMenuSwitchBtn(),
                    _dropdownMenuOutput(),
                    SizedBox(width: 20,),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SizedBox(height: 150, child: Align(alignment: Alignment.center, child: _audioRecordBtn(context))),
      ),
    );
  }


  Widget _dropdownMenuSwitchBtn() {
    return SizedBox(
      width: 25,
      height: 25,
      child: InkWell(

        onTap: (){
          _onClickedDropdownMenuSwitchBtn();
        },
        child: Image.asset('assets/exchange.png')
      ),
    );
  }

  _onClickedDropdownMenuSwitchBtn()
  {
    var tmp = currentSourceLanguageItem;
    currentSourceLanguageItem = currentTargetLanguageItem;
    currentTargetLanguageItem = tmp;

    onSelectedSourceDropdownMenuItem(currentSourceLanguageItem);
    onSelectedTargetDropdownMenuItem(currentTargetLanguageItem);
  }
  Widget _translatedTextDescriptions()
  {
    return Stack(
      children: [
        Positioned(left: 8, top: 8, child: _textToSpeechBtn()),
        Positioned(right : 8, top: 8, child: _translateToolField()),
      ]
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

  Widget _translateFieldInput() {
    return Consumer<SpeechToTextControl>(
      builder: (context, speech, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            readOnly: true,
            style: TextStyle(fontSize: 25),
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: inputTextEditController,
            decoration: InputDecoration(
              border : InputBorder.none,
              hintText: isRecording ? "" : "마이크 버튼을 눌러 번역할 내용을 말해보세요.",
              hintStyle: TextStyle(fontSize: 14),
            ),
          ),
        );
      },
    );
  }
  Widget _translateFieldOutput() {
    return Consumer<SpeechToTextControl>(
      builder: (context, speech, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            readOnly: true,
            style: TextStyle(fontSize: 25),
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: outputTextEditController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "",
            ),
          ),
        );
      },
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

  bool isRecording = false;
  Consumer<SpeechToTextControl> _audioRecordBtn(BuildContext context) {
    return Consumer<SpeechToTextControl>(
      // Positioned(left : 9, child: LoadingAnimationWidget.beat(size: 50, color: Colors.lightBlueAccent)),
      builder: (context, speechToTextControl, child) {
        return Stack(
          children: [
            RippleAnimation(
              color: Colors.indigoAccent,
              delay: const Duration(milliseconds: 200),
              repeat: true,
              minRadius: isRecording ? 35 : 0,
              ripplesCount: 6,
              duration: const Duration(milliseconds: 6 * 300),
              child:
              ElevatedButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(60, 60)),
                  shape: MaterialStateProperty.all(CircleBorder()),
                  backgroundColor: MaterialStateProperty.all(isRecording ? Colors.indigo : Colors.indigo),
                ),
                onPressed: onPressedAudioRecordBtn,
                child: isRecording ?
                LoadingAnimationWidget.staggeredDotsWave(size: 36, color: Colors.white) :
                Icon(Icons.mic, color:  Colors.white, size: 36,),
              ),
            ),
          ],
        );
      },
    );
  }


  // isRecording ? LoadingAnimationWidget.beat(size: 50, color: Colors.grey) : Container(width: 36, height: 36,),
  onPressedAudioRecordBtn() async{
    if (await ConnectivityWrapper.instance.isConnected) {
      bool hasPermission = await PermissionController.checkIfVoiceRecognitionPermisionGranted();
      if (!hasPermission) {
        PermissionController.showNoPermissionSnackBar(context);
      }
      else {
        print("devlog bluetooth state :  ${_bluetoothControl.flutterBlue.state}");
        if(_bluetoothControl.selectedDeviceForm == null) {
          await simpleAskDialog(context, "블루투스 기기 연결이 안되었습니다.", "블루투스 기기에 연결하시겠습니까?");
          onClickedOpenDeviceSelectScreen();
        }
        else{
          // simpleLoadingDialog(context, "디바이스 재연결중");
          // await _bluetoothControl.connectDevice(_bluetoothControl.selectedDeviceForm!, 3);
          // Navigator.of(context).pop();
          if(!isRecording)
          {
            isRecording = true;
            startListening();
          }
          else{
            isRecording = false;
            stopListening();
          }
          setState(() {});
        };
      }
    }
    else{
      showSimpleSnackBar(context, "인터넷 연결 안되었어요", 1);
    }
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
          isRecording = false;
          stopListening();
        }
      },
    ).then((value) async{
    }).onError((error, stackTrace) {
      print("error $error");
      isRecording = false;
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
      _onClickedTextToSpeechBtn();
      _onClickedDropdownMenuSwitchBtn();
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
        bool isModelDownloaded = await translateByGoogleDevice.getLanguageDownloaded(currentTargetLanguageItem.translateLanguage!);
        if(!isModelDownloaded)
        {
          bool? response = await simpleAskDialog(context, "서버 번역을 사용할수 없습니다.", "디바이스 번역을위해 언어를 다운로드하시겠습니까?");
          if(response! == true)
          {
            finalStr = await translateByGoogleDevice.textTranslate(inputStr);
          }
        }
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

    isDropdownAnimating = true;
    setState(() {
    });
  }
  onSelectedTargetDropdownMenuItem(LanguageItem languageItem){
    currentTargetLanguageItem = languageItem;
    translateByGoogleDevice.changeTranslateApiLanguage(currentSourceLanguageItem.translateLanguage, languageItem.translateLanguage);

    isDropdownAnimating = true;
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
      height: 50,
      child: Card(
        child: DropdownButton(
          isExpanded: true,
          alignment: Alignment.center,
          items: languageDatas.languageMenuItems,
          value: currentSourceLanguageItem.menuDisplayStr,
          onChanged: (value) async{
            LanguageItem languageItem = languageDatas.findLanguageItemByMenuDisplayStr(value!);
            setState(() {
            });
            onSelectedSourceDropdownMenuItem(languageItem);
          },
        ),
      ),
    );
  }
  Widget _dropdownMenuOutput() {
    return SizedBox(
      width: 100,
      height: 50,
      child: DropdownButton(
        isExpanded: true,
        items: languageDatas.languageMenuItems,
        value: currentTargetLanguageItem.menuDisplayStr,
        onChanged: (value) async{
          LanguageItem languageItem = languageDatas.findLanguageItemByMenuDisplayStr(value!);
          setState(() {
          });
          onSelectedTargetDropdownMenuItem(languageItem);
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
    return InkWell(
      child: Icon(Icons.bluetooth_searching, color: Colors.white, size: 25,),
      onTap: () async {
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
            BluetoothDeviceState deviceState;
            double iconSize = 20;
            if (snapshot.hasData) {
              deviceState = snapshot.data!;
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
              rampColor = Colors.transparent;
            }
            return IntrinsicWidth(
              child: Card(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, color: rampColor, size: iconSize,),
                    bluetoothControl.selectedDeviceForm != null ? Text("$deviceName  ", style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w400)): Text("Disconnected", style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
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
    simpleLoadingDialog(context, "블루투스 켜져있는지 확인중");
    _bluetoothControl.flutterBlue.state.listen((state) async {
      if (state == BluetoothState.off) {
        print("블루투스 켤게요");
        await simpleConfirmDialog(context, "블루투스 컴색을위해 블루투스를 켭니다", "message");
        simpleLoadingDialog(context, "블루투스를 켜는중");
        bool response = await _bluetoothControl.flutterBlue.turnOn();
        Navigator.of(context).pop();
      }
    });
    Navigator.of(context).pop();

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

