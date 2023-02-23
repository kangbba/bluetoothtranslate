
import 'dart:async';
import 'package:bluetoothtranslate/bluetooth_control.dart';
import 'package:bluetoothtranslate/permission_controller.dart';
import 'package:bluetoothtranslate/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/simple_separator.dart';
import 'package:bluetoothtranslate/sizes.dart';
import 'package:bluetoothtranslate/speech_to_text_control.dart';
import 'package:bluetoothtranslate/text_to_speech_control.dart';
import 'package:bluetoothtranslate/translate_control.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'device_select_screen.dart';
import 'language_datas.dart';

class MainScreen extends StatefulWidget {

  final SharedPreferences prefs;
  MainScreen({required this.prefs});

  @override
  _MainScreenState createState() => _MainScreenState();
}
enum RecordingTurnState
{
  myTurn,
  neutral,
  yourTurn
}
class _MainScreenState extends State<MainScreen> {

  RecordingTurnState _recordingTurnState = RecordingTurnState.neutral;
  bool _isAudioRecording = false;

  final LanguageDatas _languageDatas = LanguageDatas();
  final BluetoothControl _bluetoothControl = BluetoothControl();
  final SpeechToTextControl _speechToTextControl = SpeechToTextControl();
  final TextToSpeechControl _textToSpeechControl = TextToSpeechControl();
  final TranslateControl _translateControl = TranslateControl();

  TextEditingController myTextEdit = TextEditingController();
  TextEditingController yourTextEdit = TextEditingController();


  late LanguageItem nowMyLanguageItem = _languageDatas.languageItems[11];
  late LanguageItem nowYourLanguageItem = _languageDatas.languageItems[0];

