import 'dart:convert';

import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';
import 'package:rafa_app/contants.dart';
import 'package:http/http.dart' as http;
import 'package:rafa_app/models/recaptcha_response.dart';

class RecaptchaService {
  // Prevent class instantiation
  RecaptchaService._();

  // Load Google reCAPTCHA V3 api
  static Future<bool> initiate() async =>
      await GRecaptchaV3.ready(kRecaptchaSiteKey);

  // Check if user is a bot
  static Future<bool> isNotaBot() async {
    if (kIsRecaptchaEnabled) {
      var verificationResponse = await _getVerificationResponse();
      var _score = verificationResponse?.score ?? 0.0;
      return _score >= 0.5 && _score <= 1 ? true : false;
    } else {
      return true;
    }
  }

  static Future<RecaptchaResponse?> _getVerificationResponse() async {
    String? _token = await GRecaptchaV3.execute("submit") ?? "";
    RecaptchaResponse? _recaptchaResponse;

    if (_token.isNotEmpty) {
      // base64 encoding neccessary to bypass Azure Web Application Firewall Ruleset SQLi
      _token = base64.encode(utf8.encode(_token));

      //replace 0x to bypass Azure WAF Firewall Ruleset SQli Hex Encoding
      _token = _token.replaceAll("0x", ",").replaceAll("0X", ".");

      var response = await http.get(Uri.parse(kGRecaptchaVerificationUrl)
          .replace(queryParameters: {"gRecaptchaToken": _token}));
      _recaptchaResponse =
          RecaptchaResponse.fromJson(jsonDecode(response.body));
    }

    return _recaptchaResponse;
  }
}
