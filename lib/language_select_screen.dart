
import 'package:bluetoothtranslate/helper/simple_separator.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';

import 'language_select_control.dart';

class LanguageSelectScreen extends StatefulWidget {
  final bool isMine;
  final LanguageSelectControl languageSelectControl;

  const LanguageSelectScreen({
    required this.isMine,
    required this.languageSelectControl,
    Key? key,
  }) : super(key: key);


  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  // TODO: 기본함수
  // void makeLanguageDatas() {
  //   for (var languageItem in languageDataList) {
  //     languageMenuItems.add(languageDropdownMenuItem(languageItem!));
  //   }
  // }
  late bool isMine = widget.isMine;
  late List<LanguageItem> languageDataList = widget.languageSelectControl.languageDataList;
  late final List<Widget> _languageListTiles = [];

  @override
  void initState() {
    // TODO: implement initState
    for(int i = 0 ; i < languageDataList.length ; i++)
    {
      _languageListTiles.add(languageListTile(languageDataList[i]));
    }

    // onSelectedLanguageListTile(widget.languageSelectControl.initialLanguageItem);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 50, child: Align(alignment : Alignment.center, child: Text("${isMine ? "당신" : "상대방"}의 언어를 선택해주세요")),),
          SimpleSeparator(color: Colors.black, height: 0.3, top: 0, bottom: 10),
          Expanded(
            child: ListView(
              children: _languageListTiles,
            ),
          ),
        ],
      ),
    );
  }

  Widget languageListTile(LanguageItem languageItem)
  {
    return InkWell(
      onTap: () => onSelectedLanguageListTile(languageItem),
      child: ListTile(
        title: Text(languageItem.menuDisplayStr!, textAlign: TextAlign.left,),
      ),
    );
  }
  void onSelectedLanguageListTile(LanguageItem languageItem) {
    if (isMine) {
      
      widget.languageSelectControl.nowMyLanguageItem = languageItem;
    } else {
      widget.languageSelectControl.nowYourLanguageItem = languageItem;
    }
    Navigator.of(context).pop();
  }
}
