// import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import 'package:rafa_app/contants.dart';
import 'package:rafa_app/location_page.dart';
import 'package:rafa_app/services/recaptcha_service.dart';
import 'package:universal_io/io.dart';
import 'homepage.dart';

void main() async {
  getParams();
  // temporarily used to override certificate
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    bool ready = await RecaptchaService.initiate();
    print("Is Recaptcha ready: ${ready}");
  }
  runApp(MyApp());
}

// override certificate
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String? building;
String? spaceId;
String? space;

void getParams() {
  //change here from window.url to this
  var uri = Uri.dataFromString("https://fem.jtcqas.gov.sg/rafa/app/#/");
  Map<String, String> params = Map.fromEntries(uri.queryParameters.entries);
  for (String key in params.keys) {
    if (params[key] != null) {
      if (params[key]!.contains("#/")) {
        String lastParam = params[key]!.split("#/").first;
        params[key] = lastParam;
      }
    }
  }
  if (params["building"] != null) {
    building = urlDecoding(params["building"]!);
  }
  if (params["spaceid"] != null) {
    print("Space id: It is a string");
    spaceId = urlDecoding(params["spaceid"]!);
  }
  if (params["space"] != null) {
    space = urlDecoding(params["space"]!);
  }
}

String urlDecoding(String parameter) {
  parameter = parameter
      .replaceAll(RegExp(r"%60"), "`")
      .replaceAll(RegExp(r"%7E"), "~")
      .replaceAll(RegExp(r"%21"), "!")
      .replaceAll(RegExp(r"%40"), "@")
      .replaceAll(RegExp(r"%23"), "#")
      .replaceAll(RegExp(r"%24"), "\$")
      .replaceAll(RegExp(r"%25"), "%")
      .replaceAll(RegExp(r"%5E"), "^")
      .replaceAll(RegExp(r"%26"), "&")
      .replaceAll(RegExp(r"%2A"), "*")
      .replaceAll(RegExp(r"%28"), "(")
      .replaceAll(RegExp(r"%29"), ")")
      .replaceAll(RegExp(r"%2D"), "-")
      .replaceAll(RegExp(r"%5F"), "_")
      .replaceAll(RegExp(r"%3D"), "=")
      .replaceAll(RegExp(r"%2B"), "+")
      .replaceAll(RegExp(r"%5B"), "[")
      .replaceAll(RegExp(r"%7B"), "{")
      .replaceAll(RegExp(r"%5D"), "]")
      .replaceAll(RegExp(r"%7D"), "}")
      .replaceAll(RegExp(r"%5C"), "\\")
      .replaceAll(RegExp(r"%7C"), "|")
      .replaceAll(RegExp(r"%3B"), ";")
      .replaceAll(RegExp(r"%3A"), ":")
      .replaceAll(RegExp(r"%27"), "'")
      .replaceAll(RegExp(r"%22"), '"')
      .replaceAll(RegExp(r"%2C"), ",")
      .replaceAll(RegExp(r"%3C"), "<")
      .replaceAll(RegExp(r"%2E"), ".")
      .replaceAll(RegExp(r"%3E"), ">")
      .replaceAll(RegExp(r"%2F"), "/")
      .replaceAll(RegExp(r"%3F"), "?")
      .replaceAll(RegExp(r"%20"), " ");
  return parameter;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      // builder: (context, child) {
      //   bool isSmallScreen = MediaQuery.of(context).size.width < 800;
      //   return Theme(data: _buildThemeData(isSmallScreen), child: child!);
      // },
      scrollBehavior: MyCustomScrollBehaviour(),
      title: 'Report-A-Fault',
      theme: _buildThemeData(),
      home:
          // LocationPage(
          //   accessToken: "test",
          //   contactNumber: "12345678",
          // )
          RAFAHomePage(
        building: building,
        spaceId: spaceId,
        space: space,
      ),
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: MaterialStateProperty.all(true),
      ),
      inputDecorationTheme: const InputDecorationTheme(
          errorStyle: TextStyle(
            color: kRed,
            fontSize: 18,
            fontFeatures: [ui.FontFeature.proportionalFigures()],
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            fontSize: 18,
            fontFeatures: [ui.FontFeature.proportionalFigures()],
          )),
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: kElectricBlue,
          onPrimary: Colors.white,
          secondary: Colors.red,
          onSecondary: Colors.orange,
          error: Colors.yellow,
          onError: Colors.green,
          background: Colors.blue,
          onBackground: Colors.indigo,
          surface: Colors.purple,
          onSurface: kGrey66),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Barlow',
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: kGreyF0,
        titleTextStyle: TextStyle(
          color: kGrey2a,
          fontSize: 39,
          fontWeight: FontWeight.w500,
          fontFeatures: [ui.FontFeature.proportionalFigures()],
        ),
        iconTheme: IconThemeData(
          color: kGrey2a,
        ),
      ),
      textTheme: const TextTheme(
        headline1: TextStyle(
          fontSize: 61.0,
          fontWeight: FontWeight.normal,
        ),
        headline2: TextStyle(
          fontSize: 49.0,
          fontWeight: FontWeight.normal,
        ),
        headline3: TextStyle(
          fontSize: 39.0,
          fontWeight: FontWeight.normal,
        ),
        headline4: TextStyle(
          fontSize: 39.0,
          fontWeight: FontWeight.w500,
          fontFeatures: [ui.FontFeature.proportionalFigures()],
        ),
        headline5: TextStyle(
          color: kGrey2a,
          fontSize: 31.0,
          fontWeight: FontWeight.w600,
          fontFeatures: [ui.FontFeature.proportionalFigures()],
        ),
        headline6: TextStyle(
          color: kGrey2a,
          fontSize: 25.0,
          fontWeight: FontWeight.w600,
          fontFeatures: [ui.FontFeature.proportionalFigures()],
        ),
        subtitle1: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.normal,
          fontFeatures: [ui.FontFeature.proportionalFigures()],
        ),
        subtitle2: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
        ),
        bodyText1: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.normal,
        ),
        bodyText2: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
          color: kGrey2a,
          fontFeatures: [ui.FontFeature.proportionalFigures()],
        ),
        button: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          fontFeatures: [ui.FontFeature.proportionalFigures()],
        ),
        caption: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
        ),
        overline: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.normal,
          color: kGrey2a,
          fontFeatures: [ui.FontFeature.proportionalFigures()],
        ),
      ),
    );
  }
}

