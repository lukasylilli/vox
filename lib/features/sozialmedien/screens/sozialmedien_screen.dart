// FILE: lib/features/sozialmedien/screens/sozialmedien_screen.dart
// DEPS: -
// PURPOSE: لینک‌های شبکه‌های اجتماعی VOX — Telegram، Instagram، YouTube
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/vox_button.dart';

class SozialmedienScreen extends StatelessWidget {
  const SozialmedienScreen({super.key});

  static const _channels = [
    (
      name   : 'Telegram',
      handle : '@VOXDeutsch',
      desc   : 'social_telegram_sub',
      icon   : Icons.telegram,
      color  : Color(0xFF229ED9),
      link   : 'https://t.me/VOXDeutsch',
    ),
    (
      name   : 'Instagram',
      handle : '@vox.deutsch',
      desc   : 'social_insta_sub',
      icon   : Icons.photo_camera_rounded,
      color  : Color(0xFFE1306C),
      link   : 'https://instagram.com/vox.deutsch',
    ),
    (
      name   : 'YouTube',
      handle : 'VOX Deutsch',
      desc   : 'social_youtube_sub',
      icon   : Icons.play_circle_rounded,
      color  : Color(0xFFFF0000),
      link   : 'https://youtube.com/@VOXDeutsch',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soziale Medien')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: AppSizes.md),
            child: Text(
              'social_follow_msg',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
          ),
          ..._channels.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child  : _ChannelCard(channel: c),
              )),
          const SizedBox(height: AppSizes.lg),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  Icon(Icons.favorite_rounded,
                      color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'social_share_msg',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({required this.channel});

  final ({
    String name,
    String handle,
    String desc,
    IconData icon,
    Color color,
    String link,
  }) channel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: channel.color,
          child: Icon(channel.icon, color: Colors.white, size: 20),
        ),
        title   : Text(channel.name,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(channel.handle,
                style: TextStyle(
                  color    : Theme.of(context).colorScheme.primary,
                  fontSize : 12,
                  fontWeight: FontWeight.w600,
                )),
            Text(AppL10n.t(context, channel.desc),
                style: TextStyle(
                  color  : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                )),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            VoxIconButton(
              icon: Icons.copy_rounded, iconSize: 18,
              tooltip  : AppL10n.t(context, 'copy_link'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: channel.link));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content : Text(AppL10n.t(context, 'link_copied')),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
