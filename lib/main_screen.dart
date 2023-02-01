import 'package:bluetoothtranslate/apiKey.dart';
import 'package:flutter/material.dart';
import 'package:bluetoothtranslate/tranlsate_api.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'language_items.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final TextEditingController _textController = TextEditingController();

  String _translatedText = '';

  LanguageItem? currentSourceLanguageItem = findLanguageItemByLanguageCode('en');
  LanguageItem? currentTargetLanguageItem= findLanguageItemByLanguageCode('ko');

  late String _selectedSourceLanguageCode = currentSourceLanguageItem!.languageCode!;
  late String _selectedTargetLanguageCode = currentTargetLanguageItem!.languageCode!;

  final List<DropdownMenuItem<String>> _languageMenuItems = [];

  @override
  void initState() {
    super.initState();

    for (var languageItem in languageItems) {
      _languageMenuItems.add(languageDropdownMenuItem(languageItem));
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translate'),
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _textController,
              decoration: InputDecoration(hintText: 'Enter text to translate'),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButton(
                    items: _languageMenuItems,
                    value: currentSourceLanguageItem!.languageCode,
                    onChanged: (value) {
                      setState(() {
                        _selectedSourceLanguageCode = value!;
                        currentSourceLanguageItem = findLanguageItemByLanguageCode(value!);
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
                    value: currentTargetLanguageItem!.languageCode,
                    onChanged: (value) {
                      setState(() {
                        _selectedTargetLanguageCode =  value!;
                        currentTargetLanguageItem = findLanguageItemByLanguageCode(value!);
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              child: Text('Translate'),
              onPressed: () async {
                String textToTranslate = _textController.text;
                final translateApi = TranslateApi(
                    sourceTranslateLanguage: currentSourceLanguageItem!.translateLanguage!,
                    targetTranslateLanguage: currentTargetLanguageItem!.translateLanguage!
                );
                final translatedText = await translateApi.translate(textToTranslate);
                print(translatedText);
                setState(() {
                  _translatedText = translatedText;
                });
              },
            ),
            Text(_translatedText),
          ],
        ),
      ),
    );
  }

}

