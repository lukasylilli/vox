// FILE: lib/core/utils/external_link_opener_web.dart
// PURPOSE: Öffnet eine URL in einem neuen Browser-Tab (package:web).
import 'package:web/web.dart' as web;

void openExternalLink(String url) => web.window.open(url, '_blank');
