import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppHelpers {
  static const Map<String, String> _storeLabels = {
    'games4you': 'Games4You',
    'mipl': 'Mipl.rs',
    'gnom': 'BottleGnome',
    'kraken': 'Kraken.rs',
  };

  // Returns the store name based on the key.
  static String getStoreLabel(String? key) {
    if (key == null) return 'null';

    final normalizedKey = key.trim().toLowerCase();
    return _storeLabels[normalizedKey] ?? 'null';
  }

  // Returns price in 999,00 RSD format
  static String formatPrice(int price) {
    final str = price.toString();
    final offset = str.length % 3;
    final buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (i - offset) % 3 == 0 && i >= offset) buffer.write('.');
      buffer.write(str[i]);
    }
    return '${buffer.toString()},00 RSD';
  }

  // Opens a store link for the user
  static Future<void> launchStoreUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      debugPrint('No URL provided to launch');
      return;
    }

    final Uri url = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(url)) {
        // Opens in default browser
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('Could not launch $urlString');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}
