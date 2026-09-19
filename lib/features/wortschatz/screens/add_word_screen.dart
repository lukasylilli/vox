// FILE: lib/features/wortschatz/screens/add_word_screen.dart
// DEPS: parser_registry.dart, wordDaoProvider, ModelToCompanion
// PURPOSE: Paste text → live parse preview → save to DB
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/models/word_model.dart';
import '../../../core/parsers/parser_registry.dart';
import '../../../core/widgets/article_badge.dart';
import '../../../core/utils/formatters.dart';
import '../controllers/word_controller.dart';
import '../../../core/widgets/vox_button.dart';
import '../../../core/widgets/deutsch_text.dart';

class AddWordScreen extends ConsumerStatefulWidget {
  const AddWordScreen({super.key});

  @override
  ConsumerState<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends ConsumerState<AddWordScreen> {
  final _controller = TextEditingController();
  WordModel? _parsed;
  String?   _error;
  bool      _saving = false;

  void _onTextChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() { _parsed = null; _error = null; });
      return;
    }
    final result = ParserRegistry.parse(value);
    setState(() {
      _parsed = result;
      _error  = result == null ? AppL10n.t(context, 'unknown_format') : null;
    });
  }

  Future<void> _save() async {
    if (_parsed == null || _saving) return;
    setState(() => _saving = true);
    try {
      final dao = ref.read(wordDaoProvider);
      await dao.insert(_parsed!.toCompanion());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppL10n.tf(context, 'saved_quoted', {'x': _parsed!.german})),
            backgroundColor: Colors.green,
          ),
        );
        _controller.clear();
        setState(() { _parsed = null; _error = null; });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppL10n.t(context, 'error')}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppL10n.t(context, 'add_word')),
        actions: [
          VoxIconButton(
            icon: Icons.help_outline_rounded,
            tooltip: AppL10n.t(context, 'format_guide'),
            onPressed: () => _showFormatHelp(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input area
            TextField(
              controller   : _controller,
              onChanged    : _onTextChanged,
              maxLines     : 4,
              decoration   : InputDecoration(
                hintText   : AppL10n.t(context, 'paste_word_hint'),
                hintStyle  : theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                alignLabelWithHint: true,
                suffixIcon : _controller.text.isNotEmpty
                    ? VoxIconButton(
                        icon: Icons.clear_rounded,
                        onPressed: () {
                          _controller.clear();
                          _onTextChanged('');
                        },
                      )
                    : null,
              ),
            ),

            const SizedBox(height: AppSizes.md),

            // Error message
            if (_error != null)
              Container(
                padding    : const EdgeInsets.all(AppSizes.md),
                decoration : BoxDecoration(
                  color       : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!,
                        style: const TextStyle(color: Colors.red))),
                  ],
                ),
              ),

            // Parse preview
            if (_parsed != null) ...[
              _ParsePreview(model: _parsed!),
              const SizedBox(height: AppSizes.md),
            ],

            const Spacer(),

            // Save button
            VoxButton.primary(
              label    : _saving ? AppL10n.t(context, 'saving') : AppL10n.t(context, 'save_word'),
              icon     : Icons.save_rounded,
              size     : VoxButtonSize.large,
              expand   : true,
              loading  : _saving,
              onPressed: _parsed != null && !_saving ? _save : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showFormatHelp(BuildContext context) {
    showModalBottomSheet(
      context      : context,
      isScrollControlled: true,
      shape        : const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand        : false,
        initialChildSize: 0.6,
        builder       : (ctx, scroll) => ListView(
          controller: scroll,
          padding   : const EdgeInsets.all(AppSizes.md),
          children  : [
            Text(AppL10n.t(ctx, 'format_guide'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.md),
            for (final fmt in ParseFormat.values) ...[
              Text(_formatLabel(fmt),
                style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                padding   : const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color       : Theme.of(context).colorScheme
                      .surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(ParserRegistry.formatHint(fmt),
                  style: const TextStyle(
                    fontFamily: 'monospace', fontSize: 12, height: 1.6,
                  )),
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ],
        ),
      ),
    );
  }

  String _formatLabel(ParseFormat fmt) => switch (fmt) {
    ParseFormat.standard      => AppL10n.t(context, 'fmt_standard'),
    ParseFormat.irregularVerb => AppL10n.t(context, 'fmt_uv'),
    ParseFormat.konnektor     => AppL10n.t(context, 'fmt_k'),
    ParseFormat.nvv           => 'Nomen-Verb-Verbindung (NVV)',
  };
}

// ── Parse preview card ────────────────────────────────────────────────────────

class _ParsePreview extends StatelessWidget {
  const _ParsePreview({required this.model});
  final WordModel model;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding    : const EdgeInsets.all(AppSizes.md),
      decoration : BoxDecoration(
        color       : Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border      : Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Text(AppL10n.t(context, 'parse_success'),
                  style: const TextStyle(color: Colors.green,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          const Divider(),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: DeutschText(model.german,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
              ),
              if (model.article != null)
                ArticleBadge(article: model.article, large: true),
              const SizedBox(width: 8),
              Container(
                padding    : const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration : BoxDecoration(
                  color       : scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(model.wordType.label,
                  style: TextStyle(
                    color    : scheme.primary, fontSize: 11,
                    fontWeight: FontWeight.w600,
                  )),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(AppL10n.meaning(context, fa: model.meaningFa,
              en: model.meaningEn ?? model.meaningFa),
              style: theme.textTheme.bodyLarge),
          if (model.level != null)
            Text(AppL10n.tf(context, 'level_prefix', {'x': model.level!.label}),
              style: theme.textTheme.bodySmall),
          if (model.examples.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(Formatters.countLabel(model.examples.length, AppL10n.t(context, 'example')),
                style: theme.textTheme.bodySmall),
            ),
          if (model.conjugation != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${model.conjugation!.infinitiv} · '
                '${model.conjugation!.praesens} · '
                '${model.conjugation!.praeteritum} · '
                '${model.conjugation!.partizip}',
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
