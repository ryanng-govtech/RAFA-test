// ignore_for_file: camel_case_types, file_names, avoid_unnecessary_containers, prefer_const_constructors

import 'dart:developer';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:rafa_app/contants.dart';
import 'package:rafa_app/error_page.dart';
import 'package:rafa_app/services/my_http_client.dart';
import 'location.dart';
import 'package:dio/dio.dart';
// import 'dart:html' as html;
import 'dart:ui' as ui;
// import geolocator to get current location 
import 'package:geolocator/geolocator.dart';
import 'services/locationdata.dart';
import 'qr_scanner_page.dart';
import 'upload_image_page.dart';

class JTCMap extends StatefulWidget {
  final String accessToken;
  final double lat;
  final double lng;
  final bool hasMultiplePoints;
  final bool isLatLngSelected;
  final void Function(String) tmpBuildingCodeVal;
  final void Function(String) tmpFaultDetails;
  final void Function(List<LatLng>) workerUpdate;
  final void Function(String) email;
  final void Function(bool) receiveUpdate;
  final String? building;
  final String? spaceId;
  final String? space;

  const JTCMap({
    Key? key,
    required this.accessToken,
    this.lat = 1.3308967,
    this.lng = 103.7417483,
    this.hasMultiplePoints = false,
    this.isLatLngSelected = false,
    required this.tmpBuildingCodeVal,
    required this.tmpFaultDetails,
    required this.workerUpdate,
    required this.email,
    required this.receiveUpdate,
    this.building,
    this.spaceId,
    this.space,
  }) : super(key: key);

  @override
  JTCMapState createState() => JTCMapState();
}

class JTCMapState extends State<JTCMap> {
  late double screenWidth;
  late double screenHeight;
  late bool isSmallScreen;

  late MyHttpClient myHttpClient;
  late BackendService backendService;

  String? spaceId;
  String _currentAddress = "";
  List<LatLng> tappedPoints = [];
  List<Marker> markers = [];
  List<LatLng> latlngList = [];
  MapController? mapController;
  bool isSetSelectedLocationMarker = false;
  final formKey = GlobalKey<FormState>();
  final uploadImageKey = GlobalKey<MyUploadPageState>();
  // this.lat = 1.4293,
  // this.lng = 103.8359,
  double tempLat = 0.0;
  double tempLon = 0.0;
  String? locationValidator;
  String DDLocationVal = "one-north";
  String buildingCodeVal = "";

  final locationTextEditingController = TextEditingController();
  final otherLocationTextEditingController = TextEditingController();
  final additionalLocationDetailsTextEditingController =
      TextEditingController();
  final faultDescTextEditingController = TextEditingController();
  String? salutationDropdownButtonSelectedValue;
  final givenNameTextEditingController = TextEditingController();
  final surnameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final mapLocationTextEditingController = TextEditingController();

  bool _isChecked = false;
  List dataLocation = List.empty();
  List<DropdownMenuItem> itemsLocation = [];

  FocusNode locationFocusNode = FocusNode();
  FocusNode nonJtcLocationFocusNode = FocusNode();
  FocusNode locationDetailsFocusNode = FocusNode();
  FocusNode faultDescFocusNode = FocusNode();
  FocusNode salutationFocusNode = FocusNode();
  FocusNode givenNameFocusNode = FocusNode();
  FocusNode surnameFocusNode = FocusNode();
  FocusNode emailAddressFocusNode = FocusNode();

  TextStyle locationTextStyle = kFieldLabelStyle;
  TextStyle locationDetailsTextStyle = kFieldLabelStyle;
  TextStyle faultDescTextStyle = kFieldLabelStyle;
  TextStyle salutationTextStyle = kFieldLabelStyle;
  TextStyle givenNameTextStyle = kFieldLabelStyle;
  TextStyle surnameTextStyle = kFieldLabelStyle;
  TextStyle emailAddressTextStyle = kFieldLabelStyle;
  TextStyle nonJtcLocationTextStyle = kFieldLabelStyle;

  bool isOtherLocationVisibility = false;
  bool isSuggestionSelected = false;

  GlobalKey locationLabelGlobalKey = GlobalKey();
  GlobalKey otherLocationLabelGlobalKey = GlobalKey();
  GlobalKey additionalLocationDetailsLabelGlobalKey = GlobalKey();
  GlobalKey salutationLabelGlobalKey = GlobalKey();
  GlobalKey givenNameLabelGlobalKey = GlobalKey();
  GlobalKey surnameLabelGlobalKey = GlobalKey();
  GlobalKey emailAddressLabelGlobalKey = GlobalKey();
  late List<GlobalKey> fieldLabelsGlobalKeysList = [
    locationLabelGlobalKey,
    otherLocationLabelGlobalKey,
    additionalLocationDetailsLabelGlobalKey,
    salutationLabelGlobalKey,
    givenNameLabelGlobalKey,
    surnameLabelGlobalKey,
    emailAddressLabelGlobalKey
  ];
  int? scrollToIndex;
  bool validateFailedForOtherLocation = false;

