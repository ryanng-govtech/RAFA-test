import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rafa_app/error_page.dart';
import 'package:rafa_app/services/recaptcha_service.dart';
import 'package:rafa_app/sgds_appbar.dart';
import 'package:rafa_app/sgds_footer.dart';
import 'package:rafa_app/widgets/loading_dialog.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

import 'contants.dart';
import 'location_page.dart';
import 'package:http/http.dart' as http;

class RAFAHomePage extends StatefulWidget {
  final String? building;
  final String? spaceId;
  final String? space;

  const RAFAHomePage({Key? key, this.building, this.spaceId, this.space})
      : super(key: key);

  @override
  _RAFAHomePageState createState() => _RAFAHomePageState();
}

class _RAFAHomePageState extends State<RAFAHomePage> {
  final ScrollController _pageScrollController = ScrollController();
  final _cntNumFormKey = GlobalKey<FormFieldState>();
  final myContactCntr = TextEditingController();
  final myOTPCntr = TextEditingController();
  bool visibilityFaultButton = false;
  bool visibility = false;
  String getOTPURL = APIPREFIX + "/api/RAFAOTPs/GenerateOTPByMobileNumber";

  String getNewOTPURL = APIPREFIX + "/api/RAFAOTPs/ResendOTPByMobileNumber";

  String verifyOTP = APIPREFIX + "/api/RAFAOTPs/VerifyOTPCode?phoneNum=";

  FocusNode cntNumFocusNode = FocusNode();
  FocusNode otpFocusNode = FocusNode();
  TextStyle cntNumTextStyle = kFieldLabelStyle;
  TextStyle otpTextStyle = kFieldLabelStyle;

  final CountdownController countdownController =
      CountdownController(autoStart: true);
  double timeCount = 0;
  String otpText = "";

  final mobileNumberGlobalKey = GlobalKey();

  bool isLoading = false;

