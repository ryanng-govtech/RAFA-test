import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rafa_app/sgds_masthead.dart';
import 'package:url_launcher/url_launcher.dart';

class SgdsAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? appBar;
  SgdsAppbar({this.appBar});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var a = appBar!;
    return 
        ListView(
            children: [
              const SgdsMasthead(),
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    SizedBox(
                      child: InkWell(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 0.08 * screenWidth,
                              top: 16,
                              bottom: 16,
                              right: 16),
                          child: Image.asset(
                            'assets/images/jtc_favicon.png',
                            height: 56,
                          ),
                        ),
                        // onTap: () {
                        //   launch('https://www.jtc.gov.sg/');
                        // },
                        hoverColor: Colors.transparent,
                      ),
                    ),
                    // SizedBox(
                    //   child: InkWell(
                    //     child: Padding(
                    //       padding: EdgeInsets.all(16),
                    //       child: Image.asset('assets/images/jtc_favicon.png',
                    //           width: 71),
                    //     ),
                    //     onTap: () {
                    //       launch('https://www.jtc.gov.sg/');
                    //     },
                    //     hoverColor: Colors.transparent,
                    //   ),
                    // ),
                  ],
                ),
              ),
              a,
              //BetaTesting Container
              // Container(
              //     color: Colors.amber,
              //     child: const Text(
              //       "This application is under Beta Testing.",
              //       textAlign: TextAlign.center,
              //     )),
            ],
          )
        ;
  }

  @override
  // implement preferredSize
  Size get preferredSize => const Size.fromHeight(185);
  //BetaTesting Container
  // Size get preferredSize => const Size.fromHeight(200);
}
