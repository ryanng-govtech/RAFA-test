import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:rafa_app/error_page.dart';
import 'package:rafa_app/main.dart';
import 'package:rafa_app/services/recaptcha_service.dart';
import 'package:rafa_app/sgds_appbar.dart';
import 'package:rafa_app/sgds_footer.dart';
import 'package:rafa_app/thankyou_page.dart';
import 'package:rafa_app/widgets/checkbox_list_tile_formfield.dart';
import 'package:rafa_app/widgets/loading_dialog.dart';
import 'package:rafa_app/widgets/summary_fieldgroup.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contants.dart';
import 'js_libraries/google_analytics_4_js.dart';

class SummaryPage extends StatefulWidget {
  final String salutation;
  final String givenName;
  final String surname;
  final String contactNumber;
  final String email;
  final bool isReceiveUpdate;
  final String buildingCode;
  final String additionalLocationDetails;
  final String faultDetails;
  final List<XFile> imageList;
  final String accessToken;
  final String buildingName;
  final String? otherLocation;
  final double latitude;
  final double longitude;
  final String? spaceId;

  const SummaryPage({
    Key? key,
    required this.salutation,
    required this.givenName,
    required this.surname,
    required this.contactNumber,
    required this.email,
    required this.isReceiveUpdate,
    required this.buildingCode,
    required this.buildingName,
    this.otherLocation,
    required this.additionalLocationDetails,
    required this.faultDetails,
    required this.imageList,
    required this.accessToken,
    required this.latitude,
    required this.longitude,
    this.spaceId,
  }) : super(key: key);

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final ScrollController _pageScrollController = ScrollController();
  String faultDetails = "";
  String contactDetails = "";
  late String jtcCaseId;

  String urlPostFault = APIPREFIX + "/api/RAFAFaultReports/CreateNewFault";

  final formFieldKey = GlobalKey<FormFieldState>();

  ScrollController imageScrollController = ScrollController();

  bool isLoading = false;

