
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:imageshare/model/user.dart';
import 'package:imageshare/util/jsonutil.dart';
import 'package:imageshare/util/urlutil.dart';
import 'home_page.dart';
import 'package:imageshare/model/myimage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = new GlobalKey<FormState>();

  String _userID;
  String _password;
  int _role = 1;
  bool _isChecked = true;
  bool _isLoading;
  IconData _checkIcon = Icons.check_box;
  

  void _changeFormToLogin() {
    _formKey.currentState.reset();
  }

  void _onLogin() async{
    final form = _formKey.currentState;
    form.save();

    if (_userID == '') {
      _showMessageDialog('账号不可为空');
      return;
    }
    if (_password == '') {
      _showMessageDialog('密码不可为空');
      return;
    }
    //验证用户名密码
    FormData formData = new FormData.fromMap({
      "username": _userID,
      "password": _password,
      "role": _role
    });
    var dio = new Dio();
    var response = await dio.post(URLUtil.url + "login", data:formData);
    var responseJson = json.decode(JsonUtil.toJson(response.data.toString()));
    if(int.parse(responseJson["code"]) != 0){
      //登录失败，进行注册
      FormData formData = new FormData.fromMap({
        "username": _userID,
        "password": _password,
        "role": _role
      });
      response = await dio.post(URLUtil.url + "register", data:formData,);
      responseJson = json.decode(JsonUtil.toJson(response.data.toString()));
      if(int.parse(responseJson["code"]) != 0){
        //注册也失败
        _showMessageDialog("登录、注册失败");
        return;
      }else{
        //注册也失败
        _showMessageDialog("注册成功");
        return;
      }
    }else{
      //登录成功
      _showMessageDialog("登录成功");
      User user = new User(_userID, responseJson["data"]);
      await setMyImages(user);
      Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute(builder: (context) => new HomePage(user: user)), (route) => route == null);
    }
  }

  void _showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text('提示'),
          content: new Text(message),
          actions: <Widget>[
            new FlatButton(
              child: new Text("ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showUsernameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        style: TextStyle(fontSize: 15,color: Colors.grey[300]),
        decoration: new InputDecoration(
            border: InputBorder.none,
            hintText: '请输入帐号',
            hintStyle: TextStyle(color:  Colors.grey),
            icon: new Icon(
              Icons.person,
              color: Colors.grey,
            )
        ),
        onSaved: (value) => _userID = value.trim(),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        style: TextStyle(fontSize: 15, color: Colors.grey[300]),
        decoration: new InputDecoration(
            border: InputBorder.none,
            hintText: '请输入密码',
            hintStyle: TextStyle(color:  Colors.grey),
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            ),
        ),  
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/login_bcg.png"),
              fit: BoxFit.cover
            )
          ),
          child: ListView(
            children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 30),
              height: 240,
              child: Image(image: AssetImage('assets/images/login.png')),
            ),
            Form(
              key: _formKey,
              child: Container(
                height: 125,
                padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                child: Card(
                  color: Colors.transparent,
                  child: Column(
                    children: <Widget>[
                      _showUsernameInput(),
                      Divider(
                        height: 0.5,
                        indent: 16.0,
                        color: Colors.grey[300],
                      ),
                      _showPasswordInput(),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: RadioListTile(
                  value: 2,
                  title: Text("用户"),
                  groupValue: _role,
                  onChanged: (value){
                    setState(() {
                      _role = value;
                      });
                    },
                  ),
                ),
                Flexible(
                  child: RadioListTile(
                  value: 1,
                  title: Text("管理员"),
                  groupValue: _role,
                  onChanged: (value){
                    setState(() {
                      _role = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Container(
              height: 70,
              padding: const EdgeInsets.fromLTRB(35, 30, 35, 0),
              child: OutlineButton(
                child: Text(
                  '登录/注册',
                  style: TextStyle(fontSize: 18),  
                ),
                textColor: Colors.black45,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                borderSide: BorderSide(color: Colors.black26, width: 2),
                onPressed: () {
                  _onLogin();
                },
              ),
            ),
          ],
         ),
        )
      );
  }
}