  Future<void> getOTP(
    contactNumber,
  ) async {
    Map<String, String> queryParams = {
      "MobileNumber": contactNumber.toString(),
    };
    var response =
        await http.post(Uri.parse(getOTPURL + "?mobileNumber=" + contactNumber),
            //body: (queryParams),
            headers: {
          "Content-Type": "application/json",
        });
    if (response.statusCode == 200) {
      var otp = json.decode(response.body)["otp"];
      setState(() {
        otpText = otp.toString();
      });
    } else if (response.statusCode == 401 ||
        response.statusCode == 404 ||
        response.statusCode == 500) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ErrorPage(statusCode: response.statusCode)));
    }

    // log("Response: ${response2.statusCode} - ${response2.body}", name: "submitInspectionReportDate");
  }

  Future<void> resendOTP(
    contactNumber,
  ) async {
    Map<String, String> queryParams = {
      "MobileNumber": contactNumber.toString(),
    };
    var response = await http
        .post(Uri.parse(getNewOTPURL + "?mobileNumber=" + contactNumber),
            //body: (queryParams),
            headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      // var otp = json.decode(response.body)["otp"];
      // setState(() {
      //   otpText = otp.toString();
      // });
    } else if (response.statusCode == 401 ||
        response.statusCode == 404 ||
        response.statusCode == 500) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ErrorPage(statusCode: response.statusCode)));
    }
    // log("Response: ${response2.statusCode} - ${response2.body}", name: "submitInspectionReportDate");
  }

  Future<void> postOTP(contactNumber, OTP) async {
    Map<String, dynamic> queryParams = {
      "MobileNumber": contactNumber.toString(),
      "OTPCode": int.parse(OTP),
    };
    var response =
        await http.post(Uri.parse(verifyOTP + contactNumber + "&otp=" + OTP),
            //body: (queryParams),
            headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      var tmpToken = json.decode(response.body);
      print(tmpToken['accessToken']);
      setState(() {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LocationPage(
                    contactNumber: myContactCntr.text,
                    accessToken: tmpToken['accessToken'],
                    building: widget.building,
                    spaceId: widget.spaceId,
                    space: widget.space)));
      });
    } else if (response.statusCode == 401 ||
        response.statusCode == 404 ||
        response.statusCode == 500) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ErrorPage(statusCode: response.statusCode)));
    } else {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Please enter a valid mobile and OTP."),
          );
        },
      );
    }
    log('${response.body}' + '${response.statusCode}');
    // log("Response: ${response2.statusCode} - ${response2.body}", name: "submitInspectionReportDate");
  }

  @override
  void initState() {
    super.initState();
    cntNumFocusNode.addListener(() => setState(() {
          cntNumTextStyle = cntNumFocusNode.hasFocus
              ? kFieldLabelStyle.copyWith(color: kElectricBlue)
              : kFieldLabelStyle;
        }));
    otpFocusNode.addListener(() => setState(() {
          otpTextStyle = otpFocusNode.hasFocus
              ? kFieldLabelStyle.copyWith(color: kElectricBlue)
              : kFieldLabelStyle;
        }));
    print(widget.building);
    print(widget.space);
  }

  @override
  void dispose() {
    cntNumFocusNode.dispose();
    otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenWidth < 800 ? true : false;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
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
                            padding: EdgeInsets.symmetric(
                                vertical: 0.05 * screenHeight,
                                horizontal: isSmallScreen
                                    ? 0.08 * screenWidth
                                    : 0.15 * screenWidth),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "Verify Mobile Number",
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.w500,
                                        fontFeatures: [
                                          ui.FontFeature.proportionalFigures()
                                        ],
                                      ),
                                    ),
                                    // SelectableText("[$otpText]"),
                                  ],
                                ),
                                const Text(
                                    'Please enter your mobile number for verification, OTP will be sent via SMS.',
                                    textAlign: TextAlign.center),
                                const SizedBox(
                                  height: 16,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Mobile Number",
                                      style: cntNumTextStyle,
                                      children: const [
                                        TextSpan(
                                          text: "*",
                                          style: TextStyle(color: kRed),
                                        ),
                                      ],
                                    ),
                                    key: mobileNumberGlobalKey,
                                  ),
                                ),
                                SizedBox(height: 0.01 * screenHeight),
                                TextFormField(
                                  key: _cntNumFormKey,
                                  style: kFormFieldStyle,
                                  focusNode: cntNumFocusNode,
                                  controller: myContactCntr,
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.length < 8) {
                                      return 'Please enter a valid contact number.';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                  ],
                                  maxLength: 8,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintStyle: kFormFieldHintStyle,
                                    hintText: 'Enter your mobile number',
                                    errorMaxLines: 3,
                                    hintMaxLines: 3,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: kElectricBlue,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              const EdgeInsets.all(20))),
                                      onPressed: () async {
                                        if (_cntNumFormKey.currentState!
                                            .validate()) {
                                          if (await RecaptchaService
                                              .isNotaBot()) {
                                            if (visibility == false) {
                                              getOTP(myContactCntr.text);
                                              setState(() {
                                                visibility = true;
                                              });
                                            } else if (timeCount == 0) {
                                              countdownController.restart();
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const AlertDialog(
                                                    content: Text(
                                                        "A new OTP is sent to your mobile number."),
                                                  );
                                                },
                                              );
                                              getOTP(myContactCntr.text);
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const AlertDialog(
                                                    content: Text(
                                                        "Please request for OTP again after 1 minute from your previous attempt."),
                                                  );
                                                },
                                              );
                                            }
                                          }
                                        } else {
                                          Scrollable.ensureVisible(
                                              mobileNumberGlobalKey
                                                  .currentContext!);
                                        }
                                      },
                                      child: const Text("Retrieve OTP")),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Visibility(
                                    visible: visibility,
                                    child: Column(children: <Widget>[
                                      const SizedBox(height: 16.0),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Please enter the SMS OTP sent to your mobile number',
                                          style: otpTextStyle,
                                        ),
                                      ),
                                      SizedBox(height: 0.01 * screenHeight),
                                      TextField(
                                        style: kFormFieldStyle,
                                        focusNode: otpFocusNode,
                                        controller: myOTPCntr,
                                        maxLength: 6,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintStyle: kFormFieldHintStyle,
                                            hintText: 'Enter 6 digits OTP'),
                                      ),
                                      const Text('Did not receive an OTP?'),
                                      Countdown(
                                          controller: countdownController,
                                          seconds: 60,
                                          build: (context, time) {
                                            timeCount = time;
                                            return const SizedBox.shrink();
                                          }),
                                      TextButton(
                                        onPressed: () async {
                                          myOTPCntr.text = "";
                                          if (await RecaptchaService
                                              .isNotaBot()) {
                                            if (timeCount == 0) {
                                              countdownController.restart();
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const AlertDialog(
                                                    content: Text(
                                                        "A new OTP is sent to your mobile number."),
                                                  );
                                                },
                                              );
                                              resendOTP(myContactCntr.text);
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const AlertDialog(
                                                    content: Text(
                                                        "Please request for OTP again after 1 minute from your previous attempt."),
                                                  );
                                                },
                                              );
                                            }
                                          }
                                        },
                                        child: const Text(
                                          'Resend OTP',
                                          style:
                                              TextStyle(color: kElectricBlue),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: kElectricBlue,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                              padding:
                                                  MaterialStateProperty.all(
                                                      const EdgeInsets.all(
                                                          20))),
                                          onPressed: () async {
                                            if (isLoading == true) {
                                              return;
                                            }
                                            isLoading = true;
                                            if (myOTPCntr.text == "" ||
                                                myOTPCntr.text.length != 6) {
                                              myOTPCntr.text = "";
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const AlertDialog(
                                                    content:
                                                        Text("Invalid OTP!"),
                                                  );
                                                },
                                              );
                                            } else {
                                              if (await RecaptchaService
                                                  .isNotaBot()) {
                                                showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (BuildContext context) {
                                                      return const LoadingDialog(
                                                        backgroundColor:
                                                            Colors.black54,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: SizedBox(
                                                            width: 100,
                                                            height: 100,
                                                            child:
                                                                CircularProgressIndicator(
                                                              backgroundColor:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    });
                                                postOTP(myContactCntr.text,
                                                    myOTPCntr.text);
                                              }
                                            }
                                            isLoading = false;
                                          },
                                          child: const Text("Submit"),
                                        ),
                                      ),
                                    ])),
                              ],
                            )),
                        SizedBox(height: 0.3 * screenHeight),
                        const SgdsFooter(),
                      ],
                    ),
                  ),
                ]),
          ),
        )),
      ),
    );
  }
}

