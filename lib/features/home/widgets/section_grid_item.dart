// FILE: lib/features/home/widgets/section_grid_item.dart
// PURPOSE: Single card in the home 3×4 grid — icon, DE title, local title
import 'package:flutter/material.dart';

class SectionData {
  const SectionData({
    required this.titleDe,
    required this.titleLocal,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String   titleDe;
  final String   titleLocal;
  final IconData icon;
  final Color    color;
  final String   route;
}

class SectionGridItem extends StatelessWidget {
  const SectionGridItem({
    super.key,
    required this.section,
    required this.onTap,
  });

  final SectionData  section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color       : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap       : onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor : Colors.white24,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin : Alignment.topLeft,
              end   : Alignment.bottomRight,
              colors: [
                section.color.withValues(alpha: 0.85),
                section.color.withValues(alpha: 0.55),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color : section.color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset    : const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(section.icon, color: Colors.white, size: 28),
                const Spacer(),
                Text(
                  section.titleDe,
                  style: const TextStyle(
                    color     : Colors.white,
                    fontSize  : 12,
                    fontWeight: FontWeight.w700,
                    height    : 1.2,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  section.titleLocal,
                  style: const TextStyle(
                    color    : Color(0xCCFFFFFF),
                    fontSize : 11,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines : 1,
                  overflow : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
