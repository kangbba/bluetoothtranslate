import 'dart:async';
import 'dart:convert';
import '../statics/apiKey.dart';
import 'package:http/http.dart' as http;

class TranslateByPapagoServer
{
  void initializeTranslateByPapagoServer()
  {
  }
  //TRANSLATIONS
  Future<dynamic> getUsedLanguage(String content) async {
    String _content_type = "application/x-www-form-urlencoded; charset=UTF-8";
    String _url = "https://openapi.naver.com/v1/papago/detectLangs";

    http.Response lan = await http.post(Uri.parse(_url), headers: {
      // 'query': text,
      'Content-Type': _content_type,
      'X-Naver-Client-Id': naverAPIKey,
      'X-Naver-Client-Secret': naverAPISecret
    }, body: {
      'query': content
    });
    if (lan.statusCode == 200) {
      var dataJson = jsonDecode(lan.body);
      //만약 성공적으로 언어를 받아왔다면 language 변수에 언어가 저장됩니다. (ex: eu, ko, etc..)
      var language = dataJson['langCode'];
      return language;
    } else {
      print(lan.statusCode);
      throw("언어감지 실패");
    }
  }

  Future<String?> textTranslate(String inputStr, String sourceLanguageCode, String targetLanguageCode, int timeoutMillisec) async {
    try {
      var translation = await Future.any([
        _translate(inputStr, sourceLanguageCode, targetLanguageCode),
        Future.delayed(Duration(milliseconds: timeoutMillisec)).then((_) => throw TimeoutException('Translation request timed out')),
      ]);
      return translation;
    } on TimeoutException catch (_) {
      return null;
    }
  }

  Future<String?> _translate(String content, String sourceCode, String targetCode) async {
    String _content_type = "application/x-www-form-urlencoded; charset=UTF-8";
    String _url = "https://openapi.naver.com/v1/papago/n2mt";

    http.Response trans = await http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': _content_type,
        'X-Naver-Client-Id': naverAPIKey,
        'X-Naver-Client-Secret': naverAPISecret
      },
      body: {
        'source': sourceCode,
        'target': targetCode,
        'text': content,
      },
    );
    if (trans.statusCode == 200) {
      var dataJson = jsonDecode(trans.body);
      String result_papago = dataJson['message']['result']['translatedText'];
      return result_papago;
    } else {
      print('error ${trans.statusCode}');
      print('error ${trans}');
      return null;
    }
  }

}