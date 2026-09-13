// FILE: lib/core/widgets/vox_search_field.dart
// STATUS: [x] LIVE (B9 — 2026-07-04)
// PURPOSE: Design System — the one search input used by every list screen.
//          Screens pass controller + hint; look & behavior live here once.
import 'package:flutter/material.dart';

class VoxSearchField extends StatelessWidget {
  const VoxSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onClear,
    this.showClear,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  /// Called after the field is cleared (in addition to controller.clear()).
  final VoidCallback? onClear;

  /// Override clear-button visibility; defaults to `controller.text.isNotEmpty`.
  final bool? showClear;

  @override
  Widget build(BuildContext context) {
    final hasText = showClear ?? controller.text.isNotEmpty;

    return TextField(
      controller     : controller,
      onChanged      : onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText  : hint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: hasText
            ? IconButton(
                icon    : const Icon(Icons.close_rounded),
                onPressed: () {
                  controller.clear();
                  onChanged?.call('');
                  onClear?.call();
                },
              )
            : null,
        border        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        isDense       : true,
      ),
    );
  }
}
