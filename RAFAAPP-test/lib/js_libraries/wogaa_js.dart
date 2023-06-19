@JS("wogaaCustom")
library wogaa;

import 'package:js/js.dart';

@JS("startTransactionalService")
external void wogaaStartTransactionalService(String trackingId);

@JS("completeTransactionalService")
external void wogaaCompleteTransactionalService(String trackingId);
