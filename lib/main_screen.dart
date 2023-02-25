
import 'dart:async';
import 'package:bluetoothtranslate/bluetooth_control.dart';
import 'package:bluetoothtranslate/permission_controller.dart';
import 'package:bluetoothtranslate/helper/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/helper/simple_separator.dart';
import 'package:bluetoothtranslate/statics/sizes.dart';
import 'package:bluetoothtranslate/speech_recognition_control.dart';
import 'package:bluetoothtranslate/apis/text_to_speech_control.dart';
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

  MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}
enum ActingOwner
{
  me,
  neutral,
  you
}
enum ActingStatus
{
  none,
  recording,
  translating,
  deviceSending
}
class _MainScreenState extends State<MainScreen> {

  bool _isAudioRecordBtnPressed = false;
  bool _isMicNotTouched = true;

  ActingStatus _nowActingStatus = ActingStatus.none;
  ActingOwner _nowActingOwner = ActingOwner.neutral;

  final SpeechRecognitionControl _speechRecognitionControl = SpeechRecognitionControl();
  final LanguageDatas _languageDatas = LanguageDatas();
  final BluetoothControl _bluetoothControl = BluetoothControl();
  final TextToSpeechControl _textToSpeechControl = TextToSpeechControl();
  final TranslateControl _translateControl = TranslateControl();

  TextEditingController myTextEdit = TextEditingController();
  TextEditingController yourTextEdit = TextEditingController();


  Color yourMainColor = Colors.blueGrey[800]!;
  Color myMainColor = Colors.cyan[800]!;


  late LanguageItem nowMyLanguageItem = _languageDatas.languageItems[11];
  late LanguageItem nowYourLanguageItem = _languageDatas.languageItems[0];

