import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:imageshare/model/user.dart';
import 'package:imageshare/util/jsonutil.dart';
import 'package:imageshare/util/urlutil.dart';

class MyImage{
  String title;
  String url;
  MyImage(String title, String url){
    this.title = title;
    this.url = url;
  }
}
List<MyImage> myimages = new List<MyImage>();

setMyImages(User user) async{
  print(user.token);
  Options options = Options(headers:{HttpHeaders.authorizationHeader: "Bearer " + user.token});
    var dio = new Dio();
    var response = await dio.get(URLUtil.url + "image/" + "getAllImageUrl", options: options);
    var responseJson = json.decode(JsonUtil.toJson(response.data.toString()));
    if(int.parse(responseJson["code"]) == 0){
      String urlstring = responseJson["data"];
      urlstring = urlstring.substring(1, urlstring.length -1);
      List<String> urls = urlstring.split(",");
      List<MyImage> images = new List<MyImage>();
      for(int i=0; i<urls.length; i++){
        String title = urls[i].split("/").last;
        String url =urls[i].trim().replaceAll("localhost", "10.0.2.2");
        print(url);
        MyImage myImage = new MyImage(title, url);
        images.add(myImage);
      }
      myimages = images;
    }
  }
 