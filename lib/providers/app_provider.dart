import 'package:flutter/foundation.dart';
import '../models/app_model.dart';
import '../services/github_service.dart';
import '../services/storage_service.dart';
import '../services/download_service.dart';
import '../config/github_config.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage;
  GithubService? _githubService;

  List<AppModel> _allApps = [];
  List<AppModel> _filteredApps = [];
  List<AppCollection> _collections = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'all';
  String _sortBy = 'name';
  String _searchQuery = '';

  // Self-update state
  bool _selfUpdateAvailable = false;
  String _selfUpdateVersion = '';
  String _selfUpdateUrl = '';

  // App updates state: appId -> {version, download_url}
  Map<String, Map<String, String>> _appUpdates = {};

  AppProvider(this._storage);

  List<AppModel> get allApps => _allApps;
  List<AppModel> get filteredApps => _filteredApps;
  List<AppCollection> get collections => _collections;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;

  // Self-update getters
  bool get selfUpdateAvailable => _selfUpdateAvailable;
  String get selfUpdateVersion => _selfUpdateVersion;
  String get selfUpdateUrl => _selfUpdateUrl;

  // App updates getters
  Map<String, Map<String, String>> get appUpdates => _appUpdates;
  bool hasUpdate(String appId) => _appUpdates.containsKey(appId);
  String? getUpdateVersion(String appId) => _appUpdates[appId]?['version'];

  GithubService? get githubService => _githubService;

  List<AppModel> get featuredApps =>
      _allApps.where((a) => a.isFeatured).toList();
  List<AppModel> get trendingApps =>
      _allApps.where((a) => a.isTrending).toList();
  List<AppModel> get editorChoiceApps =>
      _allApps.where((a) => a.isEditorChoice).toList();
  List<AppModel> get newReleases {
    final sorted = List<AppModel>.from(_allApps)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(20).toList();
  }
  List<AppModel> get topRated {
    final sorted = List<AppModel>.from(_allApps)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(20).toList();
  }
  List<AppModel> get topDownloaded {
    final sorted = List<AppModel>.from(_allApps)
      ..sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
    return sorted.take(20).toList();
  }

  void initGithubService(GithubConfig config) {
    _githubService = GithubService(config);
  }

  Future<void> loadApps() async {
    if (_githubService == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allApps = await _githubService!.fetchAllApps();
      _collections = await _githubService!.fetchCollections();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Failed to load apps: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshApps() async {
    await loadApps();
    // Also check for updates after refreshing
    await checkForUpdates();
  }

  /// Check for self-update and installed app updates.
  Future<void> checkForUpdates() async {
    if (_githubService == null) return;

    // Check self-update
    await _checkSelfUpdate();

    // Check installed app updates
    await _checkInstalledAppUpdates();

    notifyListeners();
  }

  Future<void> _checkSelfUpdate() async {
    if (_githubService == null) return;

    try {
      final updateInfo = await _githubService!.checkSelfUpdate();
      if (updateInfo != null) {
        _selfUpdateAvailable = true;
        _selfUpdateVersion = updateInfo['version'] ?? '';
        _selfUpdateUrl = updateInfo['download_url'] ?? '';
      } else {
        _selfUpdateAvailable = false;
        _selfUpdateVersion = '';
        _selfUpdateUrl = '';
      }
    } catch (_) {
      // Silently fail - don't disrupt the user experience
    }
  }

  Future<void> _checkInstalledAppUpdates() async {
    if (_githubService == null) return;

    try {
      final installedVersions = _storage.getInstalledAppVersions();
      if (installedVersions.isEmpty) return;

      _appUpdates = await _githubService!.checkAppUpdates(installedVersions);
    } catch (_) {
      // Silently fail
    }
  }

  /// Dismiss self-update banner.
  void dismissSelfUpdate() {
    _selfUpdateAvailable = false;
    notifyListeners();
  }

  /// Mark an app as installed with its version.
  Future<void> markAppInstalled(String appId, String version) async {
    await _storage.addInstalledApp(appId);
    await _storage.setInstalledAppVersion(appId, version);
    // Remove from updates map if it was there
    _appUpdates.remove(appId);
    notifyListeners();
  }

  /// Check if an app is installed.
  bool isAppInstalled(String appId) {
    return _storage.getInstalledApps().contains(appId);
  }

  /// Perform background updates for installed apps.
  Future<void> performBackgroundUpdates(DownloadService downloadService) async {
    if (_githubService == null) return;
    if (!_storage.getBackgroundUpdates()) return;

    await downloadService.performBackgroundUpdates(
      storage: _storage,
      githubService: _githubService!,
      allApps: _allApps,
    );

    // Re-check for updates after background updates complete
    await _checkInstalledAppUpdates();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    _applyFilters();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    if (query.isNotEmpty) {
      _storage.addSearchHistory(query);
    }
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredApps = List.from(_allApps);

    if (_selectedCategory != 'all') {
      _filteredApps = _filteredApps
          .where((a) => a.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      _filteredApps = _filteredApps.where((a) {
        return a.name.toLowerCase().contains(query) ||
            a.description.toLowerCase().contains(query) ||
            a.developer.toLowerCase().contains(query) ||
            a.tags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    switch (_sortBy) {
      case 'name':
        _filteredApps.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'rating':
        _filteredApps.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'downloads':
        _filteredApps.sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
        break;
      case 'date':
        _filteredApps.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'size':
        _filteredApps.sort((a, b) => a.size.compareTo(b.size));
        break;
    }
  }

  List<AppModel> getAppsByCategory(String category) =>
      _allApps.where((a) => a.category.toLowerCase() == category.toLowerCase()).toList();

  List<AppModel> getAppsByDeveloper(String developer) =>
      _allApps.where((a) => a.developer == developer).toList();

  AppModel? getAppById(String id) {
    try {
      return _allApps.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  List<AppModel> getRelatedApps(AppModel app) {
    return _allApps
        .where((a) =>
            a.id != app.id &&
            (a.category == app.category || a.developer == app.developer))
        .take(10)
        .toList();
  }

  List<AppModel> getWishlistApps() {
    final wishlist = _storage.getWishlist();
    return _allApps.where((a) => wishlist.contains(a.id)).toList();
  }

  List<AppModel> getFavoriteApps() {
    final favorites = _storage.getFavorites();
    return _allApps.where((a) => favorites.contains(a.id)).toList();
  }

  Map<String, int> getCategoryCounts() {
    final counts = <String, int>{};
    for (final app in _allApps) {
      counts[app.category] = (counts[app.category] ?? 0) + 1;
    }
    return counts;
  }
}
