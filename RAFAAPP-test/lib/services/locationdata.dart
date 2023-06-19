import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:rafa_app/error_page.dart';
import 'package:rafa_app/main.dart';
import 'package:rafa_app/services/my_http_client.dart';
import 'dart:convert' as convert;

import '../contants.dart';

class BackendService {
  final String accessToken;
  late MyHttpClient myHttpClient;

  BackendService(this.accessToken) {
    myHttpClient = MyHttpClient({"Authorization": "Bearer " + accessToken});
  }

  Future<List<Map<String, dynamic>>> getSuggestions(
      {String? name, String? postalCode}) async {
    List<Suggestion> suggestions = [];

    if (name != null && name.length < 3) {
      print('Query needs to be at least 3 chars');
      return Future.value([]);
    }

    //check if postalcode == "" after manipulation
    if (postalCode == "") {
      Suggestion emptyButNotNullPostalCode = Suggestion(
          buildingCode: "Others", buildingName: "Others", lat: 0, lon: 0);
      suggestions.add(emptyButNotNullPostalCode);
      return Future.value(suggestions
          .map((e) => {
                'buildingName': e.buildingName,
                'buildingCode': e.buildingCode,
                'lat': e.lat,
                'lon': e.lon,
              })
          .toList());
    }

    name ??= "";
    postalCode ??= "";
    var url = Uri.parse(APIPREFIX +
        '/api/RAFABuildings/SearchForBuilding' +
        '?name=$name&postalCode=$postalCode');
    // var url = Uri.parse(jmmApiPrefix +
    //     '/JMM/api/building/search?name=$query&include_building_space=false&include_asset=false');
    // APIPREFIX + '/api/RAFAEstates/RetreiveEstateById' + '?estate=$query';
    var response = await myHttpClient.get(url);

    if (response.statusCode == 200) {
      Iterable json = convert.jsonDecode(response.body);
      suggestions = List<Suggestion>.from(
          json.map((model) => Suggestion.fromJson(model)));
      print('Number of suggestion: ${suggestions.length}.');
    } else if (response.statusCode == 401 ||
        response.statusCode == 404 ||
        response.statusCode == 500) {
      navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => ErrorPage(statusCode: response.statusCode)));
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    if (suggestions.isEmpty) {
      Suggestion others = Suggestion(
          buildingCode: "Others", buildingName: "Others", lat: 0, lon: 0);
      suggestions.add(others);
    }
    return Future.value(suggestions
        .map((e) => {
              'buildingName': e.buildingName,
              'buildingCode': e.buildingCode,
              'lat': e.lat,
              'lon': e.lon,
            })
        .toList());
  }

  Future<bool> checkBuildingExists(String? name) async {
    if (name == "Others") {
      return true;
    }
    var url = Uri.parse(
        APIPREFIX + '/api/RAFABuildings/SearchForBuilding' + '?name=$name');
    var response = await myHttpClient.get(url);
    List<Suggestion> suggestions = [];
    if (response.statusCode == 200) {
      Iterable json = convert.jsonDecode(response.body);
      suggestions = List<Suggestion>.from(
          json.map((model) => Suggestion.fromJson(model)));
      for (var suggestion in suggestions) {
        if (name == suggestion.buildingName) {
          return true;
        }
      }
    } else if (response.statusCode == 401 ||
        response.statusCode == 404 ||
        response.statusCode == 500) {
      navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => ErrorPage(statusCode: response.statusCode)));
    }
    return false;
    // var json = convert.jsonDecode(response.body);
    // return json;
  }

  Future<Map<String, dynamic>?> getBuildingNameByBuildingCode(
      String? buildingCode) async {
    if (buildingCode != null && buildingCode.isNotEmpty) {
      var url = Uri.parse(APIPREFIX +
          "/api/RAFABuildings/RetrieveBuildingByCode" +
          "?buildingCode=$buildingCode");
      var response = await myHttpClient.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> building = convert.jsonDecode(response.body);
        return Future.value({
          'buildingName': building["building_name"],
          'buildingCode': building["building_code"],
          'lat': building["latitude"],
          'lon': building["longtitude"],
        });
      } else if (response.statusCode == 401 ||
          response.statusCode == 404 ||
          response.statusCode == 500) {
        navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => ErrorPage(statusCode: response.statusCode)));
      }
    }
    return Future.value(null);
  }

  Future<List<Map>> searchForOneMapAddressData(String searchVal) async {
    Uri url = Uri.parse(
        APIPREFIX + "/api/RAFABuildings/OneMapApiSearch?searchVal=$searchVal");
    http.Response response = await myHttpClient.get(url);

    if (response.statusCode == 200) {
      List<Map> jsonBody = List<Map>.from(convert.jsonDecode(response.body));
      return jsonBody;
    } else if (response.statusCode == 401 ||
        response.statusCode == 404 ||
        response.statusCode == 500) {
      navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => ErrorPage(statusCode: response.statusCode)));
    }
    return Future.value([]);
  }
}

class Suggestion {
  final String buildingCode;
  final String buildingName;
  final double lat;
  final double lon;
  // final String address;

  Suggestion({
    required this.buildingCode,
    required this.buildingName,
    required this.lat,
    required this.lon,
    /*required this.address*/
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      buildingCode: json['building_code'],
      buildingName: json['building_name'],
      lat: json['latitude'],
      lon: json['longtitude'], /*address: json['address']*/
    );
  }
}
