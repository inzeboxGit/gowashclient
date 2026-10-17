import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract final class AppRuntime {
  static bool get _usesTestBinding {
    final String bindingName = WidgetsBinding.instance.runtimeType.toString();
    return bindingName.contains('TestWidgetsFlutterBinding');
  }

  static bool get supportsFirebaseBackend {
    return !kIsWeb &&
        !_usesTestBinding &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
  }

  static bool get supportsNativeGoogleMap {
    return defaultTargetPlatform == TargetPlatform.android && !_usesTestBinding;
  }
}
