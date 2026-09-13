// FILE: lib/core/widgets/vox_loading_widget.dart
// DEPS: -
// PURPOSE: Konsistenter Ladeindikator — zentriert, mit optionalem Label
import 'package:flutter/material.dart';

class VoxLoadingWidget extends StatelessWidget {
  const VoxLoadingWidget({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: scheme.primary),
          if (label != null) ...[
            const SizedBox(height: 16),
            Text(label!,
                style: TextStyle(
                    color: scheme.onSurfaceVariant, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

// Shimmer-style skeleton block for card placeholders
class VoxSkeletonBlock extends StatefulWidget {
  const VoxSkeletonBlock({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double  height;
  final double  borderRadius;

  @override
  State<VoxSkeletonBlock> createState() => _VoxSkeletonBlockState();
}

class _VoxSkeletonBlockState extends State<VoxSkeletonBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync   : this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Container(
        width : widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            isDark
                ? const Color(0xFF1E1E2A)
                : const Color(0xFFE8E8F0),
            isDark
                ? const Color(0xFF2E2E3E)
                : const Color(0xFFF4F4FC),
            _anim.value,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
