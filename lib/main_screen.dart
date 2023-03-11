
import 'dart:async';
import 'package:bluetoothtranslate/bluetooth_control.dart';
import 'package:bluetoothtranslate/bluetooth_select_screen.dart';
import 'package:bluetoothtranslate/helper/simple_loading_dialog.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:lecle_volume_flutter/lecle_volume_flutter.dart';
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
class _MainScreenState extends State<MainScreen>  with WidgetsBindingObserver {

  bool isBeforeResume = true;
  bool _isMicNotTouched = true;

  ActingStatus _nowActingStatus = ActingStatus.none;
  ActingOwner _nowRecordBtnOwner = ActingOwner.neutral;

  final SpeechToTextControl _speechToTextControl = SpeechToTextControl();
  final LanguageSelectControl _languageSelectControl = LanguageSelectControl();
  final BluetoothControl _bluetoothControl = BluetoothControl();
  final TextToSpeechControl _textToSpeechControl = TextToSpeechControl();
  final TranslateControl _translateControl = TranslateControl();

  TextEditingController myTextEdit = TextEditingController();
  TextEditingController yourTextEdit = TextEditingController();


  Color yourMainColor = Colors.blueGrey[800]!;
  Color myMainColor = Colors.cyan[800]!;

  AudioManager audioManager = AudioManager.streamSystem;

