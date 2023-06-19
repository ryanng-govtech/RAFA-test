import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rafa_app/contants.dart';
import 'package:rafa_app/homepage.dart';
import 'package:rafa_app/sgds_appbar.dart';
import 'package:rafa_app/sgds_footer.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorPage extends StatefulWidget {
  final int statusCode;

  const ErrorPage({Key? key, required this.statusCode}) : super(key: key);

  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  final ScrollController _pageScrollController = ScrollController();
  late TapGestureRecognizer _returnToHomePageRecognizer;
  late TapGestureRecognizer _callCustomerServiceLocalRecognizer;

  @override
  void initState() {
    super.initState();
    _returnToHomePageRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const RAFAHomePage()));
      };
    _callCustomerServiceLocalRecognizer = TapGestureRecognizer()
      ..onTap = () {
        launch("tel:1800 568 7000");
      };
  }

  @override
  void dispose() {
    _returnToHomePageRecognizer.dispose();
    super.dispose();
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
                              left: 0.08 * screenWidth,
                              right: 0.08 * screenWidth,
                              top: 0.05 * screenHeight),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                    "Error " + widget.statusCode.toString(),
                                    style:
                                        Theme.of(context).textTheme.headline5),
                              ),
                            ],
                          ),
                        ),
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
                                widget.statusCode == 401
                                    ? _buildStatusCode401()
                                    : const SizedBox.shrink(),
                                widget.statusCode == 404
                                    ? _buildStatusCode404()
                                    : const SizedBox.shrink(),
                                widget.statusCode >= 500 &&
                                        widget.statusCode < 600
                                    ? _buildStatusCode500To599()
                                    : const SizedBox.shrink(),
                              ],
                            )),
                        SizedBox(height: 0.4 * screenHeight),
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

  _buildStatusCode401() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text.rich(
              TextSpan(
                  text:
                      'Your session has expired (20 minutes time limit).\nPlease refresh the page or click ',
                  children: [
                    TextSpan(
                        text: "here ",
                        style: const TextStyle(
                            color: kElectricBlue, fontWeight: FontWeight.bold),
                        recognizer: _returnToHomePageRecognizer),
                    const TextSpan(
                      text: "and verify your mobile number again.",
                    )
                  ]),
              maxLines: 5,
              textAlign: TextAlign.left),
        )
      ],
    );
  }

  _buildStatusCode404() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text.rich(
              TextSpan(
                  text: 'The link is broken. Please contact us at ',
                  children: [
                    TextSpan(
                        text: "1800 568 7000",
                        style: const TextStyle(
                            color: kElectricBlue, fontWeight: FontWeight.bold),
                        recognizer: _callCustomerServiceLocalRecognizer),
                    const TextSpan(
                      text: "(Local).",
                    )
                  ]),
              maxLines: 5,
              textAlign: TextAlign.left),
        )
      ],
    );
  }

  _buildStatusCode500To599() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text.rich(
              TextSpan(
                  text:
                      'We encountered an internal server error. Please call us at ',
                  children: [
                    TextSpan(
                        text: "1800 568 7000",
                        style: const TextStyle(
                            color: kElectricBlue, fontWeight: FontWeight.bold),
                        recognizer: _callCustomerServiceLocalRecognizer),
                    const TextSpan(
                      text: "(Local) to lodge a report, or try again ",
                    ),
                    TextSpan(
                        text: "here",
                        style: const TextStyle(
                            color: kElectricBlue, fontWeight: FontWeight.bold),
                        recognizer: _returnToHomePageRecognizer),
                    const TextSpan(
                      text: ".",
                    ),
                  ]),
              maxLines: 8,
              textAlign: TextAlign.left),
        )
      ],
    );
  }
}