  //onemap api variables
  int apiStatusCode = 0;
  String buildingName = "";
  String block = "";
  String road = "";
  String postalCode = "";
  String fullLocationInformation = "";
  Map buildingWithMatchingPostalCode = {};

  Future<void> reverseGeocode(double latitude, double longitude) async {
    var url = Uri.parse(APIPREFIX +
        '/api/RAFABuildings/ReverseGeocode' +
        "?latitude=$latitude&longitude=$longitude");
    var response = await myHttpClient.post(url);
    apiStatusCode = response.statusCode;
    if (response.statusCode == 200) {
      var locationInformation = jsonDecode(response.body);

      //manipulate string for text field
      manipulateStringForFullLocationInformation(locationInformation);
      mapLocationTextEditingController.text = fullLocationInformation;

      //check postal code from reverse geocode with master list
      List<Map> searchForBuildingWithPostalCode =
          await backendService.getSuggestions(postalCode: postalCode);
      buildingWithMatchingPostalCode = searchForBuildingWithPostalCode[0];
    } else if (response.statusCode == 401 ||
        response.statusCode == 404 ||
        response.statusCode == 500) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorPage(
                    statusCode: response.statusCode,
                  )));
    } else {
      mapLocationTextEditingController.text = "";
    }
  }

  void manipulateStringForFullLocationInformation(locationInformation) {
    buildingName =
        assignLocationInformation(locationInformation["BUILDINGNAME"]);
    block = assignLocationInformation(locationInformation["BLOCK"]);
    road = assignLocationInformation(locationInformation["ROAD"]);
    postalCode = assignLocationInformation(locationInformation["POSTALCODE"]);
    fullLocationInformation = buildingName;
    if (buildingName.isNotEmpty &&
        (block.isNotEmpty || road.isNotEmpty || postalCode.isNotEmpty)) {
      fullLocationInformation += ", ";
    }
    if (block.isNotEmpty) {
      fullLocationInformation += "BLK ";
    }
    fullLocationInformation += block;
    if (block.isNotEmpty && (road.isNotEmpty || postalCode.isNotEmpty)) {
      fullLocationInformation += " ";
    }
    fullLocationInformation += road;
    if (road.isNotEmpty && postalCode.isNotEmpty) {
      fullLocationInformation += " ";
    }
    if (postalCode.isNotEmpty) {
      fullLocationInformation += "S(";
    }
    fullLocationInformation += postalCode;
    if (postalCode.isNotEmpty) {
      fullLocationInformation += ")";
    }
  }

  bool isNullEmptyOrNil(String? locationInformation) {
    if (locationInformation == null ||
        locationInformation.isEmpty ||
        locationInformation == "null" ||
        locationInformation == "NIL") {
      return true;
    }
    return false;
  }

  String assignLocationInformation(String? locationInformation) {
    if (isNullEmptyOrNil(locationInformation)) {
      return "";
    } else {
      return locationInformation!;
    }
  }

  @override
  void initState() {
    super.initState();
    myHttpClient =
        MyHttpClient({"Authorization": "Bearer " + widget.accessToken});
    backendService = BackendService(widget.accessToken);

    log("Init state");
    if (!isSetSelectedLocationMarker) {
      log("Pinning selected loc");
      _handleCreate();
    }
    spaceId = widget.spaceId;
    latlngList.add(LatLng(widget.lat, widget.lng));

    locationFocusNode.addListener(() {
      setState(() {
        locationTextStyle = locationFocusNode.hasFocus
            ? kFieldLabelStyle.copyWith(color: kElectricBlue)
            : kFieldLabelStyle;
        if (!locationFocusNode.hasFocus && !isSuggestionSelected) {
          locationTextEditingController.text = "";
          otherLocationTextEditingController.text = "";
          isOtherLocationVisibility = false;
          mapLocationTextEditingController.text = "";
          latlngList.clear();
          latlngList.add(LatLng(1.3308967, 103.7417483));
          widget.workerUpdate(latlngList);
          markers.clear();
          validateFailedForOtherLocation = false;
        }
      });
    });
    locationDetailsFocusNode.addListener(() {
      setState(() {
        locationDetailsTextStyle = locationDetailsFocusNode.hasFocus
            ? kFieldLabelStyle.copyWith(color: kElectricBlue)
            : kFieldLabelStyle;
      });
    });
    faultDescFocusNode.addListener(() {
      setState(() {
        faultDescTextStyle = faultDescFocusNode.hasFocus
            ? kFieldLabelStyle.copyWith(color: kElectricBlue)
            : kFieldLabelStyle;
      });
    });
    salutationFocusNode.addListener(() {
      setState(() {
        salutationTextStyle = salutationFocusNode.hasFocus
            ? kFieldLabelStyle.copyWith(color: kElectricBlue)
            : kFieldLabelStyle;
      });
    });
    givenNameFocusNode.addListener(() {
      setState(() {
        givenNameTextStyle = givenNameFocusNode.hasFocus
            ? kFieldLabelStyle.copyWith(color: kElectricBlue)
            : kFieldLabelStyle;
      });
    });
    surnameFocusNode.addListener(() {
      setState(() {
        surnameTextStyle = surnameFocusNode.hasFocus
            ? kFieldLabelStyle.copyWith(color: kElectricBlue)
            : kFieldLabelStyle;
      });
    });
    emailAddressFocusNode.addListener(() {
      setState(() {
        emailAddressTextStyle = emailAddressFocusNode.hasFocus
            ? kFieldLabelStyle.copyWith(color: kElectricBlue)
            : kFieldLabelStyle;
      });
    });
    nonJtcLocationFocusNode.addListener(() {
      setState(() {
        nonJtcLocationTextStyle = nonJtcLocationFocusNode.hasFocus
            ? kFieldLabelStyle.copyWith(color: kElectricBlue)
            : kFieldLabelStyle;
      });
    });

    //populate building name
    getBuildingFromQrAndPopulate(widget.building);

    //populate additional location details
    additionalLocationDetailsTextEditingController.text = widget.space ?? "";
  }

  @override
  void dispose() {
    locationFocusNode.dispose();
    locationDetailsFocusNode.dispose();
    faultDescFocusNode.dispose();
    givenNameFocusNode.dispose();
    emailAddressFocusNode.dispose();
    myHttpClient.close();
    backendService.myHttpClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    isSmallScreen = true;

    tempLat = widget.lat;
    tempLon = widget.lng;

    if (widget.isLatLngSelected) {
      log("tapped list: " + tappedPoints.length.toString());
    }
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /* ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(4),
            children: <Widget>[
              ///merge online and offline data in the same list and set custom max Height
              DropdownSearch<LocationModel>(
                maxHeight: 300,
                onFind: (String? filter) => getData(filter),
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Search For A Location",
                  contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                  border: OutlineInputBorder(),
                ),
                onChanged: (print) {
                  setState(() {
                    DDLocationVal = print.toString();
                    log(DDLocationVal);
                  });
                },
                showSearchBox: true,
              ),
              Divider(),
            ],
          ),*/
          Padding(
              padding: EdgeInsets.only(
                  top: screenHeight * 0.05,
                  left: isSmallScreen ? 0.08 * screenWidth : 0.15 * screenWidth,
                  right:
                      isSmallScreen ? 0.08 * screenWidth : 0.15 * screenWidth),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          text: "Location",
                          style: locationTextStyle,
                          children: const [
                            TextSpan(
                              text: "*",
                              style: TextStyle(color: kRed),
                            ),
                          ],
                        ),
                        key: locationLabelGlobalKey,
                      ),
                    ),
                    SizedBox(height: 0.01 * screenHeight),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TypeAheadFormField(
                              validator: (value) {
                                return locationValidator;
                              },
                              textFieldConfiguration: TextFieldConfiguration(
                                style: kFormFieldStyle,
                                focusNode: locationFocusNode,
                                controller: locationTextEditingController,
                                onChanged: (value) {
                                  isSuggestionSelected = false;
                                },
                                decoration: InputDecoration(
                                  errorMaxLines: 3,
                                  hintMaxLines: 3,
                                  border: OutlineInputBorder(),
                                  hintStyle: kFormFieldHintStyle,
                                  hintText: "Enter location name",
                                ),
                              ),
                              suggestionsCallback: (pattern) async {
                                return await backendService.getSuggestions(
                                    name: pattern);
                              },
                              itemBuilder:
                                  (context, Map<String, dynamic> suggestion) {
                                return ListTile(
                                  title: Text(suggestion['buildingName']!),
                                  //subtitle: Text('${suggestion['id']}'),
                                );
                              },
                              noItemsFoundBuilder: (context) {
                                return ListTile(
                                    title: Text(
                                        "Enter 3 or more characters for dropdown or 'Others' for other location"));
                              },
                              onSuggestionSelected:
                                  (Map<String, dynamic> suggestion) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  isSuggestionSelected = true;
                                  locationTextEditingController.text =
                                      suggestion['buildingName']!.toString();
                                  setState(() {
                                    if (suggestion['buildingName'] ==
                                        "Others") {
                                      isOtherLocationVisibility = true;
                                    } else {
                                      isOtherLocationVisibility = false;
                                    }
                                    if (!widget.hasMultiplePoints) {
                                      tappedPoints.clear();
                                      markers.clear();
                                      latlngList.clear();
                                    }
                                    tappedPoints.add(LatLng(
                                        suggestion['lat'], suggestion['lon']));
                                    markers = tappedPoints.map((latlng) {
                                      return Marker(
                                        width: 50.0,
                                        height: 50.0,
                                        point: latlng,
                                        builder: (ctx) => Container(
                                            child: const Icon(Icons.pin_drop)),
                                      );
                                    }).toList();
                                    latlngList.add(LatLng(
                                        suggestion['lat'], suggestion['lon']));
                                    widget.workerUpdate(latlngList);
                                  });
                                });
                                buildingCodeVal = suggestion['buildingCode'];
                                setState(() {
                                  widget.tmpBuildingCodeVal(buildingCodeVal);
                                });
                              },
                            ),
                          ),
                          isSmallScreen
                              ? SizedBox.shrink()
                              : Container(
                                  child: Row(
                                  children: [
                                    SizedBox(width: 5),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        Map<String, String>? locationParams =
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        QrScannerPage()));
                                        setState(() {
                                          if (locationParams != null &&
                                              locationParams.isNotEmpty) {
                                            getBuildingFromQrAndPopulate(
                                                locationParams["building"]);
                                            spaceId = locationParams["spaceid"];
                                            additionalLocationDetailsTextEditingController
                                                    .text =
                                                locationParams["space"] ?? "";
                                          }
                                        });
                                      },
                                      icon: Icon(Icons.qr_code_rounded),
                                      label: Text("Scan QR"),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: kElectricBlue),
                                        padding: EdgeInsets.all(20),
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (_) {
                                              return StatefulBuilder(builder:
                                                  (context, setStateForDialog) {
                                                return _buildMapDialog(
                                                    setStateForDialog);
                                              });
                                            });
                                      },
                                      icon: Icon(Icons.location_pin),
                                      label: Text("Map"),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: kElectricBlue),
                                        padding: EdgeInsets.all(20),
                                      ),
                                    )
                                  ],
                                ))
                        ]),
                    isSmallScreen
                        ? SizedBox(
                            height: 5,
                          )
                        : SizedBox.shrink(),
                    isSmallScreen
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: OverflowBar(
                              spacing: 5,
                              overflowSpacing: 5,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    Map<String, String>? locationParams =
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    QrScannerPage()));
                                    setState(() {
                                      if (locationParams != null &&
                                          locationParams.isNotEmpty) {
                                        getBuildingFromQrAndPopulate(
                                            locationParams["building"]);
                                        spaceId = locationParams["spaceid"];
                                        additionalLocationDetailsTextEditingController
                                                .text =
                                            locationParams["space"] ?? "";
                                      }
                                    });
                                  },
                                  icon: Icon(Icons.qr_code_rounded),
                                  label: Text("Scan QR"),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: kElectricBlue),
                                    padding: EdgeInsets.all(20),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) {
                                          return StatefulBuilder(builder:
                                              (context, setStateForDialog) {
                                            return _buildMapDialog(
                                                setStateForDialog);
                                          });
                                        });
                                  },
                                  icon: Icon(Icons.location_pin),
                                  label: Text("Map"),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: kElectricBlue),
                                    padding: EdgeInsets.all(20),
                                  ),
                                )
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                    Align(
                        alignment: Alignment.centerLeft,
                        child:
                            Text("See a QR Code? Click the QR Logo to scan.")),
                    Visibility(
                        visible: isOtherLocationVisibility,
                        child: Column(
                          children: [
                            SizedBox(height: 16),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text.rich(
                                  TextSpan(
                                    text: "Other Location",
                                    style: nonJtcLocationTextStyle,
                                    children: const [
                                      TextSpan(
                                        text: "*",
                                        style: TextStyle(color: kRed),
                                      ),
                                    ],
                                  ),
                                  key: otherLocationLabelGlobalKey,
                                )),
                            SizedBox(height: 0.01 * screenHeight),
                            TextFormField(
                              maxLines: null,
                              controller: otherLocationTextEditingController,
                              focusNode: nonJtcLocationFocusNode,
                              style: kFormFieldStyle,
                              decoration: InputDecoration(
                                  errorMaxLines: 3,
                                  hintMaxLines: 3,
                                  border: OutlineInputBorder(),
                                  hintStyle: kFormFieldHintStyle,
                                  hintText: "Enter other location"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  validateFailedForOtherLocation = true;
                                  return "Enter other location.";
                                }
                                return null;
                              },
                              maxLength: 200,
                            )
                          ],
                        )),
                    SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 32.0),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                text: "Additional Location Details",
                                style: locationDetailsTextStyle,
                                children: const [
                                  TextSpan(
                                    text: "*",
                                    style: TextStyle(color: kRed),
                                  ),
                                ],
                              ),
                              key: additionalLocationDetailsLabelGlobalKey,
                            ),
                          ),
                          SizedBox(height: 0.01 * screenHeight),
                          TextFormField(
                            maxLines: null,
                            focusNode: locationDetailsFocusNode,
                            style: kFormFieldStyle,
                            controller:
                                additionalLocationDetailsTextEditingController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                scrollToIndex ??= 2;
                                return 'Please enter the location details.';
                              }
                              return null;
                            },
                            maxLength: 50,
                            decoration: const InputDecoration(
                              errorMaxLines: 3,
                              hintMaxLines: 3,
                              border: OutlineInputBorder(),
                              hintStyle: kFormFieldHintStyle,
                              hintText: 'Describe location E.g. Level 1 Lobby',
                            ),
                          ),
                          SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Fault Description",
                              style: faultDescTextStyle,
                            ),
                          ),
                          SizedBox(height: 0.01 * screenHeight),
                          TextFormField(
                            focusNode: faultDescFocusNode,
                            style: kFormFieldStyle,
                            controller: faultDescTextEditingController,
                            maxLength: 200,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              errorMaxLines: 3,
                              hintMaxLines: 3,
                              border: OutlineInputBorder(),
                              hintStyle: kFormFieldHintStyle,
                              hintText: 'Describe fault',
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  widget.tmpFaultDetails(
                                      faultDescTextEditingController.text);
                                });
                              }
                            },
                          ),
                          SizedBox(height: 16),
                          MyUploadPage(key: uploadImageKey),
                          SizedBox(height: 16),
                          isSmallScreen
                              ? buildSalutation()
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                      width: 0.35 * screenWidth,
                                      child: buildSalutation()),
                                ),
                          SizedBox(height: 16),
                          isSmallScreen
                              ? Column(
                                  children: [
                                    buildGivenName(),
                                    SizedBox(height: 16),
                                    buildSurname(),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                          width: 0.34 * screenWidth,
                                          child: buildGivenName()),
                                    ),
                                    SizedBox(width: 0.02 * screenWidth),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                          width: 0.34 * screenWidth,
                                          child: buildSurname()),
                                    )
                                  ],
                                ),
                          SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                text: "Email Address",
                                style: emailAddressTextStyle,
                                children: const [
                                  TextSpan(
                                    text: "*",
                                    style: TextStyle(color: kRed),
                                  ),
                                ],
                              ),
                              key: emailAddressLabelGlobalKey,
                            ),
                          ),
                          SizedBox(height: 0.01 * screenHeight),
                          TextFormField(
                            focusNode: emailAddressFocusNode,
                            style: kFormFieldStyle,
                            controller: emailTextEditingController,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  widget.email(emailTextEditingController.text);
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                scrollToIndex ??= 6;
                                return 'Please enter your email address.';
                              } else {
                                final emailValidator = RegExp(
                                    r"[\S ]+@[\S ]+\.[\S ]*[A-Za-z0-9]$");
                                if (emailValidator.hasMatch(value)) {
                                  return null;
                                } else {
                                  scrollToIndex ??= 6;
                                  return "Please enter a valid email address.";
                                }
                              }
                            },
                            maxLength: 320,
                            decoration: const InputDecoration(
                              errorMaxLines: 3,
                              hintMaxLines: 3,
                              border: OutlineInputBorder(),
                              hintStyle: kFormFieldHintStyle,
                              hintText: 'Enter your email',
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          TextButton(
                            style:
                                TextButton.styleFrom(padding: EdgeInsets.zero),
                            onPressed: () {
                              setState(() {
                                _isChecked = !_isChecked;
                                widget.receiveUpdate(_isChecked);
                              });
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Checkbox(
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    splashRadius: 0,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    value: _isChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        _isChecked = value!;
                                        widget.receiveUpdate(_isChecked);
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'I would like to have the report follow up.',
                                    style: _isChecked
                                        ? TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: kElectricBlue,
                                            fontFeatures: const [
                                              ui.FontFeature
                                                  .proportionalFigures()
                                            ],
                                          )
                                        : TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: kGrey2a,
                                            fontFeatures: const [
                                              ui.FontFeature
                                                  .proportionalFigures()
                                            ],
                                          ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),

          /*Row(),
          Positioned(
            right: 0,
            child: IconButton(
                tooltip: 'Get Current Location',
                onPressed: () {
                  _getCurrentLocation();
                  // this.lat = ,
                  // this.lng = 103.8359,
                  /*setState(() {
                  markers.clear();
                  tappedPoints.clear();
                  tappedPoints.add(LatLng(1.4293, 103.8359));
                  mapController.move(LatLng(1.4293, 103.8359), 5.0);
                });
                // tempLat = 1.4293;
                // tempLat = 103.8359;*/
                },
                icon: const Icon(Icons.location_pin)),
          ),*/

          /*ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blueAccent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
            onPressed: () {
              _getCurrentLocation();
            },
            child: Text("Test Get location"),
          ),*/
          if (_currentAddress != null) Text(_currentAddress),
        ],
      ),
    );
  }

  Column buildSurname() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              text: "Surname",
              style: surnameTextStyle,
              children: const [
                TextSpan(
                  text: "*",
                  style: TextStyle(color: kRed),
                ),
              ],
            ),
            key: surnameLabelGlobalKey,
          ),
        ),
        SizedBox(height: 0.01 * screenHeight),
        TextFormField(
          focusNode: surnameFocusNode,
          style: kFormFieldStyle,
          controller: surnameTextEditingController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              scrollToIndex ??= 5;
              return 'Please enter your surname.';
            }
            return null;
          },
          maxLength: 66,
          decoration: const InputDecoration(
            errorMaxLines: 3,
            hintMaxLines: 3,
            border: OutlineInputBorder(),
            hintStyle: kFormFieldHintStyle,
            hintText: 'Enter your surname',
          ),
        ),
      ],
    );
  }

  Column buildGivenName() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              text: "Given Name",
              style: givenNameTextStyle,
              children: const [
                TextSpan(
                  text: "*",
                  style: TextStyle(color: kRed),
                ),
              ],
            ),
            key: givenNameLabelGlobalKey,
          ),
        ),
        SizedBox(height: 0.01 * screenHeight),
        TextFormField(
          focusNode: givenNameFocusNode,
          style: kFormFieldStyle,
          controller: givenNameTextEditingController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              scrollToIndex ??= 4;
              return 'Please enter your given name.';
            }
            return null;
          },
          maxLength: 66,
          decoration: const InputDecoration(
            errorMaxLines: 3,
            hintMaxLines: 3,
            border: OutlineInputBorder(),
            hintStyle: kFormFieldHintStyle,
            hintText: 'Enter your given name',
          ),
        ),
      ],
    );
  }

  Column buildSalutation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text.rich(
            TextSpan(
              text: "Salutation",
              style: salutationTextStyle,
              children: const [
                TextSpan(
                  text: "*",
                  style: TextStyle(color: kRed),
                ),
              ],
            ),
            key: salutationLabelGlobalKey,
          ),
        ),
        SizedBox(height: 0.01 * screenHeight),
        DropdownButtonFormField(
          items: const [
            DropdownMenuItem(child: Text("Miss"), value: "Miss"),
            DropdownMenuItem(child: Text("Mr."), value: "Mr."),
            DropdownMenuItem(child: Text("Mrs."), value: "Mrs.")
          ],
          onChanged: (String? newValue) {
            setState(() {
              salutationDropdownButtonSelectedValue = newValue;
            });
          },
          value: salutationDropdownButtonSelectedValue,
          focusNode: salutationFocusNode,
          style: TextStyle(
            fontFamily: "Barlow",
            fontSize: 20,
            color: kGrey2a,
            fontWeight: FontWeight.w600,
            fontFeatures: [ui.FontFeature.proportionalFigures()],
          ),
          validator: (value) {
            if (value == null) {
              scrollToIndex ??= 3;
              return 'Please choose a salutation.';
            }
            return null;
          },
          decoration: const InputDecoration(
            errorMaxLines: 3,
            hintMaxLines: 3,
            border: OutlineInputBorder(),
            hintStyle: kFormFieldHintStyle,
            hintText: 'Choose one',
          ),
        ),
      ],
    );
  }

  void _getCurrentLocation(StateSetter setStateForDialog) async {
    // final geolocation = html.window.navigator.geolocation;
    // final position = await geolocation.getCurrentPosition();
    // final latitude = position.coords?.latitude;
    // final longitude = position.coords?.longitude;
    bool locationPermissionGranted = await Geolocator.isLocationServiceEnabled();
    if (!locationPermissionGranted) {
      await Geolocator.requestPermission();
    }
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      forceAndroidLocationManager: true
    );
    final latitude = position.latitude;
    final longitude = position.longitude;
    print(latitude);
    print(longitude);
    reverseGeocode(latitude as double, longitude as double);
    setStateForDialog(() {
      if (!widget.hasMultiplePoints) {
        tappedPoints.clear();
        markers.clear();
        latlngList.clear();
      }
      if (latitude != null && longitude != null) {
        LatLng latlng = LatLng(latitude as double, longitude as double);
        tappedPoints.add(latlng);
        markers = tappedPoints.map((latlng) {
          return Marker(
            width: 50.0,
            height: 50.0,
            point: latlng,
            builder: (ctx) => Container(child: const Icon(Icons.pin_drop)),
          );
        }).toList();
        latlngList.add(latlng);
        // widget.workerUpdate(latlngList);
        mapController?.move(latlng, 13);
      }
    });

    // //Geolocator
    // await _geolocatorPlatform
    //     .getCurrentPosition(locationSettings: LocationSettings())
    //     .then((Position position) {
    //   setState(() {
    //     print(position);
    //     _currentPosition = position;
    // _getAddressFromLatLng(
    //     _currentPosition!.latitude, _currentPosition!.longitude);
    //     if (!widget.hasMultiplePoints) {
    //       tappedPoints.clear();
    //       markers.clear();
    //       latlngList.clear();
    //     }

    //     tappedPoints.add(
    //         LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
    //     latlngList.add(
    //         LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
    //     widget.workerUpdate(latlngList);
    //   });
    // }).catchError((e) {
    //   print(e);
    // });
  }

  void _handleCreate() {
    setState(() {
      isSetSelectedLocationMarker = true;
      tappedPoints.add(LatLng(widget.lat, widget.lng));
      latlngList.add(LatLng(widget.lat, widget.lng));
      widget.workerUpdate(latlngList);
    });
    // Future.delayed(Duration(milliseconds: 800), () {
    //   setState(() {
    //     isSetSelectedLocationMarker = true;
    //     tappedPoints.add(LatLng(widget.lat, widget.lng));
    //     latlngList.add(LatLng(widget.lat, widget.lng));
    //     widget.workerUpdate(latlngList);
    //   });
    // });
  }

  //get the building using building code from scanning QR Code and populate fields
  Future<void> getBuildingFromQrAndPopulate(String? buildingCode) async {
    Map<String, dynamic>? buildingFromQr;
    if (buildingCode != null) {
      buildingFromQr =
          await backendService.getBuildingNameByBuildingCode(buildingCode);
    } else {
      buildingFromQr = null;
    }
    if (buildingFromQr != null) {
      //populate building name and building code
      locationTextEditingController.text =
          buildingFromQr['buildingName']!.toString();
      buildingCodeVal = buildingFromQr['buildingCode'];
      setState(() {
        //populate parameters for passing buildingcode
        widget.tmpBuildingCodeVal(buildingCodeVal);

        //populate map tapped points
        if (!widget.hasMultiplePoints) {
          tappedPoints.clear();
          markers.clear();
          latlngList.clear();
        }
        tappedPoints.add(LatLng(buildingFromQr!['lat'], buildingFromQr['lon']));
        markers = tappedPoints.map((latlng) {
          return Marker(
            width: 50.0,
            height: 50.0,
            point: latlng,
            builder: (ctx) => Container(child: const Icon(Icons.pin_drop)),
          );
        }).toList();
        latlngList.add(LatLng(buildingFromQr['lat'], buildingFromQr['lon']));
        widget.workerUpdate(latlngList);
      });
    }
  }

  Widget _buildMapDialog(StateSetter setStateForDialog) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.only(top: 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(height: 25),
                  Positioned(
                      child: IconButton(
                          splashRadius: 5,
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      top: -7,
                      right: -7),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                child: Container(
                  padding: EdgeInsets.all(5),
                  color: kGreyF0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: isSmallScreen
                              ? 0.6 * screenWidth
                              : 0.3 * screenWidth,
                          child: TypeAheadField(
                              textFieldConfiguration: TextFieldConfiguration(
                                maxLines: null,
                                style: kFormFieldStyle,
                                controller: mapLocationTextEditingController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  errorMaxLines: 3,
                                  hintMaxLines: 3,
                                  border: OutlineInputBorder(),
                                  hintStyle: kFormFieldHintStyle,
                                  hintText: "Tap on map to find location",
                                ),
                              ),
                              suggestionsCallback: (pattern) async {
                                return await backendService
                                    .searchForOneMapAddressData(pattern);
                              },
                              itemBuilder: (context, Map item) {
                                String itemBuildingName =
                                    assignLocationInformation(item["BUILDING"]);
                                String itemBlock =
                                    assignLocationInformation(item["BLK_NO"]);
                                String itemRoad =
                                    assignLocationInformation(item["ROAD_NAME"]);
                                String itemPostalCode =
                                    assignLocationInformation(item["POSTAL"]);
                                String itemFullLocationInformation =
                                    itemBuildingName;
                                if (itemBuildingName.isNotEmpty &&
                                    (itemBlock.isNotEmpty ||
                                        itemRoad.isNotEmpty ||
                                        itemPostalCode.isNotEmpty)) {
                                  itemFullLocationInformation += ", ";
                                }
                                if (itemBlock.isNotEmpty) {
                                  itemFullLocationInformation += "BLK ";
                                }
                                itemFullLocationInformation += itemBlock;
                                if (itemBlock.isNotEmpty &&
                                    (itemRoad.isNotEmpty ||
                                        itemPostalCode.isNotEmpty)) {
                                  itemFullLocationInformation += " ";
                                }
                                itemFullLocationInformation += itemRoad;
                                if (itemRoad.isNotEmpty &&
                                    itemPostalCode.isNotEmpty) {
                                  itemFullLocationInformation += " ";
                                }
                                if (itemPostalCode.isNotEmpty) {
                                  itemFullLocationInformation += "S(";
                                }
                                itemFullLocationInformation += itemPostalCode;
                                if (itemPostalCode.isNotEmpty) {
                                  itemFullLocationInformation += ")";
                                }
                                return ListTile(
                                  title: Text(itemFullLocationInformation),
                                );
                              },
                              onSuggestionSelected: (Map item) {
                                String itemBuildingName =
                                    assignLocationInformation(item["BUILDING"]);
                                String itemBlock =
                                    assignLocationInformation(item["BLK_NO"]);
                                String itemRoad =
                                    assignLocationInformation(item["ROAD_NAME"]);
                                String itemPostalCode =
                                    assignLocationInformation(item["POSTAL"]);
                                String itemFullLocationInformation =
                                    itemBuildingName;
                                if (itemBuildingName.isNotEmpty &&
                                    (itemBlock.isNotEmpty ||
                                        itemRoad.isNotEmpty ||
                                        itemPostalCode.isNotEmpty)) {
                                  itemFullLocationInformation += ", ";
                                }
                                if (itemBlock.isNotEmpty) {
                                  itemFullLocationInformation += "BLK ";
                                }
                                itemFullLocationInformation += itemBlock;
                                if (itemBlock.isNotEmpty &&
                                    (itemRoad.isNotEmpty ||
                                        itemPostalCode.isNotEmpty)) {
                                  itemFullLocationInformation += " ";
                                }
                                itemFullLocationInformation += itemRoad;
                                if (itemRoad.isNotEmpty &&
                                    itemPostalCode.isNotEmpty) {
                                  itemFullLocationInformation += " ";
                                }
                                if (itemPostalCode.isNotEmpty) {
                                  itemFullLocationInformation += "S(";
                                }
                                itemFullLocationInformation += itemPostalCode;
                                if (itemPostalCode.isNotEmpty) {
                                  itemFullLocationInformation += ")";
                                }
                                //update api local variables
                                apiStatusCode = 0;
                                fullLocationInformation =
                                    itemFullLocationInformation;
                                //set map location text
                                mapLocationTextEditingController.text =
                                    fullLocationInformation;
                                //set latlng marker on map
                                setStateForDialog(() {
                                  tappedPoints.clear();
                                  markers.clear();
                                  latlngList.clear();
                                  tappedPoints.add(LatLng(
                                      double.parse(item["LATITUDE"]),
                                      double.parse(item["LONGITUDE"])));
                                  markers = tappedPoints.map((latlng) {
                                    return Marker(
                                      width: 50.0,
                                      height: 50.0,
                                      point: latlng,
                                      builder: (ctx) => Container(
                                          child: const Icon(Icons.pin_drop)),
                                    );
                                  }).toList();
                                  latlngList.add(tappedPoints[0]);
                                  mapController?.move(latlngList[0], 13);
                                  //check postal code of item with master list
                                  backendService
                                      .getSuggestions(postalCode: itemPostalCode)
                                      .then((value) =>
                                          buildingWithMatchingPostalCode =
                                              value[0]);
                                });
                                //update api status code to run addDetailsToForm() after check postal code is done
                                apiStatusCode = 200;
                              }),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Get Current Location',
                        onPressed: () {
                          _getCurrentLocation(setStateForDialog);
                        },
                        icon: const Icon(Icons.my_location_rounded),
                        iconSize: 20,
                        color: kRed,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
                child: SizedBox(
                  height: 350,
                  child: FlutterMap(
                    options: MapOptions(
                      onMapCreated: (c) {
                        mapController = c;
                      },
                      maxBounds: LatLngBounds(
                          LatLng(1.49323, 104.11475), LatLng(1.16, 103.579248)),
                      center: latlngList[0],
                      minZoom: 12.5,
                      maxZoom: 18,
                      zoom: 13.0,
                      onTap: (tapPosition, latlng) async {
                        setStateForDialog(() {
                          if (!widget.hasMultiplePoints) {
                            tappedPoints.clear();
                            markers.clear();
                            latlngList.clear();
                          }
                          print(latlng);
                          tappedPoints.add(latlng);
                          markers = tappedPoints.map((latlng) {
                            return Marker(
                              width: 50.0,
                              height: 50.0,
                              point: latlng,
                              builder: (ctx) =>
                                  Container(child: const Icon(Icons.pin_drop)),
                            );
                          }).toList();
                          latlngList.add(latlng);
                          // widget.workerUpdate(latlngList);
                        });
                        //onemap reverse geocode
                        reverseGeocode(latlng.latitude, latlng.longitude);
                      },
                    ),
                    layers: [
                      TileLayerOptions(
                        urlTemplate:
                            'https://maps-{s}.onemap.sg/v3/Original/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                        additionalOptions: {
                          'bounds': 'mapBounds',
                          "center": "center",
                        },
                      ),
                      MarkerLayerOptions(markers: markers),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: addDetailsToForm,
                        child: Text("Select Location"),
                        style: ElevatedButton.styleFrom(
                          primary: kElectricBlue,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          padding: EdgeInsets.all(20),
                        )),
                    Spacer(),
                    OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          primary: kElectricBlue,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          side: BorderSide(color: kElectricBlue),
                          padding: EdgeInsets.all(20),
                        ),
                        child: Text("Cancel"))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void addDetailsToForm() {
    if (apiStatusCode == 200) {
      //update text fields for location, other location and building code
      if (buildingWithMatchingPostalCode["buildingName"] == "Others") {
        locationTextEditingController.text = "Others";
        widget.tmpBuildingCodeVal("Others");
        otherLocationTextEditingController.text = fullLocationInformation;
        widget.workerUpdate(latlngList);
        setState(() {
          isOtherLocationVisibility = true;
        });
      } else {
        locationTextEditingController.text =
            buildingWithMatchingPostalCode["buildingName"];
        widget
            .tmpBuildingCodeVal(buildingWithMatchingPostalCode["buildingCode"]);
        otherLocationTextEditingController.text = "";
        widget.workerUpdate(latlngList);
        setState(() {
          isOtherLocationVisibility = false;
        });
      }
      Navigator.of(context).pop();
    } else {
      locationTextEditingController.text = "";
      widget.tmpBuildingCodeVal("");
      otherLocationTextEditingController.text = "";
      widget.workerUpdate(latlngList);
      setState(() {
        isOtherLocationVisibility = false;
      });
    }
  }
}
