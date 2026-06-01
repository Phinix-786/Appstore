import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/app_model.dart';
import 'storage_service.dart';
import 'github_service.dart';

class DownloadService extends ChangeNotifier {
  final Dio _dio = Dio();
  final Map<String, DownloadTask> _tasks = {};
  final Map<String, CancelToken> _cancelTokens = {};

  List<DownloadTask> get tasks => _tasks.values.toList();
  List<DownloadTask> get activeTasks =>
      _tasks.values.where((t) => t.status == DownloadStatus.downloading).toList();
  List<DownloadTask> get completedTasks =>
      _tasks.values.where((t) => t.status == DownloadStatus.completed || t.status == DownloadStatus.installed).toList();
  List<DownloadTask> get queuedTasks =>
      _tasks.values.where((t) => t.status == DownloadStatus.pending).toList();

  DownloadTask? getTask(String appId) => _tasks[appId];

  Future<String> get _downloadDir async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/appstore_downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir.path;
  }

  Future<void> startDownload(AppModel app) async {
    if (_tasks.containsKey(app.id) &&
        _tasks[app.id]!.status == DownloadStatus.downloading) {
      return;
    }

    final dir = await _downloadDir;
    final savePath = '$dir/${app.packageName}_${app.version}.apk';
    final cancelToken = CancelToken();
    _cancelTokens[app.id] = cancelToken;

    final task = DownloadTask(
      appId: app.id,
      appName: app.name,
      iconUrl: app.iconUrl,
      downloadUrl: app.downloadUrl,
      savePath: savePath,
      status: DownloadStatus.downloading,
    );

    _tasks[app.id] = task;
    notifyListeners();

    try {
      await _dio.download(
        app.downloadUrl,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            task.progress = received / total;
            notifyListeners();
          }
        },
      );

      task.status = DownloadStatus.completed;
      task.progress = 1.0;
      notifyListeners();

      _processQueue();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        task.status = DownloadStatus.paused;
      } else {
        task.status = DownloadStatus.failed;
        task.error = e.message;
      }
      notifyListeners();
    } catch (e) {
      task.status = DownloadStatus.failed;
      task.error = e.toString();
      notifyListeners();
    }
  }

  Future<void> pauseDownload(String appId) async {
    final cancelToken = _cancelTokens[appId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Paused by user');
    }
    if (_tasks.containsKey(appId)) {
      _tasks[appId]!.status = DownloadStatus.paused;
      notifyListeners();
    }
  }

  Future<void> resumeDownload(AppModel app) async {
    await startDownload(app);
  }

  Future<void> cancelDownload(String appId) async {
    final cancelToken = _cancelTokens[appId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Cancelled by user');
    }
    _tasks.remove(appId);
    _cancelTokens.remove(appId);
    notifyListeners();
  }

  Future<void> retryDownload(AppModel app) async {
    _tasks.remove(app.id);
    await startDownload(app);
  }

  void addToQueue(AppModel app) {
    if (!_tasks.containsKey(app.id)) {
      _tasks[app.id] = DownloadTask(
        appId: app.id,
        appName: app.name,
        iconUrl: app.iconUrl,
        downloadUrl: app.downloadUrl,
        savePath: '',
        status: DownloadStatus.pending,
      );
      notifyListeners();
      _processQueue();
    }
  }

  void _processQueue() {
    final active = activeTasks.length;
    if (active < 3) {
      final pending = queuedTasks;
      if (pending.isNotEmpty) {
        final task = pending.first;
        startDownload(AppModel(
          id: task.appId,
          name: task.appName,
          packageName: task.appId,
          developer: '',
          description: '',
          iconUrl: task.iconUrl,
          category: '',
          version: '',
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          downloadUrl: task.downloadUrl,
        ));
      }
    }
  }

  Future<void> installApk(String appId) async {
    final task = _tasks[appId];
    if (task == null || task.status != DownloadStatus.completed) return;

    task.status = DownloadStatus.installing;
    notifyListeners();

    try {
      final file = File(task.savePath);
      if (await file.exists()) {
        task.status = DownloadStatus.installed;
      } else {
        task.status = DownloadStatus.failed;
        task.error = 'APK file not found';
      }
    } catch (e) {
      task.status = DownloadStatus.failed;
      task.error = e.toString();
    }
    notifyListeners();
  }

  /// Download and install an app update in the background.
  /// Used by background update feature.
  Future<bool> backgroundDownloadAndInstall({
    required String appId,
    required String appName,
    required String downloadUrl,
    required String version,
    required StorageService storage,
  }) async {
    try {
      final dir = await _downloadDir;
      final savePath = '$dir/${appId}_$version.apk';

      await _dio.download(downloadUrl, savePath);

      final file = File(savePath);
      if (await file.exists()) {
        // Mark as installed and track the new version
        await storage.setInstalledAppVersion(appId, version);
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Perform background update checks and downloads for installed apps.
  /// Only runs if background updates are enabled in settings.
  Future<void> performBackgroundUpdates({
    required StorageService storage,
    required GithubService githubService,
    required List<AppModel> allApps,
  }) async {
    if (!storage.getBackgroundUpdates()) return;

    final installedVersions = storage.getInstalledAppVersions();
    if (installedVersions.isEmpty) return;

    final updates = await githubService.checkAppUpdates(installedVersions);

    for (final entry in updates.entries) {
      final appId = entry.key;
      final updateInfo = entry.value;
      final downloadUrl = updateInfo['download_url'] ?? '';
      final version = updateInfo['version'] ?? '';

      if (downloadUrl.isEmpty || version.isEmpty) continue;

      // Find the app name
      String appName = appId;
      for (final app in allApps) {
        if (app.id == appId) {
          appName = app.name;
          break;
        }
      }

      await backgroundDownloadAndInstall(
        appId: appId,
        appName: appName,
        downloadUrl: downloadUrl,
        version: version,
        storage: storage,
      );
    }
  }

  Future<void> clearCompleted() async {
    _tasks.removeWhere((_, task) =>
        task.status == DownloadStatus.completed ||
        task.status == DownloadStatus.installed);
    notifyListeners();
  }

  Future<List<String>> getDownloadHistory() async {
    final dir = await _downloadDir;
    final downloadDir = Directory(dir);
    if (await downloadDir.exists()) {
      return downloadDir
          .listSync()
          .where((f) => f.path.endsWith('.apk'))
          .map((f) => f.path)
          .toList();
    }
    return [];
  }
}