  @override
  void initState() {
    super.initState();
    print("새로시작");
    initAudioStreamType();

    isBeforeResume = true;
    _languageSelectControl.initializeLanguageSelectControl();
    _bluetoothControl.initializeBluetoothControl();
    _textToSpeechControl.initTextToSpeech();
    _translateControl.initializeTranslateControl();

    WidgetsBinding.instance.addObserver(this);
  } @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if (state == AppLifecycleState.paused) {
      // 앱이 일시정지될 때의 처리
      // 예: 재생 중인 비디오를 일시 정지
      print("앱이 일시중지됨");
      isBeforeResume = true;
    }
    else if(state == AppLifecycleState.resumed){
      print("앱이 재개됨");
      isBeforeResume = true;
    }
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
      toolbarHeight: 60,

      );
  }
  Widget translateAreaField(bool isMine) {
    Widget loadingWidget;
    if(isMine && _nowRecordBtnOwner == ActingOwner.you && _nowActingStatus == ActingStatus.translating)
    {
      loadingWidget = LoadingAnimationWidget.prograssiveDots(color: Colors.indigo, size: 25);
    }
    else if(!isMine && _nowRecordBtnOwner == ActingOwner.me && _nowActingStatus == ActingStatus.translating){
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
    bool isRecordingAndMatchWithTurn = recordBtnOwner == _nowRecordBtnOwner;
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
                    setState(() {
                    });
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
    bool isRecordBtnOwnerIsMe = recordBtnOwner == ActingOwner.me;
    if(_nowRecordBtnOwner == ActingOwner.neutral)
    {
      bool hasPermission = await PermissionController.checkIfVoiceRecognitionPermissionGranted();
      if (!hasPermission) {
        if(mounted){
          PermissionController.showNoPermissionSnackBar(context);
        }
        return;
      }
      bool isInternetConnected = await ConnectivityWrapper.instance.isConnected;
      if (!isInternetConnected) {
        await simpleConfirmDialog1(context, "인터넷 연결이 필요합니다!", "확인");
        //todo 인터넷연결안됨 처리.
        return;
      }
      if(_nowActingStatus != ActingStatus.none){
        print("이미 무언가 하고있습니다.");
        return;
      }
      _nowRecordBtnOwner = recordBtnOwner;
      if(isBeforeResume){
        _bluetoothControl.validDevice = await _bluetoothControl.getValidDevice(true);
        if(_bluetoothControl.validDevice != null){
          simpleLoadingDialog(context, "기기 재연결중");
          await _bluetoothControl.disconnectTry(_bluetoothControl.validDevice!, 2000);
          await _bluetoothControl.connectTry(_bluetoothControl.validDevice!, 3000);
          Navigator.of(context).pop();
        }
        isBeforeResume = false;
      }
      print("${isRecordBtnOwnerIsMe? "내쪽" : "상대쪽"} 마이크 켬");
      LanguageItem fromLanguageItem = isRecordBtnOwnerIsMe ? languageSelectControl.nowMyLanguageItem : languageSelectControl.nowYourLanguageItem;
      LanguageItem toLanguageItem =  isRecordBtnOwnerIsMe ? languageSelectControl.nowYourLanguageItem : languageSelectControl.nowMyLanguageItem;
      startActingRoutine(recordBtnOwner, fromLanguageItem, toLanguageItem, languageSelectControl);
    }
    else if(_nowRecordBtnOwner == recordBtnOwner){
     // _playRecordEnd();
      print("${isRecordBtnOwnerIsMe? "내쪽" : "상대쪽"} 마이크 끔");
      whenRoutineExit();
    }
    else{
      whenRoutineExit();
      _isRecordInterrupt = true;
      onPressedAudioRecordBtn(recordBtnOwner, languageSelectControl);
      print("이 경우 정의가 필요");
    }
    setState(() {});
  }
  whenRoutineExit() async{
    print("-----------------------루틴끝 stopActingRoutine------------------------");
    setVol(androidVol: 9, iOSVol: 0.0, showVolumeUI: false);
    _nowActingStatus = ActingStatus.none;
    _nowRecordBtnOwner = ActingOwner.neutral;
  }
  startActingRoutine(ActingOwner recordBtnOwner, LanguageItem fromLanguageItem, LanguageItem toLanguageItem, LanguageSelectControl languageSelectControl) async
  {
    if(recordBtnOwner == ActingOwner.neutral){
      print("중립으로 이 루틴을 실행할수 없음");
      return;
    }
      //1. setting
    print("-----------------------루틴시작 startActingRoutine------------------------");
    myTextEdit.text = '';
    yourTextEdit.text = '';

    //2. speech to original text
    print("-----------------------음성녹음 ActingStatus.recording------------------------");
    _nowActingStatus = ActingStatus.recording;

    String fromWords = await listeningRoutine(fromLanguageItem.speechLocaleId!, recordBtnOwner, languageSelectControl);
    // String fromWords = await listeningRoutine_speechToText(fromLanguageItem.speechLocaleId!, isMyRecordBtn);

    if(_isRecordInterrupt){
      print("레코드 인터럽트로 인해 상황이 변화되었음");
      _isRecordInterrupt = false;
      return;
    }
    if(fromWords.isEmpty) {
      print("아무 말도 녹음되지 않았습니다");
      whenRoutineExit();
      return;
    }
    //3. original text to translated text
    print("-----------------------번역 ActingStatus.translating------------------------");
    _nowActingStatus = ActingStatus.translating;
    String? toWords = await _translateControl.translateByAvailableTranslateTools(fromWords, fromLanguageItem, toLanguageItem, 2000);

    if(_isRecordInterrupt){
      print("레코드 인터럽트로 인해 상황이 변화되었음");
      _isRecordInterrupt = false;
      return;
    }
    setState(() {
    });

    if(toWords == null)
    {
      print("번역 기능에서 오류가 발생한듯 합니다");
      whenRoutineExit();

      await simpleConfirmDialog1(context, "서버가 불안정합니다. 잠시후 시도해보세요", "OK");
      myTextEdit.text ='';
      yourTextEdit.text ='';

      return;
    }
    if(toWords!.isEmpty) {
      print("아무 말도 번역되지 않았습니다");
      whenRoutineExit();
      return;
    }
    TextEditingController properControllerToTranslatedWords = recordBtnOwner == ActingOwner.me ? yourTextEdit : myTextEdit;
    properControllerToTranslatedWords.text = toWords;

    //speech service
    try{

      _textToSpeechControl.changeLanguage(toLanguageItem.speechLocaleId!);
      _textToSpeechControl.speak(toWords);
    }
    catch(e){
      print(e);
    }

    print("-----------------------디바이스전송 ActingStatus.deviceSending------------------------");

    if(_isRecordInterrupt){
      print("레코드 인터럽트로 인해 상황이 변화되었음");
      _isRecordInterrupt = false;
      return;
    }
    //5. send to device
    _nowActingStatus = ActingStatus.deviceSending;
    BluetoothDevice? targetDevice = _bluetoothControl.validDevice;
    if(targetDevice == null)
    {
      print("타겟디바이스가 없습니다");
      whenRoutineExit();
      return;
    }
    BluetoothDeviceState state = await targetDevice!.state.first;


    if(_isRecordInterrupt){
      print("레코드 인터럽트로 인해 상황이 변화되었음");
      _isRecordInterrupt = false;
      return;
    }

    if(state != BluetoothDeviceState.connected)
    {
      print("타겟디바이스의 연결이 끊겨있습니다.");
      whenRoutineExit();
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

    if(_isRecordInterrupt){
      print("레코드 인터럽트로 인해 상황이 변화되었음");
      _isRecordInterrupt = false;
      return;
    }
    whenRoutineExit();

    // await Future.delayed(Duration(milliseconds: 1000));
    // onPressedAudioRecordBtn(recordBtnOwner == ActingOwner.me ? ActingOwner.you : ActingOwner.me, languageSelectControl);
  }
  bool _isRecordInterrupt = false;
  listeningRoutine(String speechLocaleID, ActingOwner recordBtnOwner, languageSelectControl) async {

    setVol(androidVol: 0, iOSVol: 0.0, showVolumeUI: false);
    SpeechRecognitionControl speechRecognitionControl = SpeechRecognitionControl();
    speechRecognitionControl.transcription = '';
    speechRecognitionControl.activateSpeechRecognizer();
    speechRecognitionControl.start(speechLocaleID);
    TextEditingController properControllerToTranslatedWords = recordBtnOwner == ActingOwner.me ? myTextEdit  : yourTextEdit;
    while (true) {
      // if(!_speechToTextControl.speechToText.isListening)
      await Future.delayed(Duration(milliseconds: 0));
      if(_isRecordInterrupt){
        print("레코드 인터럽트로 인한 break");
        break;
      }
      if(speechRecognitionControl.transcription.isNotEmpty) {
        properControllerToTranslatedWords.text = speechRecognitionControl.transcription;
      }
      if(recordBtnOwner != _nowRecordBtnOwner)
      {
        print("진입 당시 acting owner 와 상황이 달라져서 listening routine 탈출.. ");
        break;
      }
      if(speechRecognitionControl.isCompleted)
      {
        for(int i = 0 ; i < 5 ; i ++){
          await Future.delayed(Duration(milliseconds: 100));
          properControllerToTranslatedWords.text = speechRecognitionControl.transcription;
        }
        print("speechRecognitionControl.isListening가 false이기 때문에 listening routine 탈출..");
        print(speechRecognitionControl.transcription);
        break;
      }
    }
    speechRecognitionControl.stop();
    properControllerToTranslatedWords.text = speechRecognitionControl.transcription;

    return speechRecognitionControl.transcription;
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
      if(mounted) {
        PermissionController.showNoPermissionSnackBar(context);
      }
      return;
    }
    bool bluetoothOn = await bluetoothControl.flutterBlue.isOn;
    if(!bluetoothOn){
      bool resp = await bluetoothControl.checkIfBluetoothOn(context);
      return;
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
            if(_nowRecordBtnOwner != ActingOwner.neutral){
              onPressedAudioRecordBtn(_nowRecordBtnOwner, languageSelectControl);
            }
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

  Future<void> initAudioStreamType() async {
    await Volume.initAudioStream(AudioManager.streamNotification);
  }
  setVol({int androidVol = 0, double iOSVol = 0.0, bool showVolumeUI = true}) async {
    await Volume.setVol(
      androidVol: androidVol,
      iOSVol: iOSVol,
      showVolumeUI: showVolumeUI,
    );
  }

}