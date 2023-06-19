import 'package:flutter/material.dart';
import 'package:rafa_app/contants.dart';
import 'package:rafa_app/homepage.dart';
import 'package:rafa_app/location_page.dart';
import 'package:rafa_app/sgds_appbar.dart';
import 'package:rafa_app/sgds_footer.dart';
import 'js_libraries/google_analytics_4_js.dart';
import 'js_libraries/wogaa_js.dart';
import 'package:http/http.dart' as http;

class ThankYouScreen extends StatefulWidget {
  final String jtcCaseId;
  final String contactNumber;
  final String accessToken;

  const ThankYouScreen(
      {Key? key,
      required this.contactNumber,
      required this.accessToken,
      required this.jtcCaseId})
      : super(key: key);

  @override
  _ThankYouScreenState createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  final ScrollController _pageScrollController = ScrollController();
  final String checkTokenAboutToExpireUrl =
      APIPREFIX + "/api/RAFAOTPs/CheckTokenAboutToExpire";

  @override
  void initState() {
    super.initState();
    wogaaCompleteTransactionalService("femjtc-4523");
    if (kIsGa4Enabled) {
      ga4PushData(GoogleAnalytics4Data(
          event: 'page_view', page_title: 'Thank You Page'));
    }
  }

  Future<bool> checkTokenAboutToExpire(String accessToken) async {
    var response = await http.post(Uri.parse(checkTokenAboutToExpireUrl),
        body: {"accessToken": accessToken});
    print("Status Code = " + response.statusCode.toString());
    if (response.statusCode == 200) {
      return false;
    } else {
      return true;
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
        titleSpacing: 0,
        title: Padding(
            padding: EdgeInsets.only(left: 0.08 * screenWidth),
            child: const Text('Report-A-Fault')),
        automaticallyImplyLeading: false,
      )),
      body: SafeArea(
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
                                left: isSmallScreen
                                    ? 0.08 * screenWidth
                                    : 0.15 * screenWidth,
                                right: isSmallScreen
                                    ? 0.08 * screenWidth
                                    : 0.15 * screenWidth,
                                top: 0.05 * screenHeight,
                                bottom: 0.1 * screenHeight),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      'Your Case Reference ID is: ${widget.jtcCaseId}',
                                      textAlign: TextAlign.left),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Thank you for your feedback.'),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.all(20),
                                    ),
                                    onPressed: () async {
                                      bool aboutToExpire =
                                          await checkTokenAboutToExpire(
                                              widget.accessToken);
                                      if (aboutToExpire) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RAFAHomePage()));
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LocationPage(
                                                        contactNumber: widget
                                                            .contactNumber,
                                                        accessToken: widget
                                                            .accessToken)));
                                      }
                                    },
                                    child: const Text("Report Another Fault"),
                                  ),
                                ),
                              ],
                            )),
                        SizedBox(height: 0.3 * screenHeight),
                        const SgdsFooter()
                      ],
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
