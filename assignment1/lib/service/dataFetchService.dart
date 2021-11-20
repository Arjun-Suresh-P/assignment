import 'dart:convert';
import 'package:assignment1/constants/dataConstants.dart';
import 'package:http/http.dart' as http;


class DataFetchRepository{
  Future<dynamic> dataRepository() async {

    String url = DataConstants.dataUrl;
    final  response = await http.get(Uri.parse(url));
    dynamic responseJson = jsonDecode(response.body);
    return responseJson;
    //return DataModel.fromJson(responseJson);
  }
}