  @override
  void initState() {
    super.initState();

    _languageDatas.initializeLanguageDatas();
    _bluetoothControl.initializeBluetoothControl();
    _speechToTextControl.initSpeechToText();
    _textToSpeechControl.initTextToSpeech();
    _translateControl.initializeTranslateControl();
  }
  @override
  void dispose() {

    // TODO: implement dispose
    myTextEdit.dispose();
    yourTextEdit.dispose();
    _bluetoothControl.onDisposeBluetoothControl();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return MultiProvider(
      providers: [
        ListenableProvider<SpeechToTextControl>(
          create: (_) => _speechToTextControl,
        ),
        ListenableProvider<BluetoothControl>(
          create: (_) => _bluetoothControl,
        ),
      ],
      child: Scaffold(
        appBar: _myAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height : 10, child: Container()),
              Expanded(
                  flex: 3, child: yourTranslateField()),
              const SimpleSeparator(color: Colors.grey, height: 1, top: 0, bottom: 0),
              // SizedBox(height : 30, child: _translatedTextDescriptions()),
              Expanded(
                flex: 3,
                child: myTranslateField()),
              const SimpleSeparator(color: Colors.grey,height: 1, top: 0, bottom: 16),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 14,),
                    _dropdownMenuSwitchBtn(),
                    SizedBox(width: 14,),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 125, child: _audioRecordBtn(context, true)),
            SizedBox(height: 125, child: _audioRecordBtn(context, false)),
          ],
        ),
      ),
    );
  }

  AppBar _myAppBar(BuildContext context) {
    return AppBar(
        leadingWidth: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "banGawer",
              style: TextStyle(fontSize: 22),
            ),
          ],
        ),
        actions: [bluetoothDeviceSelectBtn(context)],
        backgroundColor: Colors.indigo[900],

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
    var tmp = nowMyLanguageItem;
    nowMyLanguageItem = nowYourLanguageItem;
    nowYourLanguageItem = tmp;
  }
  Widget myTranslateField() {
    return Consumer<SpeechToTextControl>(
      builder: (context, speech, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            readOnly: true,
            style: TextStyle(fontSize: 18),
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: myTextEdit,
            decoration: InputDecoration(
              border : InputBorder.none,
              // hintText: _isAudioRecording ? null : "마이크 버튼을 눌러 번역할 내용을 말해보세요.",
              hintStyle: TextStyle(fontSize: 11),
            ),
          ),
        );
      },
    );
  }
  Widget yourTranslateField() {
    return Consumer<SpeechToTextControl>(
      builder: (context, speech, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            readOnly: true,
            style: TextStyle(fontSize: 18),
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            controller: yourTextEdit,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "",
            ),
          ),
        );
      },
    );
  }


  Widget _audioRecordBtn(BuildContext context, bool isMyRecordBtn) {
    bool isRecordingAndMatchWithTurn = (isMyRecordBtn && _recordingTurnState == RecordingTurnState.myTurn) || (!isMyRecordBtn && _recordingTurnState == RecordingTurnState.yourTurn);
      return Column(
        children: [
          Stack(
            children: [
              RippleAnimation(
                color: Colors.indigoAccent,
                delay: const Duration(milliseconds: 200),
                repeat: true,
                minRadius: isRecordingAndMatchWithTurn ? 35 : 0,
                ripplesCount: 6,
                duration: const Duration(milliseconds: 6 * 300),
                child:
                ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(55, 55)),
                    shape: MaterialStateProperty.all(CircleBorder()),
                    backgroundColor: MaterialStateProperty.all(isMyRecordBtn ? Colors.indigo : Colors.grey),
                  ),
                  onPressed: (){
                    onPressedAudioRecordBtn(isMyRecordBtn);
                  },
                  child: isRecordingAndMatchWithTurn ? LoadingAnimationWidget.staggeredDotsWave(size: 33, color: Colors.white) :
                  Icon(Icons.mic, color:  Colors.white, size: 33,),
                ),
              ),
            ],
          ),
          isMyRecordBtn ? _myDropdownMenu() : _yourDropdownMenu(),
        ],
      );
  }


  // isRecording ? LoadingAnimationWidget.beat(size: 50, color: Colors.grey) : Container(width: 36, height: 36,),
  onPressedAudioRecordBtn(bool isMyRecordBtn) async {
    if(!_isAudioRecording)
    {
      print("${isMyRecordBtn? "내쪽" : "상대쪽"} 마이크 켬");
      bool hasPermission = await PermissionController.checkIfVoiceRecognitionPermisionGranted();
      if (!hasPermission) {
        PermissionController.showNoPermissionSnackBar(context);
        return;
      }
      bool isInternetConnected = await ConnectivityWrapper.instance.isConnected;
      if (!isInternetConnected) {
        await simpleConfirmDialog(context, "인터넷 연결이 필요합니다!", "확인");
        //todo 인터넷연결안됨 처리.
        return;
      }

      _recordingTurnState = isMyRecordBtn ? RecordingTurnState.myTurn : RecordingTurnState.yourTurn;
      _isAudioRecording = true;
      LanguageItem fromLanguageItem = isMyRecordBtn ? nowMyLanguageItem : nowYourLanguageItem;
      LanguageItem toLanguageItem =  isMyRecordBtn ? nowYourLanguageItem : nowMyLanguageItem;
      startTranslateRoutine(isMyRecordBtn, fromLanguageItem, toLanguageItem);
    }
    else{
      print("${isMyRecordBtn? "내쪽" : "상대쪽"} 마이크 끔");
      _recordingTurnState = RecordingTurnState.neutral;
      _isAudioRecording = false;
      LanguageItem fromLanguageItem = isMyRecordBtn ? nowMyLanguageItem : nowYourLanguageItem;
      LanguageItem toLanguageItem =  isMyRecordBtn ? nowYourLanguageItem : nowMyLanguageItem;
      stopTranslateRoutine();
    }
    setState(() {});
  }
  stopTranslateRoutine()
  {

}
listeningRoutine(String speechLocaleID, bool isMyRecordBtn) async {
  _speechToTextControl.recentRecognizedWords = '';
  _speechToTextControl.isFinalResultReturned = false;
  _speechToTextControl.stopListening();
  TextEditingController properControllerToTranslatedWords = isMyRecordBtn ? myTextEdit  : yourTextEdit;
  while (true) {
    // if(!_speechToTextControl.speechToText.isListening)
    if(!_speechToTextControl.isFinalResultReturned && !_speechToTextControl.speechToText.isListening)
    {
      print("강제로 _speechToTextControl 재시작합니다");
      _speechToTextControl.startListening(speechLocaleID);
    }
    await Future.delayed(Duration(milliseconds: 1));

    properControllerToTranslatedWords.text = _speechToTextControl.recentRecognizedWords;
    // if (!_isAudioRecording) {
    print("listening routine 작동중.. ${_speechToTextControl.speechToText.isListening}");
    if(_speechToTextControl.isFinalResultReturned)
    {
      print("_speechToTextControl가 finalResult를 반환했기때문에 listening routine 탈출..");
      _speechToTextControl.stopListening();
      _speechToTextControl.isFinalResultReturned = false;
      onPressedAudioRecordBtn(isMyRecordBtn);
      break;
    }
    if (!_isAudioRecording) {
      print("마이크를 사용자가 껐기 때문에 listening routine 탈출..");
      break;
    }
  }
  return _speechToTextControl.recentRecognizedWords;
}
startTranslateRoutine(bool isMyRecordBtn, LanguageItem fromLanguageItem, LanguageItem toLanguageItem) async
  {
      //1. setting
      myTextEdit.text = '';
      yourTextEdit.text = '';

      //2. speech to original text
      _speechToTextControl.recentRecognizedWords = '';
      String fromWords = await listeningRoutine(fromLanguageItem.speechLocaleId!, isMyRecordBtn);
      if(fromWords.isEmpty) {
        print("아무 말도 녹음되지 않았습니다");
        return;
      }
      //3. original text to translated text
      String toWords = await _translateControl.translateByAvailableTranslateTools(fromWords, fromLanguageItem, toLanguageItem);
      if(toWords.isEmpty) {
        print("아무 말도 번역되지 않았습니다");
        return;
      }
      TextEditingController properControllerToTranslatedWords = isMyRecordBtn ? yourTextEdit : myTextEdit;
      properControllerToTranslatedWords.text = toWords;

      //4. translated text to speech
      _textToSpeechControl.changeLanguage(toLanguageItem.speechLocaleId!);
      _textToSpeechControl.speak(toWords);

      //5. send to device
      if(isMyRecordBtn)
      {
        String fullMsg = _bluetoothControl.getFullMsg(toLanguageItem, toWords);
        await _bluetoothControl.sendMessageToSelectedDevice(fullMsg);
        setState(() {
        });
      }
      //6. finish

  }


  onSelectedMyLanguageItem(LanguageItem languageItem) {
    nowMyLanguageItem = languageItem;
    setState(() {
    });
  }
  onSelectedYourLanguageItem(LanguageItem languageItem){
    nowYourLanguageItem = languageItem;
    setState(() {
    });
  }

  Widget _myDropdownMenu() {
    return Card(
      child: SizedBox(
        width: 130,
        height: 45,
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: DropdownButton(
            isExpanded: true,
            underline: Container(),

            items: _languageDatas.languageMenuItems,
            value: nowMyLanguageItem.menuDisplayStr,
            onChanged: (value) async{
              LanguageItem languageItem = _languageDatas.findLanguageItemByMenuDisplayStr(value!);
              nowMyLanguageItem = languageItem;
              setState(() {
              });
            },
          ),
        ),
      ),
    );
  }
  Widget _yourDropdownMenu() {
    return Card(
      child: SizedBox(
        width: 130,
        height: 45,
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: DropdownButton(
            isExpanded: true,
            underline: Container(),
            items: _languageDatas.languageMenuItems,
            value: nowYourLanguageItem.menuDisplayStr,
            onChanged: (value) async{
              LanguageItem languageItem = _languageDatas.findLanguageItemByMenuDisplayStr(value!);
              nowYourLanguageItem = languageItem;
              setState(() {
              });
            },
          ),
        ),
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


  //TODO : 블루투스 관련 기능
  Widget bluetoothDeviceSelectBtn(BuildContext context) {
    return SizedBox(
      child: InkWell(
        child: Consumer<BluetoothControl>(
          builder: (context, bluetoothControl, _) {
            return FutureBuilder<bool>(
                future: bluetoothControl.checkIfRecentDeviceReadyToSend(),
                builder: (context, snapshot) {
                  Color rampColor;
                  String ment = "";
                  if(snapshot.hasData && bluetoothControl.recentBluetoothDevice != null)
                  {
                    bool readyToSend = snapshot.data!;
                    rampColor = readyToSend ? Colors.lightGreenAccent : Colors.red;
                    //recentBluetoothDevice! 가 null이면 보나마나 checkIfReadyToSendDevice 이 false를 뱉게 해두었기 떄문.
                    ment = readyToSend ? bluetoothControl.recentBluetoothDevice!.name : "Disconnected";
                  }
                  else{
                    ment = "Disconnected";
                    rampColor = Colors.orange;
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.circle, color: rampColor, size: 15,),
                      SizedBox(width: 5,),
                      Text(ment, style: TextStyle(fontSize: 14, color: Colors.white)),
                      SizedBox(width: 12,),
                    ],
                  );
                }
            );
          },
        ),
        onTap: () async {
          await onClickedOpenDeviceSelectScreen();
        },
      ),
    );
  }

  onClickedOpenDeviceSelectScreen() async{
    bool hasPermission = await PermissionController.checkIfBluetoothPermissionsGranted();
    if (!hasPermission) {
      print("권한에 문제가있음");
      return;
    }
    bool bluetoothTurnOn = await _bluetoothControl.isBluetoothTurnOn();
    if(!bluetoothTurnOn)
    {
      bool response = await _bluetoothControl.bluetoothTurnOnDialog(context);
      if(!response)
      {
        return;
      }
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