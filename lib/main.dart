export 'main_stub.dart'
    if (dart.library.html) 'main_web.dart'
    if (dart.library.io) 'main_mobile.dart';
