// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:image_picker/image_picker.dart';
// import 'thankyou_page.dart';
// import 'package:http/http.dart' as http;

// class OTPScreen extends StatefulWidget {
//   final String myNameCtr;
//   final String myContactCntr;
//   final String myEmailCntr;
//   final bool isReceiveUpdate;
//   final int DDLocVal;
//   final String myLocDetCntr;
//   final String myFaultDetCntr;
//   final List<XFile>? imagePath;
//   final String myEstateName;

//   const OTPScreen(
//       {Key? key,
//       required this.myNameCtr,
//       required this.myContactCntr,
//       required this.myEmailCntr,
//       required this.isReceiveUpdate,
//       required this.DDLocVal,
//       required this.myLocDetCntr,
//       required this.myFaultDetCntr,
//       required this.imagePath,
//       required this.myEstateName})
//       : super(key: key);

//   @override
//   _OTPScreenState createState() => _OTPScreenState();
// }

// class _OTPScreenState extends State<OTPScreen> {
//   final myOTPCntr = TextEditingController();
//   var responseOTPVerification;
//   String urlPostFault =
//       "https://localhost:5001/api/RAFAFaultReports/CreateNewFault";
//   String getOTPURL =
//       "https://localhost:5001/api/RAFAOTPs/GenerateOTPByMobileNumber";

//   String verifyOTP =
//       "https://localhost:5001/api/RAFAOTPs/VerifyOTPCode?phoneNum=";

//   @override
//   void initState() {
//     super.initState();
//     getOTP(widget.myContactCntr);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Step 5: OTP Verification'),
//         //automaticallyImplyLeading: false,
//       ),
//       body: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//               child: Text('Enter OTP: ', textAlign: TextAlign.left),
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               child: TextField(
//                 controller: myOTPCntr,
//                 maxLength: 6,
//                 decoration: const InputDecoration(
//                     border: OutlineInputBorder(), hintText: 'E.g. 123456'),
//               ),
//             ),
//             Row(
//               children: <Widget>[
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.blueAccent,
//                       shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(0)),
//                       ),
//                     ),
//                     onPressed: () async {
//                       if (myOTPCntr.text == "" || myOTPCntr.text.length != 6) {
//                         myOTPCntr.text = "";
//                         showDialog(
//                           context: context,
//                           builder: (context) {
//                             return const AlertDialog(
//                               content: Text("Invalid OTP!"),
//                             );
//                           },
//                         );
//                       } else {
//                         postOTP(widget.myContactCntr, myOTPCntr.text);
//                         /*submitReport(
//                             widget.DDLocVal, //widget.DDLocationVal,
//                             "blank", //location details not available
//                             "1", // no need fault category
//                             "blank", // no need fault description
//                             widget.myNameCtr,
//                             widget.myContactCntr,
//                             widget.myEmailCntr,
//                             widget.isReceiveUpdate,
//                             "In-Progress"
//                             //createdDateTime: DateTime.now().toString()
//                             );
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => ThankYouScreen()));*/
//                       }
//                     },
//                     child: const Text("Submit"),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.blueAccent,
//                       shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(0)),
//                       ),
//                     ),
//                     onPressed: () {
//                       myOTPCntr.text = "";
//                       showDialog(
//                         context: context,
//                         builder: (context) {
//                           return const AlertDialog(
//                             content:
//                                 Text("A new OTP is sent to you mobile number."),
//                           );
//                         },
//                       );
//                     },
//                     child: const Text("Send OTP"),
//                   ),
//                 ),
//               ],
//             )
//           ]),
//     );
//   }

//   Future<void> submitReport(
//       estateId,
//       locationDetails,
//       faultCategoryId,
//       faultDescription,
//       reporterName,
//       contactNumber,
//       emailAddress,
//       isReceiveUpdate,
//       reportStatus) async {
//     Map<String, dynamic> queryParams = {
//       "estateId": (estateId),
//       "locationDetails": locationDetails.toString(),
//       "faultCategoryId": int.parse(faultCategoryId),
//       "faultDescription": faultDescription.toString(),
//       "reporterName": reporterName.toString(),
//       "contactNumber": contactNumber.toString(),
//       "emailAddress": emailAddress.toString(),
//       "isReceiveUpdate": isReceiveUpdate,
//       "reportStatus": reportStatus
//     };
//     var response2 = await http.post(Uri.parse(urlPostFault),
//         body: jsonEncode(queryParams),
//         headers: {"Content-Type": "application/json"});
//     // log("Response: ${response2.statusCode} - ${response2.body}", name: "submitInspectionReportDate");
//   }

//   Future<void> getOTP(
//     contactNumber,
//   ) async {
//     Map<String, String> queryParams = {
//       "MobileNumber": contactNumber.toString(),
//     };
//     log(contactNumber);
//     log('${queryParams}');
//     var response2 =
//         await http.post(Uri.parse(getOTPURL + "?mobileNumber=" + contactNumber),
//             //body: (queryParams),
//             headers: {"Content-Type": "application/json"});
//     log('${response2.body}');
//     // log("Response: ${response2.statusCode} - ${response2.body}", name: "submitInspectionReportDate");
//   }

//   Future<void> postOTP(contactNumber, OTP) async {
//     Map<String, dynamic> queryParams = {
//       "MobileNumber": contactNumber.toString(),
//       "OTPCode": int.parse(OTP),
//     };
//     var response2 =
//         await http.post(Uri.parse(verifyOTP + contactNumber + "&otp=" + OTP),
//             //body: (queryParams),
//             headers: {"Content-Type": "application/json"});
//     if (response2.statusCode == 200) {
//       submitReport(
//           widget.DDLocVal, //widget.DDLocationVal,
//           widget.myLocDetCntr, //location details not available
//           "1", // no need fault category
//           widget.myFaultDetCntr, // no need fault description
//           widget.myNameCtr,
//           widget.myContactCntr,
//           widget.myEmailCntr,
//           widget.isReceiveUpdate,
//           "In-Progress"
//           //createdDateTime: DateTime.now().toString()
//           );
//       Navigator.push(
//           context, MaterialPageRoute(builder: (context) => ThankYouScreen()));
//     } else {
//       showDialog(
//         context: context,
//         builder: (context) {
//           return const AlertDialog(
//             content: Text("Please Enter a Valid OTP."),
//           );
//         },
//       );
//     }
//     log('${response2.body}' + '${response2.statusCode}');
//     // log("Response: ${response2.statusCode} - ${response2.body}", name: "submitInspectionReportDate");
//   }
// }
