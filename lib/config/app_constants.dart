import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'App Store';
  static const String appVersion = '1.0.0';
  static const int appVersionCode = 1;

  /// The tag prefix used for app store self-update releases on GitHub.
  /// Releases should be tagged as "appstore-v1.0.0", "appstore-v1.1.0", etc.
  static const String selfUpdateTagPrefix = 'appstore-v';

  static const List<CategoryInfo> categories = [
    CategoryInfo('games', 'Games', Icons.sports_esports, Color(0xFFE91E63)),
    CategoryInfo('social', 'Social', Icons.people, Color(0xFF2196F3)),
    CategoryInfo('communication', 'Communication', Icons.chat, Color(0xFF00BCD4)),
    CategoryInfo('productivity', 'Productivity', Icons.work, Color(0xFFFF9800)),
    CategoryInfo('entertainment', 'Entertainment', Icons.movie, Color(0xFF9C27B0)),
    CategoryInfo('tools', 'Tools', Icons.build, Color(0xFF607D8B)),
    CategoryInfo('education', 'Education', Icons.school, Color(0xFF4CAF50)),
    CategoryInfo('music', 'Music & Audio', Icons.music_note, Color(0xFFFF5722)),
    CategoryInfo('photography', 'Photography', Icons.camera_alt, Color(0xFF795548)),
    CategoryInfo('shopping', 'Shopping', Icons.shopping_bag, Color(0xFFFFC107)),
    CategoryInfo('finance', 'Finance', Icons.account_balance, Color(0xFF009688)),
    CategoryInfo('health', 'Health & Fitness', Icons.fitness_center, Color(0xFFCDDC39)),
    CategoryInfo('news', 'News & Magazines', Icons.newspaper, Color(0xFF3F51B5)),
    CategoryInfo('travel', 'Travel & Local', Icons.flight, Color(0xFF00BCD4)),
    CategoryInfo('food', 'Food & Drink', Icons.restaurant, Color(0xFFFF5722)),
    CategoryInfo('lifestyle', 'Lifestyle', Icons.spa, Color(0xFFE91E63)),
    CategoryInfo('maps', 'Maps & Navigation', Icons.map, Color(0xFF4CAF50)),
    CategoryInfo('weather', 'Weather', Icons.cloud, Color(0xFF03A9F4)),
    CategoryInfo('sports', 'Sports', Icons.sports_soccer, Color(0xFF8BC34A)),
    CategoryInfo('books', 'Books & Reference', Icons.book, Color(0xFF9E9E9E)),
    CategoryInfo('business', 'Business', Icons.business, Color(0xFF607D8B)),
    CategoryInfo('medical', 'Medical', Icons.local_hospital, Color(0xFFF44336)),
    CategoryInfo('personalization', 'Personalization', Icons.palette, Color(0xFF673AB7)),
    CategoryInfo('video', 'Video Players', Icons.videocam, Color(0xFFE91E63)),
  ];

  static const List<String> ageRatings = [
    'Everyone',
    'Everyone 10+',
    'Teen',
    'Mature 17+',
    'Adults Only',
  ];

  static const List<String> architectures = [
    'universal',
    'arm64-v8a',
    'armeabi-v7a',
    'x86',
    'x86_64',
  ];
}

class CategoryInfo {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryInfo(this.id, this.name, this.icon, this.color);
}
