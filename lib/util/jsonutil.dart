class JsonUtil{
    static String toJson(String s){
      s = s.replaceAll("{msg: ", '{"msg": "');
      s = s.replaceAll(", code: ", '", "code": "');
      s = s.replaceAll(", data: ", '", "data": "');
      s = s.replaceAll("}", '"}');
      return s;
    }
}