import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

// Application Settings

// SESSION
const kSessionInActivityThresholdInSec = 326;

// Margin
const kContainerMargin = EdgeInsets.symmetric(vertical: 20, horizontal: 20);

// URI
// var APIPREFIX =
//     kReleaseMode ? "${Uri.base.origin}/rafa/api" : "https://localhost:5001";
// Mobile URI
var APIPREFIX =
    kReleaseMode ? "${Uri.base.origin}/rafa/api" : "https://10.0.2.2:5001";

// Google Analytics 4
const kIsGa4Enabled = bool.fromEnvironment("isGa4Enabled", defaultValue: false);

// Google reCAPTCHA v3 settings
const kIsRecaptchaEnabled = false;
const kRecaptchaSiteKey = "6Leds-AhAAAAAIcivXJQIKZJ95qlHNeuHT-mGDrB";
const kRecaptchaSecretKey = "6Leds-AhAAAAADuWIMLtIVD8CutlYppXn0f_42rA";
var kGRecaptchaVerificationUrl =
    APIPREFIX + "/api/RAFARecaptcha/GetRecaptchaVerification";

// Padding
const kFormFieldPadding = 15.0;
const kFormLikePaddingIfWidthAbove = 1451;

// Size
const kElevatedButtonSize = Size(150, 60);
const kContainerMaxWidth = 480.0;
const kIconSize = 55.0;
const kDataCellColumnWidth = kIsWeb ? 200.0 : 100.0;

// Basic Colors
const kPrimaryColor = Color(0xFF006CEB); // JTC Colors
const kElectricBlue = Color(0xFF006CEB); // JTC Colors
const kSecondaryColor = Color(0xFF005588); // JTC Colors
const kHomeIconSize = kIsWeb ? 0.08 : 0.1; // x width of screen
const kGrey2a = Color(0xFF2A2A2A);
const kGrey66 = Color(0xFF666666);
const kGreyF0 = Color(0xFFF0F0F0);
const kRed = Color(0xFFDE2F1B);

const kHomeIconContainerColor = Color(0xFF2359A8);
const kInputFieldTextAreaBgColor = Colors.white;
const kInputFieldTextFieldBgColor = Colors.black;
const kInputFieldLabelBgColor = Colors.white;
const kRoundedButtonBgColor = Colors.white;
const kRoundedButtonFgColor = Colors.black;
const kRoundedButtonTextColor = Colors.white;
const kRoundedButtonSideBorderColor = Colors.blue;

const kFieldLabelStyle = TextStyle(fontWeight: FontWeight.w600, color: kGrey66);
const kFormFieldStyle =
    TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: kGrey2a);
const kFormFieldHintStyle = TextStyle(
    fontSize: 18,
    color: kGrey66,
    fontWeight: FontWeight.normal,
    fontFeatures: [ui.FontFeature.proportionalFigures()]);
const kSummaryLabelStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: kGrey2a,
    fontFeatures: [ui.FontFeature.proportionalFigures()]);

const kSummaryLabelWidth = 200.0;

const kDraftColor = Color(0xFFFFA400); // JTC Colors
const kSubmittedColor = Color(0xFF008550); // JTC Colors
const kClosedColor = Color(0xFFDE2F1B); // JTC Colors
const kOpacityofStatusColor = 0.5;

const kHomeIconColor = Colors.black;

const bool kButtonTextToUpperCase = false;
const double kButtonTextTextSize = 14;
const double kRadioButtonOptionFontSize = 14.0;

//CAROUSELL
const bool kCarouselAutoPlay = true;
const kCarouselImageWidth = 0.7; // x width of screen

const int kImageQuality = 5;
const int kTotalImagesLimit = 30;
const double kTotalImagesFontSize = 14.0;
const kTotalImageWarning = "You have reached the limit of uploading images";
const Color kImageUploadBackground = kGrey66;

const double kTextSizeTitle = 30;
const double kTextSizeNormal = 20; //20 initially
const double kTextTracking = -0.2;
const double kTextLeading = 0;

const List<String> allowedImageUploadExtensions = [
  "png",
  "jpg",
  "jpeg",
  "hpeg",
  "tif",
  "heic"
];