  @override
  void initState() {
    super.initState();

    _languageDatas.initializeLanguageDatas();
    _bluetoothControl.initializeBluetoothControl();
    _speechRecognitionControl.activateSpeechRecognizer();
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
        ListenableProvider<SpeechRecognitionControl>(
          create: (_) => _speechRecognitionControl,
        ),
        ListenableProvider<BluetoothControl>(
          create: (_) => _bluetoothControl,
        ),
      ],
      child: Scaffold(
        appBar: _myAppBar(context),
        body: Column(
          children: [
            const SimpleSeparator(color: Colors.grey, height: 0.3, top: 0, bottom: 0),
            Expanded(
                flex: 4, child: translateAreaField(true)),
            const SimpleSeparator(color: Colors.grey, height: 0.3, top: 0, bottom: 0),
            // SizedBox(height : 30, child: _translatedTextDescriptions()),
            Expanded(
              flex: 4,
              child: translateAreaField(false)),
            const SimpleSeparator(color: Colors.grey, height: 0.3, top: 0, bottom: 16),
            SizedBox(
              height: 130,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: 130, child: _audioRecordBtn(context, false)),
                    SizedBox(height: 95, child: Align(alignment : Alignment.topCenter, child: _dropdownMenuSwitchBtn())),
                    SizedBox(height: 130, child: _audioRecordBtn(context, true)),
                  ],
                )),
          ],
        ),
        bottomNavigationBar: Container(height : 40 ),

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
              "",
              style: TextStyle(fontSize: 22, color: Colors.grey[200]),
            ),
          ],
        ),
        actions: [bluetoothDeviceSelectBtn(context)],
        backgroundColor: Colors.blueGrey[100],
      shadowColor: Colors.transparent,
      toolbarHeight: 40,

      );
  }


  Widget _dropdownMenuSwitchBtn() {
    return SizedBox(
      width: 30,
      height: 30,
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
    setState(() {

    });
  }
  Widget translateAreaField(bool isMine) {
    Widget loadingWidget;
    if(isMine && _nowActingOwner == ActingOwner.you && _nowActingStatus == ActingStatus.translating)
    {
      loadingWidget = LoadingAnimationWidget.prograssiveDots(color: Colors.indigo, size: 25);
    }
    else if(!isMine && _nowActingOwner == ActingOwner.me && _nowActingStatus == ActingStatus.translating){
      loadingWidget = LoadingAnimationWidget.prograssiveDots(color: Colors.indigo, size: 25);
    }
    else{
      loadingWidget = Container();
    }
    return Container(
      alignment: Alignment.center,
      color: isMine ? Colors.white70 : Colors.white70,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: loadingWidget
            ),
            Align(
              alignment: Alignment.center,
              child: TextField(
                readOnly: true,
                style: TextStyle(fontSize: 24, color: isMine ? myMainColor : yourMainColor),
                maxLines: 5,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.multiline,
                controller: isMine ? myTextEdit : yourTextEdit,
                decoration: InputDecoration(
                  border : InputBorder.none,
                  hintText:  _isMicNotTouched && isMine ? "마이크 버튼을 눌러 번역할 내용을 말해보세요." : null,
                  hintStyle: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _audioRecordBtn(BuildContext context, bool isMyRecordBtn) {
    bool isRecordingAndMatchWithTurn = (isMyRecordBtn && _nowActingOwner == ActingOwner.me && _nowActingStatus == ActingStatus.recording)
        || (!isMyRecordBtn && _nowActingOwner == ActingOwner.you &&  _nowActingStatus == ActingStatus.recording);
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          isMyRecordBtn ? _dropdownMenu(true) : _dropdownMenu(false),
          Stack(
            children: [
              RippleAnimation(
                color: Colors.blue,
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
                    backgroundColor: MaterialStateProperty.all(isMyRecordBtn ? Colors.cyan[800] :  Colors.blueGrey[500]),
                  ),
                  onPressed: (){
                    onPressedAudioRecordBtn(isMyRecordBtn);
                  },
                  child: isRecordingAndMatchWithTurn ? LoadingAnimationWidget.staggeredDotsWave(size: 33, color: Colors.white) :
                  Icon(Icons.mic, color:  Colors.white, size: 33,),
                ),
              ),
            ],
          )
        ],
      );
  }


  // isRecording ? LoadingAnimationWidget.beat(size: 50, color: Colors.grey) : Container(width: 36, height: 36,),
  onPressedAudioRecordBtn(bool isMyRecordBtn) async {
    _isMicNotTouched = false;
    if(_nowActingOwner != ActingOwner.neutral && _nowActingOwner != (isMyRecordBtn ? ActingOwner.me : ActingOwner.you))
    {
      print("상대방이 다른행동을하고있습니다");
      return;
    }
    if(!_isAudioRecordBtnPressed)
    {
      if(_nowActingStatus != ActingStatus.none){
        print("이미 무언가 하고있습니다.");
        return;
      }
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
      print("${isMyRecordBtn? "내쪽" : "상대쪽"} 마이크 켬");
      _isAudioRecordBtnPressed = true;
      LanguageItem fromLanguageItem = isMyRecordBtn ? nowMyLanguageItem : nowYourLanguageItem;
      LanguageItem toLanguageItem =  isMyRecordBtn ? nowYourLanguageItem : nowMyLanguageItem;
      startActingRoutine(isMyRecordBtn, fromLanguageItem, toLanguageItem);
    }
    else{
      print("${isMyRecordBtn? "내쪽" : "상대쪽"} 마이크 끔");

      _isAudioRecordBtnPressed = false;
      LanguageItem fromLanguageItem = isMyRecordBtn ? nowMyLanguageItem : nowYourLanguageItem;
      LanguageItem toLanguageItem =  isMyRecordBtn ? nowYourLanguageItem : nowMyLanguageItem;
    }
    setState(() {});
  }
  stopActingRoutine() async{
    print("-----------------------루틴끝 stopActingRoutine------------------------");
    _nowActingStatus = ActingStatus.none;
    _nowActingOwner = ActingOwner.neutral;
  }
  listeningRoutine(String speechLocaleID, bool isMyRecordBtn) async {
    _speechRecognitionControl.transcription = '';
    _speechRecognitionControl.start(speechLocaleID);
    _speechRecognitionControl.isCompleted = false;
    TextEditingController properControllerToTranslatedWords = isMyRecordBtn ? myTextEdit  : yourTextEdit;
    while (true) {
      // if(!_speechToTextControl.speechToText.isListening)
      properControllerToTranslatedWords.text = _speechRecognitionControl.transcription;
      await Future.delayed(Duration(milliseconds: 1));
      if(_speechRecognitionControl.isCompleted)
      {
        await Future.delayed(Duration(milliseconds: 500));
        properControllerToTranslatedWords.text = _speechRecognitionControl.transcription;
        print("_speechRecognitionControl.isListening가 false이기 때문에 listening routine 탈출..");
        print(_speechRecognitionControl.transcription);
        onPressedAudioRecordBtn(isMyRecordBtn);
        break;
      }
      if (!_isAudioRecordBtnPressed) {
        print("마이크를 사용자가 껐기 때문에 listening routine 탈출..");
        _speechRecognitionControl.stop();
        break;
      }

    }
    properControllerToTranslatedWords.text = _speechRecognitionControl.transcription;
    return _speechRecognitionControl.transcription;
  }
  startActingRoutine(bool isMyRecordBtn, LanguageItem fromLanguageItem, LanguageItem toLanguageItem) async
  {
      //1. setting
    stopActingRoutine();
    print("-----------------------루틴시작 startActingRoutine------------------------");
    _nowActingOwner = isMyRecordBtn ? ActingOwner.me : ActingOwner.you;
    myTextEdit.text = '';
    yourTextEdit.text = '';

    //2. speech to original text
    print("-----------------------음성녹음 ActingStatus.recording------------------------");
    _nowActingStatus = ActingStatus.recording;
    String fromWords = await listeningRoutine(fromLanguageItem.speechLocaleId!, isMyRecordBtn);
    // String fromWords = await listeningRoutine_speechToText(fromLanguageItem.speechLocaleId!, isMyRecordBtn);
    if(fromWords.isEmpty) {
      print("아무 말도 녹음되지 않았습니다");
      stopActingRoutine();
      return;
    }
    //3. original text to translated text
    print("-----------------------번역 ActingStatus.translating------------------------");
    _nowActingStatus = ActingStatus.translating;
    String toWords = await _translateControl.translateByAvailableTranslateTools(fromWords, fromLanguageItem, toLanguageItem);
    if(toWords.isEmpty) {
      print("아무 말도 번역되지 않았습니다");
      stopActingRoutine();
      return;
    }
    TextEditingController properControllerToTranslatedWords = isMyRecordBtn ? yourTextEdit : myTextEdit;
    properControllerToTranslatedWords.text = toWords;

    print("-----------------------디바이스전송 ActingStatus.deviceSending------------------------");
    //5. send to device
    _nowActingStatus = ActingStatus.deviceSending;
    //speech service
    _textToSpeechControl.changeLanguage(toLanguageItem.speechLocaleId!);
    _textToSpeechControl.speak(toWords);
    if(isMyRecordBtn)
    {
      String fullMsg = _bluetoothControl.getFullMsg(toLanguageItem, toWords);
      print("내가 말했을때 디바이스표시 : $fullMsg");
      await _bluetoothControl.sendMessageToSelectedDevice(fullMsg);
      setState(() {
      });
    }
    else{
      String fullMsg = _bluetoothControl.getFullMsg(fromLanguageItem, fromWords);
      print("외국인이 대답했을때 디바이스표시 : $fullMsg");
      await _bluetoothControl.sendMessageToSelectedDevice(fullMsg);
      setState(() {
      });
    }
    //6. finish
    stopActingRoutine();
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

  Widget _dropdownMenu(bool isMyDropdownMenu) {
    return SizedBox(
      width: 125,
      height: 45,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: DropdownButton(
          isExpanded: true,
          underline: Container(),
          alignment: Alignment.centerLeft,

          items: _languageDatas.languageMenuItems,
          value: isMyDropdownMenu ? nowMyLanguageItem.menuDisplayStr : nowYourLanguageItem.menuDisplayStr,
          onChanged: (value) async{
            LanguageItem languageItem = _languageDatas.findLanguageItemByMenuDisplayStr(value!);
            if(isMyDropdownMenu){
              nowMyLanguageItem = languageItem;
            }
            else{
              nowYourLanguageItem = languageItem;
            }
            setState(() {
            });
          },
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
                      Text(ment, style: TextStyle(fontSize: 14, color: Colors.black87)),
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