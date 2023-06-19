import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contants.dart';

class SgdsMasthead extends StatelessWidget {
  const SgdsMasthead({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 0.08 * screenWidth),
          hoverColor: Colors.transparent,
          dense: true,
          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          minLeadingWidth: 0,
          tileColor: kGreyF0,
          onTap: () {
            launch('https://www.gov.sg/');
          },
          leading: Text(
            '${String.fromCharCode(59720)}',
            style: TextStyle(
              fontFamily: 'sgds-icons',
              // color: Color(0xFFDB0000),
              color: Color(0xFFFF0000),
              fontSize: 24,
            ),
          ),
          // leading: IconButton(
          //   padding: EdgeInsets.zero,
          //   constraints: BoxConstraints(),
          //   hoverColor: Colors.transparent,
          //   icon: Image.asset('assets/images/sgds_head.png',
          //       width: 22, height: 22),
          //   onPressed: () {
          //     launch('https://www.gov.sg/');
          //   },
          // ),
          title: Text(
            ' A Singapore Government Agency Website',
            style: TextStyle(
              fontFamily: "Lato",
              color: Color(0xFF4C4C4C),
              fontSize: 12,
            ),
          ),
        ),
        // SizedBox(
        //   height: 71,
        //   child: ListTile(
        //     // dense: true,
        //     visualDensity: VisualDensity(vertical: 4),
        //     // minLeadingWidth: 0,
        //     tileColor: Color(0xFFFFFFFF),
        //     leading: Image.asset(
        //       'assets/images/JTC_Logo3x.png',
        //       width: 47,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
