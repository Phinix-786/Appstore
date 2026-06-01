class AppModel {
  final String id;
  final String name;
  final String packageName;
  final String developer;
  final String developerEmail;
  final String description;
  final String shortDescription;
  final String iconUrl;
  final List<String> screenshots;
  final String? promoVideoUrl;
  final String category;
  final List<String> tags;
  final String version;
  final String versionCode;
  final String changelog;
  final double rating;
  final int ratingCount;
  final int downloadCount;
  final double size;
  final String minSdk;
  final List<String> permissions;
  final String ageRating;
  final DateTime updatedAt;
  final DateTime createdAt;
  final String downloadUrl;
  final String architecture;
  final bool isEditorChoice;
  final bool isTrending;
  final bool isFeatured;
  final String signature;
  final List<AppReview> reviews;
  final List<AppVersion> versionHistory;

  AppModel({
    required this.id,
    required this.name,
    required this.packageName,
    required this.developer,
    this.developerEmail = '',
    required this.description,
    this.shortDescription = '',
    required this.iconUrl,
    this.screenshots = const [],
    this.promoVideoUrl,
    required this.category,
    this.tags = const [],
    required this.version,
    this.versionCode = '1',
    this.changelog = '',
    this.rating = 0.0,
    this.ratingCount = 0,
    this.downloadCount = 0,
    this.size = 0.0,
    this.minSdk = '21',
    this.permissions = const [],
    this.ageRating = 'Everyone',
    required this.updatedAt,
    required this.createdAt,
    required this.downloadUrl,
    this.architecture = 'universal',
    this.isEditorChoice = false,
    this.isTrending = false,
    this.isFeatured = false,
    this.signature = '',
    this.reviews = const [],
    this.versionHistory = const [],
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      packageName: json['package_name'] ?? '',
      developer: json['developer'] ?? '',
      developerEmail: json['developer_email'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      screenshots: List<String>.from(json['screenshots'] ?? []),
      promoVideoUrl: json['promo_video_url'],
      category: json['category'] ?? 'Other',
      tags: List<String>.from(json['tags'] ?? []),
      version: json['version'] ?? '1.0.0',
      versionCode: json['version_code'] ?? '1',
      changelog: json['changelog'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      downloadCount: json['download_count'] ?? 0,
      size: (json['size'] ?? 0.0).toDouble(),
      minSdk: json['min_sdk'] ?? '21',
      permissions: List<String>.from(json['permissions'] ?? []),
      ageRating: json['age_rating'] ?? 'Everyone',
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      downloadUrl: json['download_url'] ?? '',
      architecture: json['architecture'] ?? 'universal',
      isEditorChoice: json['is_editor_choice'] ?? false,
      isTrending: json['is_trending'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      signature: json['signature'] ?? '',
      reviews: (json['reviews'] as List?)
              ?.map((r) => AppReview.fromJson(r))
              .toList() ??
          [],
      versionHistory: (json['version_history'] as List?)
              ?.map((v) => AppVersion.fromJson(v))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'package_name': packageName,
        'developer': developer,
        'developer_email': developerEmail,
        'description': description,
        'short_description': shortDescription,
        'icon_url': iconUrl,
        'screenshots': screenshots,
        'promo_video_url': promoVideoUrl,
        'category': category,
        'tags': tags,
        'version': version,
        'version_code': versionCode,
        'changelog': changelog,
        'rating': rating,
        'rating_count': ratingCount,
        'download_count': downloadCount,
        'size': size,
        'min_sdk': minSdk,
        'permissions': permissions,
        'age_rating': ageRating,
        'updated_at': updatedAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'download_url': downloadUrl,
        'architecture': architecture,
        'is_editor_choice': isEditorChoice,
        'is_trending': isTrending,
        'is_featured': isFeatured,
        'signature': signature,
      };

  String get formattedSize {
    if (size < 1024) return '${size.toStringAsFixed(1)} KB';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get formattedDownloads {
    if (downloadCount < 1000) return '$downloadCount';
    if (downloadCount < 1000000) return '${(downloadCount / 1000).toStringAsFixed(1)}K';
    if (downloadCount < 1000000000) return '${(downloadCount / 1000000).toStringAsFixed(1)}M';
    return '${(downloadCount / 1000000000).toStringAsFixed(1)}B';
  }
}

class AppReview {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final String? developerReply;
  final int helpfulCount;

  AppReview({
    required this.id,
    required this.userName,
    this.userAvatar = '',
    required this.rating,
    required this.comment,
    required this.date,
    this.developerReply,
    this.helpfulCount = 0,
  });

  factory AppReview.fromJson(Map<String, dynamic> json) {
    return AppReview(
      id: json['id'] ?? '',
      userName: json['user_name'] ?? 'Anonymous',
      userAvatar: json['user_avatar'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      developerReply: json['developer_reply'],
      helpfulCount: json['helpful_count'] ?? 0,
    );
  }
}

class AppVersion {
  final String version;
  final String versionCode;
  final String changelog;
  final DateTime date;
  final double size;
  final String downloadUrl;

  AppVersion({
    required this.version,
    required this.versionCode,
    required this.changelog,
    required this.date,
    required this.size,
    required this.downloadUrl,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      version: json['version'] ?? '',
      versionCode: json['version_code'] ?? '',
      changelog: json['changelog'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      size: (json['size'] ?? 0.0).toDouble(),
      downloadUrl: json['download_url'] ?? '',
    );
  }
}

class AppCategory {
  final String id;
  final String name;
  final String icon;
  final int appCount;
  final String color;

  AppCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.appCount = 0,
    this.color = '#4CAF50',
  });

  factory AppCategory.fromJson(Map<String, dynamic> json) {
    return AppCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? 'category',
      appCount: json['app_count'] ?? 0,
      color: json['color'] ?? '#4CAF50',
    );
  }
}

class DownloadTask {
  final String appId;
  final String appName;
  final String iconUrl;
  final String downloadUrl;
  final String savePath;
  double progress;
  DownloadStatus status;
  String? error;

  DownloadTask({
    required this.appId,
    required this.appName,
    required this.iconUrl,
    required this.downloadUrl,
    required this.savePath,
    this.progress = 0.0,
    this.status = DownloadStatus.pending,
    this.error,
  });
}

enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  installing,
  installed,
}

class AppCollection {
  final String id;
  final String title;
  final String description;
  final String bannerUrl;
  final List<String> appIds;

  AppCollection({
    required this.id,
    required this.title,
    required this.description,
    this.bannerUrl = '',
    this.appIds = const [],
  });

  factory AppCollection.fromJson(Map<String, dynamic> json) {
    return AppCollection(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      bannerUrl: json['banner_url'] ?? '',
      appIds: List<String>.from(json['app_ids'] ?? []),
    );
  }
}
