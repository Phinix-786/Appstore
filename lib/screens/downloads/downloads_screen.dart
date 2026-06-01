import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/download_service.dart';
import '../../models/app_model.dart';
import '../../themes/app_theme.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final downloadService = context.watch<DownloadService>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final active = downloadService.activeTasks;
    final completed = downloadService.completedTasks;
    final queued = downloadService.queuedTasks;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Downloads',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (completed.isNotEmpty)
                      GestureDetector(
                        onTap: () => downloadService.clearCompleted(),
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (active.isEmpty && completed.isEmpty && queued.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 48,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No downloads',
                      style: TextStyle(
                        fontSize: 17,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (active.isNotEmpty || queued.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _sectionHeader('Active', theme),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: LiquidGlassCard(
                    child: Column(
                      children: [
                        for (final task in [...active, ...queued])
                          _buildActiveItem(task, downloadService, theme),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (completed.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _sectionHeader('Completed', theme),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: LiquidGlassCard(
                    child: Column(
                      children: [
                        for (int i = 0; i < completed.length; i++) ...[
                          _buildCompletedItem(completed[i], downloadService, theme),
                          if (i < completed.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 72),
                              child: Divider(
                                height: 0.5,
                                thickness: 0.5,
                                color: isDark
                                    ? const Color(0xFF38383A)
                                    : const Color(0xFFE5E5EA),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildActiveItem(
      DownloadTask task, DownloadService service, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.apps_rounded, size: 22, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.appName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: task.status == DownloadStatus.downloading
                        ? task.progress
                        : null,
                    backgroundColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    color: const Color(0xFF007AFF),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => service.cancelDownload(task.appId),
            child: Icon(
              Icons.close_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedItem(
      DownloadTask task, DownloadService service, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.apps_rounded, size: 22, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              task.appName,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (task.status == DownloadStatus.completed)
            GestureDetector(
              onTap: () => service.installApk(task.appId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3C)
                      : const Color(0xFFE5E5EA).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'INSTALL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
            )
          else
            const Icon(Icons.check_circle_rounded,
                size: 20, color: Color(0xFF34C759)),
        ],
      ),
    );
  }
}