class MyCustomScrollBehaviour extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

/*
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'uploadImage.dart';
import 'faultDetails.dart';




void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Step 1: Report a Fault';
    return MaterialApp(
      title: appTitle,
      color: const Color(0xff006ceb),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: const MyCustomForm(),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key}) : super(key: key);

  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  final String urlLocation =
      "https://jtcfemapp.azurewebsites.net/rafa/api/RAFAEstates";
  final String urlCategory =
      "https://jtcfemapp.azurewebsites.net/rafa/api/RAFAFaultCategories";
  final String urlPostFault =
      "https://jtcfemapp.azurewebsites.net/rafa/api/RAFAFaultReports/CreateNewFault";
  final myLocDetCntr = TextEditingController();
  final myFaultDetCntr = TextEditingController();
  final myNameCtr = TextEditingController();
  final myContactCntr = TextEditingController();
  final myEmailCntr = TextEditingController();
  final myOTPCntr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String DDLocationVal = "one-north";
  String DDFaultVal = "One";
  bool _isChecked = false;

  List dataLocation = List.empty(); //edited line
  List<DropdownMenuItem> itemsLocation = [];
  List dataFault = List.empty(); //edited line
  List<DropdownMenuItem> itemsFault = [];

  Future<String> getWSLocation() async {
    var res = await http
        .get(Uri.parse(urlLocation), headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);
    if (res.statusCode == 200) {
      setState(() {
        dataLocation = resBody;
        itemsLocation = dataLocation
            .map((item) => DropdownMenuItem(
                child: Text(item['estate']), value: item['id'].toString()))
            .toList();
        DDLocationVal = dataLocation[0]["id"].toString();
      });
      return "Sucess";
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  Future<String> getWSCategory() async {
    var res = await http
        .get(Uri.parse(urlCategory), headers: {"Accept": "application/json"});
    var resFaultBody = json.decode(res.body);
    if (res.statusCode == 200) {
      setState(() {
        dataFault = resFaultBody;
        itemsFault = dataFault
            .map((item) => DropdownMenuItem(
                child: Text(item['faultType']), value: item['id'].toString()))
            .toList();
        DDFaultVal = dataFault[0]["id"].toString();
      });
      return "Sucess";
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  @override
  void initState() {
    super.initState();
    this.getWSLocation();
    this.getWSCategory();
  }

  @override
  void dispose() {
    myLocDetCntr.dispose();
    myFaultDetCntr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                  'Use the Report-A-Fault features to report any facilities '
                  'or estate management matters.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16, color: Colors.lightBlue[800])),
            ),
            // <<Location>>
            /*Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Location: ', textAlign: TextAlign.left),
          ),*/
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: DropdownButtonFormField<dynamic>(
                value: DDLocationVal,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Location Details \*",
                ),
                items: itemsLocation,
                onChanged: (newLocValue) {
                  setState(() {
                    DDLocationVal = newLocValue.toString();
                  });
                },
              ),
            ),
            // <<Location Details>>
            /*Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Location Details: ', textAlign: TextAlign.left),
          ),*/
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                controller: myLocDetCntr,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location details.';
                  }
                  return null;
                },
                style: TextStyle(height: 0.5),
                maxLength: 100,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'E.g. Fusionopolis, Level 1, Walkway',
                  labelText: "Location Details \*",
                ),
              ),
            ),
            // <<Fault/Issues Categories>>
            /* Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Fault/Issues Categories: ', textAlign: TextAlign.left),
          ),*/
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: DropdownButtonFormField<dynamic>(
                value: DDFaultVal,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Fault/Issue Category",
                ),
                items: itemsFault,
                onChanged: (newFaultValue) {
                  setState(() {
                    DDFaultVal = newFaultValue.toString();
                  });
                },
              ),
            ),
            // <<Details of Faults/Issues>>
            /*Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Details of Faults/Issues: ', textAlign: TextAlign.left),
          ),*/
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                controller: myFaultDetCntr,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the faults/issues details.';
                  }
                  return null;
                },
                maxLines: 2,
                maxLength: 500,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'E.g. Fusionopolis, Level 1, Walkway',
                  labelText: "Faults/Issues Details \*",
                ),
              ),
            ),
            //name
            /*Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Name: ', textAlign: TextAlign.left),
          ),*/
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                controller: myNameCtr,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name.';
                  }
                  return null;
                },
                maxLength: 50,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'E.g. Alan',
                  labelText: "Name \*",
                ),
              ),
            ),
            /*Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Contact Number: ', textAlign: TextAlign.left),
          ),*/
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                controller: myContactCntr,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 8) {
                    return 'Please enter a valid contact number.';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                maxLength: 8,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'E.g. 91234567',
                  labelText: "Contact Number \*",
                ),
              ),
            ),
            /*Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Email Address: ', textAlign: TextAlign.left),
          ),*/
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                controller: myEmailCntr,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address.';
                  }
                  return null;
                },
                maxLength: 50,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'E.g. Alan@JTC.GOV.SG',
                  labelText: "Email Address \*",
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: CheckboxListTile(
                title: const Text('Report Follow Up'),
                subtitle: const Text(
                    'I would like to have the report follow up via the email provided.'),
                autofocus: false,
                activeColor: Colors.blueAccent,
                checkColor: Colors.white,
                selected: _isChecked,
                value: _isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked = value!;
                  });
                },
              ),
            ),
            // <Submit Button>>
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                ),
                //onPressed: _pushSaved,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FaultDetailsPage()));
                },
                child: const Text("Proceed"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostFaultDetails {
  final int estateId;
  final String locationDetails;
  final int faultCategoryId;
  final String faultDescription;
  final String reporterName;
  final String contactNumber;
  final String emailAddress;
  final bool isReceiveUpdate;
  //final String createdDateTime;

  PostFaultDetails({
    required this.estateId,
    required this.locationDetails,
    required this.faultCategoryId,
    required this.faultDescription,
    required this.reporterName,
    required this.contactNumber,
    required this.emailAddress,
    required this.isReceiveUpdate,
    //required this.createdDateTime
  });

  factory PostFaultDetails.fromJson(Map json) {
    return PostFaultDetails(
      estateId: json['estateId'],
      locationDetails: json['locationDetails'],
      faultCategoryId: json['faultCategoryId'],
      faultDescription: json['faultDescription'],
      reporterName: json['reporterName'],
      contactNumber: json['contact'],
      emailAddress: json['email'],
      isReceiveUpdate: json['isReceiveUpdate'],
      //createdDateTime: json['createdDateTime']
    );
  }

  Map toMap() {
    var map = new Map();
    map["estateId"] = estateId;
    map["faultCategoryId"] = faultCategoryId;
    map["locationDetails"] = locationDetails;
    map["faultDescription"] = faultDescription;
    map["reporterName"] = reporterName;
    map["contactNumber"] = contactNumber;
    map["emailAddress"] = emailAddress;
    map["isReceiveUpdate"] = isReceiveUpdate;
    //map["createdDateTime"] = createdDateTime;
    return map;
  }
}

Future createPost(String url, {required Map body}) async {
  return http
      .post(Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(body))
      .then((http.Response response) {
    final int statusCode = response.statusCode;
    print(body);
    print(response.statusCode);
    if (statusCode == 200) {
      //print(response);
      return Text("Success");
    } else {
      throw new Exception("Error while fetching data");
    }
  });
}

Future<void> submitReport(
    String url,
    estateId,
    locationDetails,
    faultCategoryId,
    faultDescription,
    reporterName,
    contactNumber,
    emailAddress,
    isReceiveUpdate) async {
  Map<String, dynamic> queryParams = {
    "estateId": int.parse(estateId),
    "locationDetails": locationDetails.toString(),
    "faultCategoryId": int.parse(faultCategoryId),
    "faultDescription": faultDescription.toString(),
    "reporterName": reporterName.toString(),
    "contactNumber": contactNumber.toString(),
    "emailAddress": emailAddress.toString(),
    "isReceiveUpdate": isReceiveUpdate,
  };

  var response2 = await http.post(Uri.parse(url),.0
      body: jsonEncode(queryParams),
      headers: {"Content-Type": "application/json"});
  // log("Response: ${response2.statusCode} - ${response2.body}", name: "submitInspectionReportDate");
}

/*class secondScreen extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Picker Demo',
      home: MyHomePage(title: 'Image Picker Example'),
    );
  }
}*/
*/
