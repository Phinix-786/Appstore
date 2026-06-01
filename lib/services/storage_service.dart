import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/github_config.dart';

class StorageService {
  static const _keyGithubOwner = 'github_owner';
  static const _keyGithubRepo = 'github_repo';
  static const _keyGithubBranch = 'github_branch';
  static const _keyGithubToken = 'github_token';
  static const _keyWishlist = 'wishlist';
  static const _keyFavorites = 'favorites';
  static const _keyReviews = 'reviews';
  static const _keyThemeMode = 'theme_mode';
  static const _keyAutoUpdate = 'auto_update';
  static const _keyBackgroundUpdates = 'background_updates';
  static const _keyDownloadOverWifi = 'download_wifi_only';
  static const _keyNotifications = 'notifications_enabled';
  static const _keyInstalledApps = 'installed_apps';
  static const _keyInstalledAppVersions = 'installed_app_versions';
  static const _keySearchHistory = 'search_history';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // GitHub Config
  Future<void> saveGithubConfig(GithubConfig config) async {
    await _prefs.setString(_keyGithubOwner, config.owner);
    await _prefs.setString(_keyGithubRepo, config.repo);
    await _prefs.setString(_keyGithubBranch, config.branch);
    if (config.token != null) {
      await _prefs.setString(_keyGithubToken, config.token!);
    }
  }

  GithubConfig? getGithubConfig() {
    final owner = _prefs.getString(_keyGithubOwner);
    final repo = _prefs.getString(_keyGithubRepo);
    if (owner == null || repo == null) return null;

    return GithubConfig(
      owner: owner,
      repo: repo,
      branch: _prefs.getString(_keyGithubBranch) ?? 'main',
      token: _prefs.getString(_keyGithubToken),
    );
  }

  bool hasGithubConfig() => _prefs.containsKey(_keyGithubOwner);

  // Wishlist
  List<String> getWishlist() =>
      _prefs.getStringList(_keyWishlist) ?? [];

  Future<void> addToWishlist(String appId) async {
    final list = getWishlist();
    if (!list.contains(appId)) {
      list.add(appId);
      await _prefs.setStringList(_keyWishlist, list);
    }
  }

  Future<void> removeFromWishlist(String appId) async {
    final list = getWishlist();
    list.remove(appId);
    await _prefs.setStringList(_keyWishlist, list);
  }

  bool isInWishlist(String appId) => getWishlist().contains(appId);

  // Favorites
  List<String> getFavorites() =>
      _prefs.getStringList(_keyFavorites) ?? [];

  Future<void> toggleFavorite(String appId) async {
    final list = getFavorites();
    if (list.contains(appId)) {
      list.remove(appId);
    } else {
      list.add(appId);
    }
    await _prefs.setStringList(_keyFavorites, list);
  }

  bool isFavorite(String appId) => getFavorites().contains(appId);

  // Reviews
  Future<void> saveReview(String appId, Map<String, dynamic> review) async {
    final reviews = _prefs.getString(_keyReviews);
    final Map<String, dynamic> allReviews =
        reviews != null ? json.decode(reviews) : {};
    allReviews[appId] = review;
    await _prefs.setString(_keyReviews, json.encode(allReviews));
  }

  Map<String, dynamic>? getReview(String appId) {
    final reviews = _prefs.getString(_keyReviews);
    if (reviews == null) return null;
    final allReviews = json.decode(reviews) as Map<String, dynamic>;
    return allReviews[appId] as Map<String, dynamic>?;
  }

  // Settings
  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) => _prefs.setString(_keyThemeMode, mode);

  bool getAutoUpdate() => _prefs.getBool(_keyAutoUpdate) ?? true;
  Future<void> setAutoUpdate(bool value) => _prefs.setBool(_keyAutoUpdate, value);

  bool getBackgroundUpdates() => _prefs.getBool(_keyBackgroundUpdates) ?? false;
  Future<void> setBackgroundUpdates(bool value) => _prefs.setBool(_keyBackgroundUpdates, value);

  bool getDownloadOverWifiOnly() => _prefs.getBool(_keyDownloadOverWifi) ?? false;
  Future<void> setDownloadOverWifiOnly(bool value) =>
      _prefs.setBool(_keyDownloadOverWifi, value);

  bool getNotificationsEnabled() => _prefs.getBool(_keyNotifications) ?? true;
  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_keyNotifications, value);

  // Installed apps tracking
  List<String> getInstalledApps() =>
      _prefs.getStringList(_keyInstalledApps) ?? [];

  Future<void> addInstalledApp(String appId) async {
    final list = getInstalledApps();
    if (!list.contains(appId)) {
      list.add(appId);
      await _prefs.setStringList(_keyInstalledApps, list);
    }
  }

  Future<void> removeInstalledApp(String appId) async {
    final list = getInstalledApps();
    list.remove(appId);
    await _prefs.setStringList(_keyInstalledApps, list);
  }

  // Installed app versions tracking (appId -> version string)
  Map<String, String> getInstalledAppVersions() {
    final raw = _prefs.getString(_keyInstalledAppVersions);
    if (raw == null) return {};
    final decoded = json.decode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<void> setInstalledAppVersion(String appId, String version) async {
    final versions = getInstalledAppVersions();
    versions[appId] = version;
    await _prefs.setString(_keyInstalledAppVersions, json.encode(versions));
  }

  String? getInstalledAppVersion(String appId) {
    return getInstalledAppVersions()[appId];
  }

  Future<void> removeInstalledAppVersion(String appId) async {
    final versions = getInstalledAppVersions();
    versions.remove(appId);
    await _prefs.setString(_keyInstalledAppVersions, json.encode(versions));
  }

  // Search history
  List<String> getSearchHistory() =>
      _prefs.getStringList(_keySearchHistory) ?? [];

  Future<void> addSearchHistory(String query) async {
    final list = getSearchHistory();
    list.remove(query);
    list.insert(0, query);
    if (list.length > 20) list.removeLast();
    await _prefs.setStringList(_keySearchHistory, list);
  }

  Future<void> clearSearchHistory() =>
      _prefs.setStringList(_keySearchHistory, []);
}