  Future<void> submitReport(
      {buildingCode,
      otherLocation,
      locationDetails,
      faultDescription,
      salutation,
      givenName,
      surname,
      contactNumber,
      emailAddress,
      isReceiveUpdate,
      reportStatus,
      latitude,
      longitude,
      spaceId}) async {
    Map<String, dynamic> queryParams = {
      "buildingCode": (buildingCode),
      "otherLocation": otherLocation.toString(),
      "locationDetails": locationDetails.toString(),
      "faultDescription": faultDescription.toString(),
      "salutation": salutation.toString(),
      "givenName": givenName.toString(),
      "surname": surname.toString(),
      "contactNumber": contactNumber.toString(),
      "emailAddress": emailAddress.toString(),
      "isReceiveUpdate": isReceiveUpdate,
      "reportStatus": reportStatus,
      "latitude": (latitude as num).toStringAsFixed(6),
      "longitude": (longitude as num).toStringAsFixed(6),
      "spaceId": spaceId.toString(),
    };
    var request = http.MultipartRequest('POST', Uri.parse(urlPostFault));
    request = jsonToFormData(request, queryParams);
    request.headers['Authorization'] = 'Bearer ' + widget.accessToken;
    request.headers['Content-Type'] = 'multipart/form-data; charset=utf-8';
    if (widget.imageList.isNotEmpty) {
      for (int i = 0; i < widget.imageList.length; i++) {
        request.files.add(http.MultipartFile.fromBytes(
            'image' + i.toString(), await widget.imageList[i].readAsBytes(),
            filename: "image$i." +
                widget.imageList[i].mimeType.toString().split('/').last));
      }
    }
    final response = await request.send();
    log("Response: ${response.statusCode}");
    if (response.statusCode == 200) {
      var responseFromStream = await http.Response.fromStream(response);
      var body = json.decode(responseFromStream.body);
      jtcCaseId = body["jtcCaseId"];
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ThankYouScreen(
                  contactNumber: widget.contactNumber,
                  accessToken: widget.accessToken,
                  jtcCaseId: jtcCaseId)));
    } else {
      navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => ErrorPage(statusCode: response.statusCode)));
    }
    isLoading = false;
    // var response2 = await http
    //     .post(Uri.parse(urlPostFault), body: jsonEncode(queryParams), headers: {
    //   "Content-Type": "application/json",
    //   'Authorization': 'Bearer ' + widget.accessToken
    // });
    // log("Response: ${response2.statusCode} - ${response2.body}", name: "submitInspectionReportDate");
  }

  jsonToFormData(http.MultipartRequest request, Map<String, dynamic> data) {
    for (var key in data.keys) {
      if (data[key] == null || data[key] == "null") {
        request.fields[key] = "";
      } else {
        request.fields[key] = data[key].toString();
      }
    }
    return request;
  }

  @override
  void initState() {
    super.initState();
    if (kIsGa4Enabled) {
      ga4PushData(GoogleAnalytics4Data(
          event: 'page_view', page_title: 'Step 2 of 2: Fault Report Summary'));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isSmallScreen = screenWidth < 800;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: SgdsAppbar(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                  padding: EdgeInsets.only(left: 0.08 * screenWidth),
                  child: const Text('Report-A-Fault')))),
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
                    Padding(
                      padding: EdgeInsets.only(
                          left: 0.08 * screenWidth,
                          right: 0.08 * screenWidth,
                          top: 0.05 * screenHeight),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Fault Report Summary",
                                style: Theme.of(context).textTheme.headline5),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Step 2 of 2",
                                style: Theme.of(context).textTheme.headline6),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 0.08 * screenWidth,
                            right: 0.08 * screenWidth,
                            top: 0.05 * screenHeight),
                        child: Column(
                          children: <Widget>[
                            SummaryFieldGroup(
                              label: "Location",
                              field: widget.buildingName,
                            ),
                            const SizedBox(height: 4),
                            (widget.otherLocation == null ||
                                    widget.otherLocation!.isEmpty)
                                ? const SizedBox.shrink()
                                : SummaryFieldGroup(
                                    label: "Other Location",
                                    field: widget.otherLocation!),
                            const SizedBox(height: 4),
                            SummaryFieldGroup(
                                label: "Additional Location Details",
                                field: widget.additionalLocationDetails),
                            const SizedBox(height: 4),
                            SummaryFieldGroup(
                                label: "Fault Details",
                                field: widget.faultDetails),
                            const SizedBox(height: 4),
                            widget.imageList.isEmpty
                                ? const SizedBox.shrink()
                                : _buildImageList(),
                            const SizedBox(height: 4),
                            SummaryFieldGroup(
                              label: "Salutation",
                              field: widget.salutation,
                            ),
                            const SizedBox(height: 4),
                            SummaryFieldGroup(
                              label: "Given Name",
                              field: widget.givenName,
                            ),
                            const SizedBox(height: 4),
                            SummaryFieldGroup(
                              label: "Surname",
                              field: widget.surname,
                            ),
                            const SizedBox(height: 4),
                            SummaryFieldGroup(
                              label: "Email",
                              field: widget.email,
                            ),
                            const SizedBox(height: 4),
                            SummaryFieldGroup(
                              label: "Report Follow Up",
                              field: widget.isReceiveUpdate ? "Yes" : "No",
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            CheckboxListTileFormField(
                              key: formFieldKey,
                              title: Text.rich(
                                TextSpan(
                                  text:
                                      "Terms & Conditions\nBy submitting this form, I agree to JTC's ",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(
                                        text: "Terms of Usage ",
                                        style: const TextStyle(
                                            color: kElectricBlue),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            String usageUrl =
                                                "https://www.jtc.gov.sg/terms-of-use";
                                            if (await canLaunch(usageUrl)) {
                                              await launch(usageUrl);
                                            } else {
                                              throw 'Could not launch $usageUrl';
                                            }
                                          }),
                                    const TextSpan(text: "and "),
                                    TextSpan(
                                        text: "Privacy Policy",
                                        style: TextStyle(color: kElectricBlue),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            String privacyUrl =
                                                "https://www.jtc.gov.sg/privacy-statement";
                                            if (await canLaunch(privacyUrl)) {
                                              await launch(privacyUrl);
                                            } else {
                                              throw 'Could not launch $privacyUrl';
                                            }
                                          }),
                                    const TextSpan(text: "."),
                                  ],
                                ),
                              ),
                              activeColor: kElectricBlue,
                              validator: (value) {
                                if (value == null || !value) {
                                  return "Please check this box before submitting.";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    primary: kElectricBlue,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    side:
                                        const BorderSide(color: kElectricBlue),
                                    padding: const EdgeInsets.all(20),
                                  ),
                                  child: const Text("Back"),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: kElectricBlue,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                      padding: const EdgeInsets.all(20),
                                    ),
                                    onPressed: () async {
                                      if (isLoading == true) {
                                        return;
                                      }
                                      isLoading = true;
                                      if (formFieldKey.currentState!
                                          .validate()) {
                                        if (await RecaptchaService
                                            .isNotaBot()) {
                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return const LoadingDialog(
                                                  backgroundColor:
                                                      Colors.black54,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(10),
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
                                          submitReport(
                                            buildingCode: widget.buildingCode,
                                            otherLocation: widget.otherLocation,
                                            locationDetails: widget
                                                .additionalLocationDetails,
                                            faultDescription:
                                                widget.faultDetails,
                                            salutation: widget.salutation,
                                            givenName: widget.givenName,
                                            surname: widget.surname,
                                            contactNumber: widget.contactNumber,
                                            emailAddress: widget.email,
                                            isReceiveUpdate:
                                                widget.isReceiveUpdate,
                                            reportStatus: "New",
                                            latitude: widget.latitude,
                                            longitude: widget.longitude,
                                            spaceId: widget.spaceId,
                                          );
                                        }
                                      } else {
                                        Scrollable.ensureVisible(
                                          formFieldKey.currentContext!,
                                        );
                                      }
                                      isLoading = false;
                                    },
                                    child: const Text("Confirm Submission"),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.05 * screenHeight),
                          ],
                        ),
                      ),
                    ),
                    const SgdsFooter(),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  Row _buildImageList() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: kSummaryLabelWidth,
          child: Text("Uploaded Images", style: kSummaryLabelStyle),
        ),
        Flexible(
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Scrollbar(
                controller: imageScrollController,
                child: GridView.builder(
                  controller: imageScrollController,
                  physics: const ScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    crossAxisSpacing: 20,
                    maxCrossAxisExtent: 150,
                  ),
                  itemCount: widget.imageList.length,
                  itemBuilder: (context, index) {
                    return Center(
                        child: DottedBorder(
                            child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Image.file(File(widget.imageList[index].path)),
                          ]),
                    )));
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
