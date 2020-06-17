import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imageshare/model/user.dart';
import 'package:imageshare/util/filenameutil.dart';
import 'package:imageshare/model/myimage.dart';
import 'package:imageshare/util/jsonutil.dart';
import 'package:imageshare/util/urlutil.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget{
  final User user;
  HomePage({Key key, @required this.user}) : super(key:key);

  @override
  HomePageState createState() => HomePageState();

}

class HomePageState extends State<HomePage>{

  String _url = URLUtil.url + "image/";
  String _image;
  Future _getImage() async{
    final piker = ImagePicker();
    String path;
    await showCupertinoDialog(context: context, builder: (context){
      return CupertinoActionSheet(
        title: Text("选择图片", style: TextStyle(fontSize: 20),),
        message: Text("图片来源"),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () async{
              var image = await piker.getImage(source: ImageSource.gallery);
              setState(() {
                path = image.path;
              });
              Navigator.pop(context);
            },
            child: Text("相册"),
          ),         
          CupertinoActionSheetAction(
            onPressed: () async{
              var image = await piker.getImage(source: ImageSource.camera);
              setState(() {
                path = image.path;
              });
              Navigator.pop(context);
            },
            child: Text("相机"), 
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: (){
            Navigator.pop(context);
          },
          child: Text("取消"),
        ),
      );
    });
    setState(() {
      _image = path;
    });
  }

  void _addImage() async{
    await _getImage();
    FormData formData = FormData.fromMap({
      "source": await MultipartFile.fromFile(_image, filename: _image.split("/").last)
    });
    Options options = Options(headers:{HttpHeaders.authorizationHeader: "Bearer" + widget.user.token}, contentType: "multipart/form-data");
    var dio = new Dio();
    var response = await dio.post(_url + "uploadImage", data: formData, options: options);
    var responseJson = json.decode(JsonUtil.toJson(response.data.toString()));
    if(int.parse(responseJson["code"]) != 0){
        //添加失败
        _showMessageDialog("上传失败");
        return;
    }else{
        //添加成功
        _showMessageDialog("上传成功");
        await setMyImages(widget.user);
        setState(() {
          setMyImages(widget.user);
        });
        return;
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

  _deleteImage(String filename) async{
    FormData formData = FormData.fromMap({
      "filename":  filename
    });
    Options options = Options(headers:{HttpHeaders.authorizationHeader: "Bearer" + widget.user.token}, contentType: "multipart/form-data");
    var dio = new Dio();
    var response = await dio.post(_url + "deleteImage", data: formData, options: options);
    if(response.statusCode == 500){
         _showMessageDialog(response.headers.value("warn"));
        return;
    }
    var responseJson = json.decode(JsonUtil.toJson(response.data.toString()));
    if(int.parse(responseJson["code"]) != 0){
        //删除失败zh
        _showMessageDialog("您没有删除权限");
        return;
    }else{
        //删除成功
        _showMessageDialog("删除成功");
        await setMyImages(widget.user);
                setState(() {
          setMyImages(widget.user);
        });
        return;
    }
  }

  Widget _listItemBuilder(BuildContext context, int index){
    return GestureDetector(
      child: Image.network(myimages[index].url),
      onLongPress: () async{
        await showCupertinoDialog(context: context, builder: (context){
          return CupertinoActionSheet(
            title: Text("删除图片", style: TextStyle(fontSize: 20),),
            message: Text("是否确定"),
            actions: <Widget>[
              CupertinoActionSheetAction(
                onPressed: () async{
                  Navigator.pop(context);
                  await _deleteImage(myimages[index].title);           
                },
                child: Text("确定"),
              ),         
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text("取消"),
            ),
          );
        });
      },
    );
    // return Column(children: <Widget>[
    //     Image.network(myimages[index].url),
    //     Text("图" + index.toString()),
    //     SizedBox(height: 50.0)
    //   ],
    // );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Hello, ${widget.user.username} "),),
      body: ListView.builder(
        itemCount: myimages.length,
        itemBuilder: _listItemBuilder,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImage,
        tooltip: '上传图片',
        child: Icon(Icons.add_a_photo),
      ), // Th
    );
  }

}