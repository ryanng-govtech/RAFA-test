import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;

class SgdsFooter extends StatelessWidget {
  const SgdsFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool desktop = MediaQuery.of(context).size.width >= 754;
    return kIsWeb
        ? Container(
            padding: EdgeInsets.symmetric(
                horizontal: 0.08 * screenWidth, vertical: 8 * 2),
            width: double.infinity,
            color: Colors.grey[850],
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'JTC',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 31.0,
                      fontWeight: FontWeight.w500,
                      fontFeatures: [ui.FontFeature.proportionalFigures()],
                    ),
                  ),
                ),
                SizedBox(
                  height: 8 * 2,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'The JTC Summit\n8 Jurong Town Hall Road\nSingapore 609434',
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(
                  height: 8 * 2,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      InkWell(
                        child: Text(
                          '1800 568 7000 ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          launch("tel:1800 568 7000");
                        },
                      ),
                      Text(
                        '(Local)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                desktop
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'Hotline is available from Mondays to Fridays,\n8:30am - 6:00pm, excluding public holidays.',
                                      style: TextStyle(
                                        color: Color(0xFFB8B8B8),
                                        fontSize: 16,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            InkWell(
                                              child: Text(
                                                'Contact JTC',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              onTap: () {
                                                launch(
                                                    'https://www.jtc.gov.sg/about-jtc/contact-us');
                                              },
                                            ),
                                            SizedBox(
                                              width: 8 * 3,
                                            ),
                                            InkWell(
                                              child: Text(
                                                'REACH',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              onTap: () {
                                                launch(
                                                    'https://www.reach.gov.sg/');
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8),
                                              child: InkWell(
                                                child: Text(
                                                  '${String.fromCharCode(59675)}',
                                                  style: TextStyle(
                                                    fontFamily: 'sgds-icons',
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    height: 1.6,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                onTap: () {
                                                  launch(
                                                      "https://www.facebook.com/jtccorp");
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8 * 3,
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8),
                                              child: InkWell(
                                                child: Text(
                                                  '${String.fromCharCode(59678)}',
                                                  style: TextStyle(
                                                    fontFamily: 'sgds-icons',
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    height: 1.6,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                onTap: () {
                                                  launch(
                                                      "https://www.instagram.com/jtc_sg/");
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8 * 3,
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8),
                                              child: InkWell(
                                                child: Text(
                                                  '${String.fromCharCode(59689)}',
                                                  style: TextStyle(
                                                    fontFamily: 'sgds-icons',
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    height: 1.6,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                onTap: () {
                                                  launch(
                                                      "https://www.youtube.com/user/JTCsingapore");
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8 * 3,
                                            ),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8),
                                              child: InkWell(
                                                child: Text(
                                                  '${String.fromCharCode(59679)}',
                                                  style: TextStyle(
                                                    fontFamily: 'sgds-icons',
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    height: 1.6,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                onTap: () {
                                                  launch(
                                                      "https://www.linkedin.com/company/jtc-corporation");
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Divider(
                            height: 40,
                            thickness: 1,
                            color: Color(0xFFB8B8B8),
                          ),
                          SizedBox(
                            height: 8 * 1,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        InkWell(
                                          child: Text(
                                            'Report Vulnerability',
                                            style: TextStyle(
                                              color: Color(0xFFB8B8B8),
                                              fontSize: 14,
                                              height: 1.6,
                                            ),
                                          ),
                                          onTap: () {
                                            launch(
                                                "https://www.tech.gov.sg/report_vulnerability");
                                          },
                                        ),
                                        SizedBox(
                                          width: 8 * 6,
                                        ),
                                        InkWell(
                                          child: Text(
                                            'Terms of Use',
                                            style: TextStyle(
                                              color: Color(0xFFB8B8B8),
                                              fontSize: 14,
                                              height: 1.6,
                                            ),
                                          ),
                                          onTap: () {
                                            launch(
                                                "https://www.jtc.gov.sg/terms-of-use");
                                          },
                                        ),
                                        SizedBox(
                                          width: 8 * 6,
                                        ),
                                        InkWell(
                                          child: Text(
                                            'Privacy Statement',
                                            style: TextStyle(
                                              color: Color(0xFFB8B8B8),
                                              fontSize: 14,
                                              height: 1.6,
                                            ),
                                          ),
                                          onTap: () {
                                            launch(
                                                "https://www.jtc.gov.sg/privacy-statement");
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8 * 3,
                                  ),
                                ],
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '© 2022 JTC.\nLast Updated 26 Apr 2022',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Color(0xFFB8B8B8),
                                    fontSize: 14,
                                    height: 1.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Hotline is available from Mondays to Fridays, 8:30am - 6:00pm, excluding public holidays.',
                              style: TextStyle(
                                color: Color(0xFFB8B8B8),
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8 * 2,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      child: Text(
                                        'Contact JTC',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      onTap: () {
                                        launch(
                                            'https://www.jtc.gov.sg/about-jtc/contact-us');
                                      },
                                    ),
                                    SizedBox(
                                      width: 8 * 20,
                                    ),
                                    InkWell(
                                      child: Text(
                                        'REACH',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      onTap: () {
                                        launch('https://www.reach.gov.sg/');
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8 * 3,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: InkWell(
                                        child: Text(
                                          '${String.fromCharCode(59675)}',
                                          style: TextStyle(
                                            fontFamily: 'sgds-icons',
                                            color: Colors.white,
                                            fontSize: 22,
                                            height: 1.6,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        onTap: () {
                                          launch(
                                              "https://www.facebook.com/jtccorp");
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8 * 3,
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: InkWell(
                                        child: Text(
                                          '${String.fromCharCode(59678)}',
                                          style: TextStyle(
                                            fontFamily: 'sgds-icons',
                                            color: Colors.white,
                                            fontSize: 22,
                                            height: 1.6,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        onTap: () {
                                          launch(
                                              "https://www.instagram.com/jtc_sg/");
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8 * 3,
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: InkWell(
                                        child: Text(
                                          '${String.fromCharCode(59689)}',
                                          style: TextStyle(
                                            fontFamily: 'sgds-icons',
                                            color: Colors.white,
                                            fontSize: 22,
                                            height: 1.6,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        onTap: () {
                                          launch(
                                              "https://www.youtube.com/user/JTCsingapore");
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8 * 3,
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: InkWell(
                                        child: Text(
                                          '${String.fromCharCode(59679)}',
                                          style: TextStyle(
                                            fontFamily: 'sgds-icons',
                                            color: Colors.white,
                                            fontSize: 22,
                                            height: 1.6,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        onTap: () {
                                          launch(
                                              "https://www.linkedin.com/company/jtc-corporation");
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 40,
                            thickness: 1,
                            color: Color(0xFFB8B8B8),
                          ),
                          SizedBox(
                            height: 8 * 1,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      child: Text(
                                        'Report Vulnerability',
                                        style: TextStyle(
                                          color: Color(0xFFB8B8B8),
                                          fontSize: 14,
                                          height: 1.6,
                                        ),
                                      ),
                                      onTap: () {
                                        launch(
                                            "https://www.tech.gov.sg/report_vulnerability");
                                      },
                                    ),
                                    SizedBox(
                                      width: 8 * 16,
                                    ),
                                    InkWell(
                                      child: Text(
                                        'Terms of Use',
                                        style: TextStyle(
                                          color: Color(0xFFB8B8B8),
                                          fontSize: 14,
                                          height: 1.6,
                                        ),
                                      ),
                                      onTap: () {
                                        launch(
                                            "https://www.jtc.gov.sg/terms-of-use");
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8 * 4,
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      child: Text(
                                        'Privacy Statement',
                                        style: TextStyle(
                                          color: Color(0xFFB8B8B8),
                                          fontSize: 14,
                                          height: 1.6,
                                        ),
                                      ),
                                      onTap: () {
                                        launch(
                                            "https://www.jtc.gov.sg/privacy-statement");
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8 * 4,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '© 2022 JTC.\nLast Updated 14 Jun 2022',
                              style: TextStyle(
                                color: Color(0xFFB8B8B8),
                                fontSize: 14,
                                height: 1.8,
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          )
        : Container();
  }
}
