import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/github_config.dart';
import '../config/app_constants.dart';
import '../models/app_model.dart';

class GithubService {
  final GithubConfig config;
  final http.Client _client = http.Client();

  GithubService(this.config);

  Future<List<AppModel>> fetchAllApps() async {
    try {
      final response = await _client.get(
        Uri.parse('${config.rawContentUrl}/store/apps.json'),
        headers: config.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final apps = data.map((app) => AppModel.fromJson(app)).toList();

        // Ensure all apps have download URLs from GitHub Releases
        for (int i = 0; i < apps.length; i++) {
          if (apps[i].downloadUrl.isEmpty) {
            final url = await _getLatestReleaseUrl(apps[i].id);
            if (url.isNotEmpty) {
              apps[i] = _appWithDownloadUrl(apps[i], url);
            }
          }
        }
        return apps;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get the latest release APK download URL for a given app.
  /// Looks for GitHub Releases tagged as `appName-v*` and finds an APK asset.
  Future<String> _getLatestReleaseUrl(String appName) async {
    try {
      final response = await _client.get(
        Uri.parse(config.releasesUrl),
        headers: config.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> releases = json.decode(response.body);
        for (final release in releases) {
          final tag = release['tag_name'].toString().toLowerCase();
          if (tag.startsWith('${appName.toLowerCase()}-v')) {
            final assets = release['assets'] as List;
            for (final asset in assets) {
              if (asset['name'].toString().endsWith('.apk')) {
                return asset['browser_download_url'] ?? '';
              }
            }
          }
        }
      }
    } catch (_) {}
    return '';
  }

  /// Get the latest version string for an app from GitHub Releases.
  /// Returns the version extracted from the tag (e.g., "whatsapp-v2.24.1" -> "2.24.1")
  /// Returns null if no release found.
  Future<String?> getLatestVersionForApp(String appName) async {
    try {
      final response = await _client.get(
        Uri.parse(config.releasesUrl),
        headers: config.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> releases = json.decode(response.body);
        for (final release in releases) {
          final tag = release['tag_name'].toString();
          final prefix = '${appName.toLowerCase()}-v';
          if (tag.toLowerCase().startsWith(prefix)) {
            // Extract version from tag: "appname-v1.2.3" -> "1.2.3"
            return tag.substring(prefix.length);
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Get the download URL for a specific version of an app.
  Future<String?> getDownloadUrlForApp(String appName, String version) async {
    try {
      // Try exact tag first
      final tag = '${appName.toLowerCase()}-v$version';
      final response = await _client.get(
        Uri.parse(config.releasesTagUrl(tag)),
        headers: config.headers,
      );

      if (response.statusCode == 200) {
        final release = json.decode(response.body);
        final assets = release['assets'] as List;
        for (final asset in assets) {
          if (asset['name'].toString().endsWith('.apk')) {
            return asset['browser_download_url'];
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Check for a newer version of the app store itself.
  /// Looks for releases tagged as "appstore-v*".
  /// Returns a map with 'version' and 'download_url' if an update is available,
  /// or null if the current version is up to date.
  Future<Map<String, String>?> checkSelfUpdate() async {
    try {
      final response = await _client.get(
        Uri.parse(config.releasesUrl),
        headers: config.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> releases = json.decode(response.body);
        final prefix = AppConstants.selfUpdateTagPrefix;

        for (final release in releases) {
          final tag = release['tag_name'].toString();
          if (tag.startsWith(prefix)) {
            final latestVersion = tag.substring(prefix.length);
            if (_isNewerVersion(latestVersion, AppConstants.appVersion)) {
              // Find APK asset
              final assets = release['assets'] as List;
              for (final asset in assets) {
                if (asset['name'].toString().endsWith('.apk')) {
                  return {
                    'version': latestVersion,
                    'download_url': asset['browser_download_url'] ?? '',
                  };
                }
              }
            }
            // Only check the latest matching release
            break;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Compare two version strings. Returns true if [newer] is greater than [current].
  bool _isNewerVersion(String newer, String current) {
    final newerParts = newer.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad to same length
    while (newerParts.length < currentParts.length) {
      newerParts.add(0);
    }
    while (currentParts.length < newerParts.length) {
      currentParts.add(0);
    }

    for (int i = 0; i < newerParts.length; i++) {
      if (newerParts[i] > currentParts[i]) return true;
      if (newerParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  /// Check for updates for a list of installed apps.
  /// Returns a map of appId -> {version, download_url} for apps that have updates.
  Future<Map<String, Map<String, String>>> checkAppUpdates(
      Map<String, String> installedVersions) async {
    final updates = <String, Map<String, String>>{};

    try {
      final response = await _client.get(
        Uri.parse(config.releasesUrl),
        headers: config.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> releases = json.decode(response.body);

        // Track which apps we've already found the latest release for
        final foundApps = <String>{};

        for (final release in releases) {
          final tag = release['tag_name'].toString();

          for (final appId in installedVersions.keys) {
            if (foundApps.contains(appId)) continue;

            final prefix = '${appId.toLowerCase()}-v';
            if (tag.toLowerCase().startsWith(prefix)) {
              foundApps.add(appId);
              final latestVersion = tag.substring(prefix.length);
              final currentVersion = installedVersions[appId]!;

              if (_isNewerVersion(latestVersion, currentVersion)) {
                // Find APK asset
                final assets = release['assets'] as List;
                for (final asset in assets) {
                  if (asset['name'].toString().endsWith('.apk')) {
                    updates[appId] = {
                      'version': latestVersion,
                      'download_url': asset['browser_download_url'] ?? '',
                    };
                    break;
                  }
                }
              }
            }
          }

          // Stop early if we found all apps
          if (foundApps.length == installedVersions.length) break;
        }
      }
    } catch (_) {}

    return updates;
  }

  Future<List<AppCollection>> fetchCollections() async {
    try {
      final response = await _client.get(
        Uri.parse('${config.rawContentUrl}/store/collections.json'),
        headers: config.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((c) => AppCollection.fromJson(c)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>?> fetchStoreConfig() async {
    try {
      final response = await _client.get(
        Uri.parse('${config.rawContentUrl}/store/config.json'),
        headers: config.headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (_) {}
    return null;
  }

  AppModel _appWithDownloadUrl(AppModel app, String url) {
    return AppModel(
      id: app.id,
      name: app.name,
      packageName: app.packageName,
      developer: app.developer,
      developerEmail: app.developerEmail,
      description: app.description,
      shortDescription: app.shortDescription,
      iconUrl: app.iconUrl,
      screenshots: app.screenshots,
      promoVideoUrl: app.promoVideoUrl,
      category: app.category,
      tags: app.tags,
      version: app.version,
      versionCode: app.versionCode,
      changelog: app.changelog,
      rating: app.rating,
      ratingCount: app.ratingCount,
      downloadCount: app.downloadCount,
      size: app.size,
      minSdk: app.minSdk,
      permissions: app.permissions,
      ageRating: app.ageRating,
      updatedAt: app.updatedAt,
      createdAt: app.createdAt,
      downloadUrl: url,
      architecture: app.architecture,
      isEditorChoice: app.isEditorChoice,
      isTrending: app.isTrending,
      isFeatured: app.isFeatured,
      signature: app.signature,
      reviews: app.reviews,
      versionHistory: app.versionHistory,
    );
  }

  void dispose() {
    _client.close();
  }
}