/*

Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                child: Column(
              children: [
                /*ListView(
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
                          DDLocVal = print!.id;
                          log(DDLocVal.toString());
                        });
                      },
                      showSearchBox: true,
                    ),
                    Divider(),
                  ],
                ),*/
                //const Text("Welcome to  map"),
                JTCMap(
                  workerUpdate: updateList,
                  tmpLocationVal: updateEstate,
                  tmpAddLocation: updateaddEstateDetails,
                  tmpFaultDetails: updateFaultDetails,
                  tmpAddress: updateAddress,
                  isLatLngSelected: true,
                  tmpEstateName: updateEstateDetails,
                  name: updateNameDetails,
                  email: updateEmailDetails,
                  receiveUpdate: updateRecDetails,
                ),

                /*Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 2),
                            child: TextFormField(
                              controller: myLocationDetailsCtr,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the location details.';
                                }
                                return null;
                              },
                              maxLength: 50,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'E.g. Level 1 Male Toilet',
                                labelText: "Additional Location Details",
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 2),
                            child: TextFormField(
                              controller: myFaultDesc,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the location details.';
                                }
                                return null;
                              },
                              maxLength: 200,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'E.g. Crack ceiling',
                                labelText: "Fault Descriptions",
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),*/
                /*ElevatedButton(
                    onPressed: () {
                      setState(() {
                        log("LAT LONG VALUES: " + latLongList[0].toString());
                      });
                    },
                    child: Text("Retrive Value")),
                Text(latLongList.isNotEmpty
                    ? "LAT LONG VALUES: " + latLongList[0].toString()
                    : "-"),*/
              ],
            )),
            /*if (_currentAddress != null) Text(_currentAddress),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0)),
                ),
              ),
              //onPressed: _pushSaved,
              onPressed: () {
                _getCurrentLocation();
              },
              child: Text("Get location"),
            ),*/
            Container(
              height: 50,
              width: 250,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyUploadPage(
                              DDLocVal: tmpEstate,
                              myLocDetCntr: tmpEstateAddDetails,
                              myFaultDetCntr: tmpFaultDetails,
                              myEstateName: tmpEstateName,
                              name: tmpName,
                              email: tmpEmail,
                              receiveUpdates: tmpRec,
                              contactNumber: widget.contactNumber)));
                },
                child: const Text("Proceed"),
              ),
            ),
          ],
        ),
      ),*/
