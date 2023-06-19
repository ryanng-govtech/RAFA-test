import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rafa_app/contants.dart';
import 'package:rafa_app/js_libraries/google_analytics_4_js.dart';
import 'package:rafa_app/sgds_appbar.dart';
import 'package:rafa_app/sgds_footer.dart';
import 'JTCOneMap.dart';
import 'package:latlong2/latlong.dart';

import 'js_libraries/wogaa_js.dart';
import 'location.dart';
import 'services/locationdata.dart';
import 'summary.dart';

class LocationPage extends StatefulWidget {
  final String contactNumber;
  final String accessToken;
  final String? building;
  final String? spaceId;
  final String? space;

  const LocationPage({
    Key? key,
    required this.contactNumber,
    required this.accessToken,
    this.building,
    this.spaceId,
    this.space,
  }) : super(key: key);

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late BackendService backendService;

  final ScrollController _pageScrollController = ScrollController();
  // Position? _currentPosition;
  String _currentAddress = "";
  final tmpLocationTextfield = new TextEditingController();
  final myLocationDetailsCtr = new TextEditingController();
  final myFaultDesc = new TextEditingController();
  final key = GlobalKey<JTCMapState>();

  List<LatLng> latLongList = [];
  String tmpBuildingCode = "";
  String tmpFaultDetails = "";
  String tmpEmail = "";
  bool tmpRec = false;

  void updateList(List<LatLng> latlngSlave) async {
    try {
      latLongList = latlngSlave;
    } catch (e) {
      log("Update lng  no val");
    }
  }

  void updateBuildingCode(String buildingCode) async {
    try {
      tmpBuildingCode = buildingCode;
    } catch (e) {
      log("Update lng  no val");
    }
  }

  void updateFaultDetails(String FaultDetail) async {
    try {
      tmpFaultDetails = FaultDetail;
    } catch (e) {
      log("Update lng  no val");
    }
  }

  void updateEmailDetails(String email) async {
    try {
      tmpEmail = email;
    } catch (e) {
      log("Update lng  no val");
    }
  }

  void updateRecDetails(bool receiveUpdates) async {
    try {
      tmpRec = receiveUpdates;
    } catch (e) {
      log("Update lng  no val");
    }
  }

  String DDLocationVal = "one-north";
  String buildingCode = "";
  List dataLocation = List.empty();
  List<DropdownMenuItem> itemsLocation = [];
  Future<List<LocationModel>> getData(filter) async {
    /*var response = await Dio().get(
      "https://5d85ccfb1e61af001471bf60.mockapi.io/user",
      queryParameters: {"filter": filter},
    );*/

    var response = await Dio().get(
      "https://jtcfemapp.azurewebsites.net/rafa/api/RAFAEstates",
      queryParameters: {"filter": filter},
    );

    final data = response.data;
    if (data != null) {
      return LocationModel.fromJsonList(data);
    }

    return [];
  }

  @override
  void initState() {
    super.initState();
    // wogaaStartTransactionalService("femjtc-4523");
    backendService = BackendService(widget.accessToken);
    if (kIsGa4Enabled) {
      ga4PushData(GoogleAnalytics4Data(
          event: 'page_view',
          page_title: 'Step 1 of 2: Enter Fault Information'));
    }
  }

