import 'package:url_launcher/url_launcher.dart';

/// Opens the phone dialler or the browser. Behind an interface so tests do not need a phone.
abstract class ExternalLauncher {
  /// Opens the dialler with [number] filled in. Returns false if it could not be opened.
  Future<bool> dial(String number);

  /// Opens a web page in the browser. Returns false if it could not be opened.
  Future<bool> openWeb(Uri uri);
}

class UrlLauncherExternal implements ExternalLauncher {
  const UrlLauncherExternal();

  @override
  Future<bool> dial(String number) async {
    try {
      return await launchUrl(Uri(scheme: 'tel', path: number));
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> openWeb(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
