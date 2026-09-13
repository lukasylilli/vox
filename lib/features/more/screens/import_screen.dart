// FILE: lib/features/more/screens/import_screen.dart
// DEPS: import_service.dart
// PURPOSE: Import von Wörtern/Phrasen via Einfügen von CSV oder JSON Text
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/services/import_service.dart';
import '../../../core/widgets/vox_button.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  ImportType _type   = ImportType.words;
  String     _format = 'json';
  bool       _loading = false;
  ImportResult? _result;
  final _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _doImport() async {
    final content = _textCtrl.text.trim();
    if (content.isEmpty) return;
    setState(() { _loading = true; _result = null; });

    final svc = ref.read(importServiceProvider);
    ImportResult result;

    if (_type == ImportType.words && _format == 'csv') {
      result = await svc.importWordsCsv(content);
    } else if (_type == ImportType.words && _format == 'json') {
      result = await svc.importWordsJson(content);
    } else {
      result = await svc.importMemorizeJson(content);
    }

    setState(() { _result = result; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Import')),
      body  : ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [

          // Type selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppL10n.t(context, 'data_type'),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  SegmentedButton<ImportType>(
                    segments: [
                      ButtonSegment(
                          value: ImportType.words,
                          label: Text(AppL10n.t(context, 'wortschatz')),
                          icon : const Icon(Icons.translate_rounded)),
                      ButtonSegment(
                          value: ImportType.memorizePhrases,
                          label: Text(AppL10n.t(context, 'phrases_label')),
                          icon : const Icon(Icons.format_quote_rounded)),
                    ],
                    selected          : {_type},
                    onSelectionChanged: (s) =>
                        setState(() { _type = s.first; _result = null; }),
                  ),
                  if (_type == ImportType.words) ...[
                    const SizedBox(height: 12),
                    Text(AppL10n.t(context, 'format_label'),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'json', label: Text('JSON')),
                        ButtonSegment(value: 'csv',  label: Text('CSV')),
                      ],
                      selected          : {_format},
                      onSelectionChanged: (s) =>
                          setState(() => _format = s.first),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Format guide
          Card(
            color: scheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppL10n.t(context, 'expected_format'),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    _formatGuide,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 12, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Text input
          TextField(
            controller : _textCtrl,
            maxLines   : 10,
            decoration : InputDecoration(
              hintText     : AppL10n.t(context, 'paste_csv_hint'),
              border       : const OutlineInputBorder(),
              alignLabelWithHint: true,
              suffixIcon   : VoxIconButton(
                icon: Icons.clear_rounded,
                onPressed: () => _textCtrl.clear(),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),

          // Import button
          VoxButton.primary(
            label    : 'Import starten',
            icon     : Icons.download_rounded,
            loading  : _loading,
            onPressed: _loading ? null : _doImport,
          ),

          // Result
          if (_result != null) ...[
            const SizedBox(height: AppSizes.md),
            Card(
              color: _result!.success
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child  : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _result!.success
                              ? Icons.check_circle_rounded
                              : Icons.error_rounded,
                          color: _result!.success ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _result!.success
                              ? 'Import erfolgreich'
                              : 'Fehler',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    if (_result!.error != null)
                      Text(_result!.error!,
                          style: const TextStyle(color: Colors.red)),
                    if (_result!.success) ...[
                      Text(AppL10n.tf(context, 'imported_n', {'n': '${_result!.imported}'})),
                      Text(AppL10n.tf(context, 'skipped_n', {'n': '${_result!.skipped}'})),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String get _formatGuide {
    if (_type == ImportType.words && _format == 'csv') {
      return 'german,meaningFa,wordType,level,article,plural\n'
          'Haus,خانه,Nomen,a1,das,Häuser\n'
          'gehen,رفتن,Verb,a1,,';
    } else if (_type == ImportType.words) {
      return '[{"german":"Haus","meaningFa":"خانه",\n'
          ' "wordType":"Nomen","level":"a1",\n'
          ' "article":"das","plural":"Häuser"}]';
    } else {
      return '[{"phrase":"Guten Morgen",\n'
          ' "meaning":"صبح بخیر",\n'
          ' "meaning_en":"Good morning",\n'
          ' "category":"Redewendungen"}]';
    }
  }
}
