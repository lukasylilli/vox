// FILE: lib/core/services/rss_service.dart
// DEPS: api_client.dart, cache_service.dart, xml
// PURPOSE: Fetch + parse an RSS feed → List<RssItem>
//          Offline-first: fresh cache (30 min) → network → stale cache.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xml/xml.dart';

import '../network/api_client.dart';
import 'app_logger.dart';
import 'cache_service.dart';

class RssItem {
  const RssItem({
    required this.title,
    required this.description,
    required this.link,
    this.pubDate,
    this.imageUrl,
  });
  final String   title;
  final String   description;
  final String   link;
  final DateTime? pubDate;
  final String?  imageUrl;
}

class RssService {
  RssService(this._api, this._cache, this._logger);

  static const _maxAge = Duration(minutes: 30);

  final ApiClient    _api;
  final CacheService _cache;
  final AppLogger    _logger;

  Future<List<RssItem>> fetch(String feedUrl) async {
    final cacheKey = 'rss:$feedUrl';

    // 1. fresh cache → instant, no network
    final fresh = await _cache.get(cacheKey, maxAge: _maxAge);
    if (fresh != null) return _parse(fresh);

    // 2. network → update cache
    try {
      final body = await _api.getText(Uri.parse(feedUrl));
      await _cache.put(cacheKey, body);
      return _parse(body);
    } on ApiException catch (e) {
      // 3. offline → stale cache fallback
      _logger.w('fetch failed ($e) — trying stale cache');
      final stale = await _cache.getStale(cacheKey);
      return stale != null ? _parse(stale) : [];
    }
  }

  List<RssItem> _parse(String body) {
    try {
      final doc = XmlDocument.parse(body);
      return doc.findAllElements('item').map(_parseItem).toList();
    } catch (e) {
      _logger.e('RSS parse failed', e);
      return [];
    }
  }

  static RssItem _parseItem(XmlElement item) {
    String getText(String tag) =>
        item.findElements(tag).firstOrNull?.innerText.trim() ?? '';

    final title       = getText('title');
    final link        = getText('link');
    final description = _stripHtml(getText('description'));
    final pubDateStr  = getText('pubDate');
    final pubDate     = _parseDate(pubDateStr);

    // Try to extract image from <enclosure> or <media:thumbnail>
    String? imageUrl;
    final enclosure = item.findElements('enclosure').firstOrNull;
    if (enclosure != null) {
      final type = enclosure.getAttribute('type') ?? '';
      if (type.startsWith('image/')) {
        imageUrl = enclosure.getAttribute('url');
      }
    }
    imageUrl ??= item
        .findElements('media:thumbnail')
        .firstOrNull
        ?.getAttribute('url');

    return RssItem(
      title      : title,
      description: description,
      link       : link,
      pubDate    : pubDate,
      imageUrl   : imageUrl,
    );
  }

  static String _stripHtml(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), '').trim();

  static DateTime? _parseDate(String s) {
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      // RFC 2822: "Mon, 27 Jun 2026 10:30:00 +0000"
      try {
        const months = {
          'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
          'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
          'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12',
        };
        final parts = s.split(' ');
        if (parts.length >= 5) {
          final day   = parts[1].padLeft(2, '0');
          final month = months[parts[2]] ?? '01';
          final year  = parts[3];
          final time  = parts[4];
          return DateTime.parse('$year-$month-${day}T$time');
        }
      } catch (_) {}
    }
    return null;
  }
}

final rssServiceProvider = Provider<RssService>((ref) => RssService(
      ref.watch(apiClientProvider),
      ref.watch(cacheServiceProvider),
      ref.watch(loggerProvider('RssService')),
    ));
