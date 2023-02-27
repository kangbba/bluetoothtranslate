import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  String _text = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    _speech.initialize();
  }

  void _startListening(int millisec) {
    _speech.listen(
      onResult: (result) {
        setState(() {
          _text += result.recognizedWords + ' ';
        });
      },
      partialResults: true,
    );
    _isListening = true;
  }

  void _stopListening() {
    _speech.stop();
    _isListening = false;
  }

  void _onTimeout(Timer timer) {
    if (_isListening) {
      _stopListening();
      _startListening(2000);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_text),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isListening) {
                  _stopListening();
                } else {
                  _startListening(2000);
                  Timer.periodic(Duration(milliseconds: 2001), _onTimeout);
                }
              },
              child: Text(_isListening ? 'Stop' : 'Start'),
            ),
          ],
        ),
      ),
    );
  }
}
