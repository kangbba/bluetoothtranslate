
import 'dart:async';
import 'package:bluetoothtranslate/bluetooth_control.dart';
import 'package:bluetoothtranslate/bluetooth_select_screen.dart';
import 'package:bluetoothtranslate/language_select_control.dart';
import 'package:bluetoothtranslate/language_select_screen.dart';
import 'package:bluetoothtranslate/permission_controller.dart';
import 'package:bluetoothtranslate/helper/simple_confirm_dialog.dart';
import 'package:bluetoothtranslate/helper/simple_separator.dart';
import 'package:bluetoothtranslate/speech_to_text_control.dart';
import 'package:bluetoothtranslate/statics/sizes.dart';
import 'package:bluetoothtranslate/speech_recognition_control.dart';
import 'package:bluetoothtranslate/apis/text_to_speech_control.dart';
import 'package:bluetoothtranslate/translate_control.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:speech_to_text/speech_to_text.dart';

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

  final SpeechToTextControl _speechToTextControl = SpeechToTextControl();
  final LanguageSelectControl _languageSelectControl = LanguageSelectControl();
  final SpeechRecognitionControl _speechRecognitionControl = SpeechRecognitionControl();
  final BluetoothControl _bluetoothControl = BluetoothControl();
  final TextToSpeechControl _textToSpeechControl = TextToSpeechControl();
  final TranslateControl _translateControl = TranslateControl();

  TextEditingController myTextEdit = TextEditingController();
  TextEditingController yourTextEdit = TextEditingController();


  Color yourMainColor = Colors.blueGrey[800]!;
  Color myMainColor = Colors.cyan[800]!;



  @override
  void initState() {
    super.initState();
    _languageSelectControl.initializeLanguageSelectControl();
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
        ListenableProvider<LanguageSelectControl>(
          create: (_) => _languageSelectControl,
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
                    SizedBox(height: 130, child: _audioRecordBtn(context, ActingOwner.you, _languageSelectControl)),
                    SizedBox(height: 95, child: Align(alignment : Alignment.topCenter, child: _dropdownMenuSwitchBtn())),
                    SizedBox(height: 130, child: _audioRecordBtn(context, ActingOwner.me, _languageSelectControl)),
                  ],
                )),
          ],
        ),
        bottomNavigationBar: Container(height : 40 ),

      ),
    );
  }

  Widget _dropdownMenuSwitchBtn() {
    return SizedBox(
      width: 30,
      height: 30,
      child: InkWell(
          onTap: (){
            onClickedDropdownMenuSwitchBtn();
          },
          child: Image.asset('assets/exchange.png')
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
  Widget _audioRecordBtn(BuildContext context, ActingOwner recordBtnOwner, LanguageSelectControl languageSelectControl) {
    bool isRecordingAndMatchWithTurn = recordBtnOwner == _nowActingOwner;
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          recordBtnOwner == ActingOwner.me ? languageSelectScreenBtn(true) : languageSelectScreenBtn(false),

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
                    backgroundColor: MaterialStateProperty.all(recordBtnOwner == ActingOwner.me ? Colors.cyan[800] :  Colors.blueGrey[500]),
                  ),
                  onPressed: (){
                    onPressedAudioRecordBtn(recordBtnOwner, languageSelectControl);
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
  onPressedAudioRecordBtn(ActingOwner recordBtnOwner, LanguageSelectControl languageSelectControl) async {
    _isMicNotTouched = false;
    if(_nowActingOwner != ActingOwner.neutral &&  _nowActingOwner != recordBtnOwner)
    {
      print("마이크의 주인이 아닌 사람이 무언가 하고있습니다");
      return;
    }
    bool isRecordBtnOwnerIsMe = recordBtnOwner == ActingOwner.me;
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
      print("${isRecordBtnOwnerIsMe? "내쪽" : "상대쪽"} 마이크 켬");
      _isAudioRecordBtnPressed = true;
      LanguageItem fromLanguageItem = isRecordBtnOwnerIsMe ? languageSelectControl.nowMyLanguageItem : languageSelectControl.nowYourLanguageItem;
      LanguageItem toLanguageItem =  isRecordBtnOwnerIsMe ? languageSelectControl.nowYourLanguageItem : languageSelectControl.nowMyLanguageItem;
      startActingRoutine(recordBtnOwner, fromLanguageItem, toLanguageItem, languageSelectControl);
    }
    else{
      print("${isRecordBtnOwnerIsMe? "내쪽" : "상대쪽"} 마이크 끔");

      _isAudioRecordBtnPressed = false;
      LanguageItem fromLanguageItem = isRecordBtnOwnerIsMe ? languageSelectControl.nowMyLanguageItem : languageSelectControl.nowYourLanguageItem;
      LanguageItem toLanguageItem =  isRecordBtnOwnerIsMe ? languageSelectControl.nowYourLanguageItem : languageSelectControl.nowMyLanguageItem;
      stopActingRoutine();
    }
    setState(() {});
  }
  stopActingRoutine() async{
    print("-----------------------루틴끝 stopActingRoutine------------------------");
    _nowActingStatus = ActingStatus.none;
    _nowActingOwner = ActingOwner.neutral;
  }
  startActingRoutine(ActingOwner recordBtnOwner, LanguageItem fromLanguageItem, LanguageItem toLanguageItem, LanguageSelectControl languageSelectControl) async
  {
      //1. setting
    stopActingRoutine();
    print("-----------------------루틴시작 startActingRoutine------------------------");
    _nowActingOwner = recordBtnOwner;
    myTextEdit.text = '';
    yourTextEdit.text = '';

    //2. speech to original text
    print("-----------------------음성녹음 ActingStatus.recording------------------------");
    _nowActingStatus = ActingStatus.recording;
    String fromWords = await listeningRoutine(fromLanguageItem.speechLocaleId!, recordBtnOwner, languageSelectControl);
    // String fromWords = await listeningRoutine_speechToText(fromLanguageItem.speechLocaleId!, isMyRecordBtn);
    if(fromWords.isEmpty) {
      print("아무 말도 녹음되지 않았습니다");
      stopActingRoutine();
      return;
    }
    //3. original text to translated text
    print("-----------------------번역 ActingStatus.translating------------------------");
    _nowActingStatus = ActingStatus.translating;
    String? toWords = await _translateControl.translateByAvailableTranslateTools(fromWords, fromLanguageItem, toLanguageItem, 2000);
    setState(() {
    });

    if(toWords == null)
    {
      print("번역 기능에서 오류가 발생한듯 합니다");
      stopActingRoutine();

      await simpleConfirmDialog(context, "서버가 불안정합니다. 잠시후 시도해보세요", "OK");
      myTextEdit.text ='';
      yourTextEdit.text ='';

      return;
    }
    if(toWords!.isEmpty) {
      print("아무 말도 번역되지 않았습니다");
      stopActingRoutine();
      return;
    }
    TextEditingController properControllerToTranslatedWords = recordBtnOwner == ActingOwner.me ? yourTextEdit : myTextEdit;
    properControllerToTranslatedWords.text = toWords;

    //speech service
    _textToSpeechControl.changeLanguage(toLanguageItem.speechLocaleId!);
    _textToSpeechControl.speak(toWords);

    print("-----------------------디바이스전송 ActingStatus.deviceSending------------------------");

    //5. send to device
    _nowActingStatus = ActingStatus.deviceSending;
    BluetoothDevice? targetDevice = await _bluetoothControl.getValidDevice();
    if(targetDevice == null)
    {
      print("타겟디바이스가 없습니다");
      stopActingRoutine();
      return;
    }
    BluetoothDeviceState state = await targetDevice!.state.first;
    if(state != BluetoothDeviceState.connected)
    {
      print("타겟디바이스의 연결이 끊겨있습니다.");
      stopActingRoutine();
      return;
    }
    if(recordBtnOwner == ActingOwner.me)
    {
      String fullMsg = _bluetoothControl.getFullMsg(toLanguageItem, toWords);
      print("내가 말했을때 디바이스표시 : $fullMsg");
      await _bluetoothControl.sendMessageToSelectedDevice(targetDevice!, fullMsg);
      setState(() {
      });
    }
    else{
      String fullMsg = _bluetoothControl.getFullMsg(fromLanguageItem, fromWords);
      print("외국인이 대답했을때 디바이스표시 : $fullMsg");
      await _bluetoothControl.sendMessageToSelectedDevice(targetDevice!, fullMsg);
      setState(() {
      });
    }
    //6. finish
    stopActingRoutine();
  }
  listeningRoutine(String speechLocaleID, ActingOwner recordBtnOwner, languageSelectControl) async {
    _speechRecognitionControl.transcription = '';
    _speechRecognitionControl.start(speechLocaleID);
    _speechRecognitionControl.isCompleted = false;
    TextEditingController properControllerToTranslatedWords = recordBtnOwner == ActingOwner.me ? myTextEdit  : yourTextEdit;
    while (true) {
      // if(!_speechToTextControl.speechToText.isListening)
      properControllerToTranslatedWords.text = _speechRecognitionControl.transcription;
      await Future.delayed(Duration(milliseconds: 1));
      if(recordBtnOwner != _nowActingOwner)
      {
        print("진입 당시 acting owner 와 상황이 달라져서 listening routine 탈출.. ");
        break;
      }
      if(_speechRecognitionControl.isCompleted)
      {
        await Future.delayed(Duration(milliseconds: 500));
        properControllerToTranslatedWords.text = _speechRecognitionControl.transcription;
        print("_speechRecognitionControl.isListening가 false이기 때문에 listening routine 탈출..");
        print(_speechRecognitionControl.transcription);
        onPressedAudioRecordBtn(recordBtnOwner, languageSelectControl);
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




  //TODO : 블루투스 관련 기능
  Widget bluetoothDeviceSelectBtn(BuildContext context) {
    return SizedBox(
        child: Consumer<BluetoothControl>(
          builder: (context, bluetoothControl, _) {
            Color rampColor = bluetoothControl.validDevice != null ? Colors.green : Colors.red;
            String desc = bluetoothControl.validDevice != null ? bluetoothControl.validDevice!.name : "disconnected";
            return InkWell(
              onTap: (){
                onClickedOpenDeviceSelectScreen(bluetoothControl);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.circle, color: rampColor, size: 15,),
                  const SizedBox(width: 5,),
                  Text(desc, style: TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(width: 12,),
                ],
              ),
            );
          },
        )
    );
  }






  onClickedOpenDeviceSelectScreen(BluetoothControl bluetoothControl) async{
    bool hasPermission = await PermissionController.checkIfBluetoothPermissionsGranted();
    if (!hasPermission) {
      print("권한에 문제가있음");
      return;
    }
    bool bluetoothTurnOn = await bluetoothControl.isBluetoothTurnOn();
    if(!bluetoothTurnOn)
    {
      bool response = await bluetoothControl.bluetoothTurnOnDialog(context);
      if(!response)
      {
        return;
      }
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0),
              child: BluetoothSelectScreen(bluetoothControl : bluetoothControl),
            ),

          );
        }).then((result) {
      // BluetoothSelectScreen 위젯이 닫혔을 때 처리할 로직 작성
      print("돌아왔다!");
      setState(() {

      });
    });
  }
  Widget languageSelectScreenBtn(bool isMine) {
    return Consumer<LanguageSelectControl>(
      builder: (context, languageSelectControl, child) {
        return InkWell(
          onTap: () {
            late LanguageSelectScreen myLanguageSelectScreen =
            LanguageSelectScreen(
              isMine: true,
              languageSelectControl: languageSelectControl,
            );
            late LanguageSelectScreen yourLanguageSelectScreen =
            LanguageSelectScreen(
              isMine: false,
              languageSelectControl: languageSelectControl,
            );
            var selectedLanguageScreen =
            isMine ? myLanguageSelectScreen : yourLanguageSelectScreen;

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16.0),
                    child: selectedLanguageScreen,
                  ),
                );
              },
            );
          },
          child: SizedBox(
            width: 130,
            height: 30,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "${isMine ? languageSelectControl.nowMyLanguageItem.menuDisplayStr : languageSelectControl.nowYourLanguageItem.menuDisplayStr}",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
        );
      },
    );
  }

  onClickedDropdownMenuSwitchBtn()
  {
    var tmp = _languageSelectControl.nowMyLanguageItem ;
    _languageSelectControl.nowMyLanguageItem = _languageSelectControl.nowYourLanguageItem;
    _languageSelectControl.nowYourLanguageItem = tmp;
  }
}