  @override
  void dispose() {
    backendService.myHttpClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenWidth < 800 ? true : false;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: SgdsAppbar(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Padding(
                padding: EdgeInsets.only(left: 0.08 * screenWidth),
                child: const Text('Report-A-Fault'))),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Scrollbar(
            controller: _pageScrollController,
            child: SingleChildScrollView(
              controller: _pageScrollController,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                left: 0.08 * screenWidth,
                                right: 0.08 * screenWidth,
                                top: 0.05 * screenHeight),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Enter Fault Information",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Step 1 of 2",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text.rich(TextSpan(
                                      text: "*",
                                      style: Theme.of(context)
                                          .textTheme
                                          .overline!
                                          .copyWith(
                                            color: kRed,
                                          ),
                                      children: [
                                        TextSpan(
                                          text: "Denotes mandatory fields.",
                                          style: Theme.of(context)
                                              .textTheme
                                              .overline!
                                              .copyWith(
                                                  color: kGrey66,
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ])),
                                ),
                              ],
                            ),
                          ),
                          JTCMap(
                            key: key,
                            accessToken: widget.accessToken,
                            building: widget.building,
                            spaceId: widget.spaceId,
                            space: widget.space,
                            workerUpdate: updateList,
                            tmpBuildingCodeVal: updateBuildingCode,
                            tmpFaultDetails: updateFaultDetails,
                            isLatLngSelected: true,
                            email: updateEmailDetails,
                            receiveUpdate: updateRecDetails,
                          ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //       color: Colors.blue,
                          //       borderRadius: BorderRadius.circular(20)),
                          // child:
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen
                                      ? 0.08 * screenWidth
                                      : 0.15 * screenWidth),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: kElectricBlue,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                ),
                                onPressed: () async {
                                  bool estateExists = await backendService
                                      .checkBuildingExists(key.currentState
                                          ?.locationTextEditingController.text);
                                  if (!estateExists) {
                                    setState(() {
                                      key.currentState?.scrollToIndex ??= 0;
                                      key.currentState?.locationValidator =
                                          "Select a location from the dropdown list.";
                                    });
                                  } else {
                                    setState(() {
                                      key.currentState?.locationValidator =
                                          null;
                                    });
                                  }
                                  if (key.currentState!.formKey.currentState!
                                      .validate()) {
                                    if (key.currentState!
                                            .isOtherLocationVisibility ==
                                        false) {
                                      key
                                          .currentState!
                                          .otherLocationTextEditingController
                                          .text = "";
                                    }
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SummaryPage(
                                                  buildingName: key
                                                      .currentState!
                                                      .locationTextEditingController
                                                      .text,
                                                  otherLocation: key
                                                      .currentState
                                                      ?.otherLocationTextEditingController
                                                      .text,
                                                  latitude:
                                                      latLongList[0].latitude,
                                                  longitude:
                                                      latLongList[0].longitude,
                                                  spaceId:
                                                      key.currentState!.spaceId,
                                                  additionalLocationDetails: key
                                                      .currentState!
                                                      .additionalLocationDetailsTextEditingController
                                                      .text,
                                                  faultDetails: tmpFaultDetails,
                                                  imageList: key
                                                      .currentState!
                                                      .uploadImageKey
                                                      .currentState!
                                                      .imageFileList,
                                                  salutation: key.currentState!
                                                      .salutationDropdownButtonSelectedValue!,
                                                  givenName: key
                                                      .currentState!
                                                      .givenNameTextEditingController
                                                      .text,
                                                  surname: key
                                                      .currentState!
                                                      .surnameTextEditingController
                                                      .text,
                                                  email: tmpEmail,
                                                  contactNumber:
                                                      widget.contactNumber,
                                                  isReceiveUpdate: tmpRec,
                                                  buildingCode: tmpBuildingCode,
                                                  accessToken:
                                                      widget.accessToken,
                                                )));
                                  } else {
                                    if (key.currentState!
                                        .validateFailedForOtherLocation) {
                                      Scrollable.ensureVisible(key
                                          .currentState!
                                          .fieldLabelsGlobalKeysList[1]
                                          .currentContext!);
                                      key.currentState!
                                              .validateFailedForOtherLocation =
                                          false;
                                      key.currentState?.scrollToIndex = null;
                                    } else if (key
                                            .currentState?.scrollToIndex !=
                                        null) {
                                      Scrollable.ensureVisible((key.currentState
                                                  ?.fieldLabelsGlobalKeysList[
                                              key.currentState!
                                                  .scrollToIndex!])!
                                          .currentContext!);
                                      print(key.currentState?.scrollToIndex);
                                      key.currentState?.scrollToIndex = null;
                                    }
                                  }
                                },
                                child: const Text("Continue"),
                                // ),
                              ),
                            ),
                          ),
                          SizedBox(height: 0.05 * screenHeight),
                          const SgdsFooter()
                        ],
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  // _getCurrentLocation() async {
  //   await Geolocator.getCurrentPosition(
  //           desiredAccuracy: LocationAccuracy.best,
  //           forceAndroidLocationManager: true)
  //       .then((Position position) {
  //     setState(() {
  //       _currentPosition = position;
  //       _getAddressFromLatLng();
  //     });
  //   }).catchError((e) {
  //     print(e);
  //   });
  // }

  // _getAddressFromLatLng() async {
  //   try {
  //     List<Placemark> placemarks = await placemarkFromCoordinates(
  //         _currentPosition!.latitude, _currentPosition!.longitude);

  //     Placemark place = placemarks[0];
  //     setState(() {
  //       _currentAddress =
  //           // ignore: prefer_adjacent_string_concatenation
  //           "Address: " +
  //               "${place.street} \n" +
  //               "Postal Code: " +
  //               "${place.postalCode} \n" +
  //               "Country: " +
  //               "${place.country} \n" +
  //               "Latitude: " +
  //               "${_currentPosition!.latitude} \n" +
  //               "Longtitude: " +
  //               "${_currentPosition!.longitude}";
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}
