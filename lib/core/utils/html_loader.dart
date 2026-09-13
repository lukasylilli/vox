// FILE: lib/core/utils/html_loader.dart
// PURPOSE: Entfernt die CSS-Ladeanzeige (#vox-loading) aus web/index.html,
//          damit sie nach dem ersten Frame nicht unsichtbar weiterläuft.
import 'package:web/web.dart' as web;

void removeHtmlLoader() => web.document.getElementById('vox-loading')?.remove();
