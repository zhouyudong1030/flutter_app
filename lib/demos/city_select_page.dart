import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:azlistview/azlistview.dart';
import 'package:common_utils/common_utils.dart';

class CityInfo extends ISuspensionBean {
  String name;
  String tagIndex;
  String namePinyin;

  CityInfo({
    this.name,
    this.tagIndex,
    this.namePinyin
  });

  CityInfo.fromJson(Map<String, dynamic> json)
    : name = json['name'] == null ? '' : json['name'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'tagIndex': tagIndex,
    'namePinyin': namePinyin,
    'isShowSupension': isShowSuspension
  };

  @override
  String getSuspensionTag() => tagIndex;

  @override
  String toString() => "CityBean {" + "\"name\":\"" + name + "\"" + "}";
}

class CitySelectPage extends StatefulWidget {
  final String title;
  CitySelectPage(this.title);

  @override
  State<StatefulWidget> createState() => new _CitySelectPageState();
}

class _CitySelectPageState extends State<CitySelectPage> {
  List<CityInfo> _cityList = List();
  List<CityInfo> _hotCityList = List();

  int _suspensionHeight = 40;
  int _itemHeight = 50;
  String _suspensionTag = "";

  @override
  void initState(){
    super.initState();
    loadData();
  }

  void loadData() async {
    // 加载城市列表
    rootBundle.loadString('assets/data/china.json').then((value) {
      Map countMap = json.decode(value);
      List list = countMap['china'];
      list.forEach((value) {
        _cityList.add(CityInfo(name: value['name']));
      });
      _handleList(_cityList);

      _hotCityList
        ..add(CityInfo(name: '北京市', tagIndex: '热门'))
        ..add(CityInfo(name: '广州市', tagIndex: '热门'))
        ..add(CityInfo(name: '成都市', tagIndex: '热门'))
        ..add(CityInfo(name: '深圳市', tagIndex: '热门'))
        ..add(CityInfo(name: '杭州市', tagIndex: '热门'))
        ..add(CityInfo(name: '武汉市', tagIndex: '热门'));

      setState(() {
        _suspensionTag = _hotCityList[0].getSuspensionTag();
      });
    });
  }

  void _handleList(List<CityInfo> list) {
    if(list == null || list.isEmpty) return ;
    for(int i = 0, length = list.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(list[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if(RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = '#';
      }
    }
    SuspensionUtil.sortListBySuspensionTag(list);
  }

  void _onSusTagChanged(String tag) {
    setState(() {
     _suspensionTag = tag;
    });
  }

  // 构建悬停的widget
  Widget _buildSusWidget(String susTag) {
    return Container(
      height: _suspensionHeight.toDouble(),
      padding: const EdgeInsets.only(left: 15.0),
      color: Color(0xfff3f4f5),
      alignment: Alignment.centerLeft,
      child: Text(
        '$susTag',
        softWrap: false, // 是否自动换行，false的时候不换行，一行显示，超出屏幕的部分会被阶段
        style: TextStyle(
          fontSize: 14.0,
          color: Color(0xff999999),
        ),
      ),
    );
  }

  // 构建悬停的列表项
  Widget _buildListItem(CityInfo model) {
    return Column(
      children: <Widget>[
        Offstage(
          offstage: !(model.isShowSuspension == true),
          child: _buildSusWidget(model.getSuspensionTag()),
        ),
        SizedBox( // child的元素按照的父widget的尺寸调整宽高
          height: _itemHeight.toDouble(),
          child: ListTile(
            title: Text(model.name),
            onTap: () {
              LogUtil.e('OnItemClick: $model');
              Navigator.pop(context, model);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 15.0),
            height: 50.0,
            child: Text('当前城市：成都市'),
          ),
          Expanded(
            flex: 1,
            child: new AzListView(
              data: _cityList,
              topData: _hotCityList,
              itemBuilder: (context, model) => _buildListItem(model),
              suspensionWidget: _buildSusWidget(_suspensionTag),
              itemHeight: _itemHeight,
              isUseRealIndex: true,
              suspensionHeight: _suspensionHeight,
              onSusTagChanged: _onSusTagChanged,
            ),
          ),
        ],
      ),
    );
  }
}


