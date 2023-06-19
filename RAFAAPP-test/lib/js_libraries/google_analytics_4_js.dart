@JS()
library ga4;

import 'package:js/js.dart';

@JS('dataLayer.push')
external void ga4PushData(GoogleAnalytics4Data data);

@JS()
@anonymous
class GoogleAnalytics4Data {
  external String get event;
  external String get page_title;
  external factory GoogleAnalytics4Data({String event, String page_title});
}
