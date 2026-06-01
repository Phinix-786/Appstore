import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:timeago/timeago.dart' as timeago;
import '../../models/app_model.dart';
import '../../services/download_service.dart';
import '../../services/storage_service.dart';
import '../../services/security_service.dart';
import '../../providers/app_provider.dart';
import '../../themes/app_theme.dart';

class AppDetailScreen extends StatefulWidget {
  final AppModel app;

  const AppDetailScreen({super.key, required this.app});

  @override
  State<AppDetailScreen> createState() => _AppDetailScreenState();
}

class _AppDetailScreenState extends State<AppDetailScreen> {
  bool _isInWishlist = false;
  bool _descExpanded = false;

  @override
  void initState() {
    super.initState();
    final storage = context.read<StorageService>();
    _isInWishlist = storage.isInWishlist(widget.app.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final downloadService = context.watch<DownloadService>();
    final task = downloadService.getTask(widget.app.id);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 20,
                            color: Color(0xFF007AFF),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => share_plus.Share.share(
                            'Check out ${widget.app.name}!',
                          ),
                          child: Icon(
                            Icons.ios_share_rounded,
                            size: 22,
                            color: const Color(0xFF007AFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildHeader(theme, isDark, task, downloadService)),
              if (widget.app.screenshots.isNotEmpty)
                SliverToBoxAdapter(child: _buildScreenshots(theme)),
              SliverToBoxAdapter(child: _buildDescription(theme, isDark)),
              SliverToBoxAdapter(child: _buildInfo(theme, isDark)),
              if (widget.app.permissions.isNotEmpty)
                SliverToBoxAdapter(child: _buildPermissions(theme, isDark)),
              SliverToBoxAdapter(child: _buildRatings(theme, isDark)),
              SliverToBoxAdapter(child: _buildRelatedApps(isDark)),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomAction(theme, isDark, task, downloadService),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark, DownloadTask? task,
      DownloadService service) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'app_icon_${widget.app.id}',
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: widget.app.iconUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFFE5E5EA),
                    child: const Icon(Icons.apps_rounded, size: 48),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.app.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.app.developer,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 14),
                _buildActionButton(task, service, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      DownloadTask? task, DownloadService service, ThemeData theme) {
    final appProvider = context.watch<AppProvider>();
    final hasUpdate = appProvider.hasUpdate(widget.app.id);

    if (task != null && task.status == DownloadStatus.downloading) {
      return SizedBox(
        width: 70,
        height: 30,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                value: task.progress,
                strokeWidth: 2.5,
                color: const Color(0xFF007AFF),
                backgroundColor: const Color(0xFFE5E5EA),
              ),
            ),
            GestureDetector(
              onTap: () => service.pauseDownload(widget.app.id),
              child: const Icon(Icons.stop_rounded, size: 14, color: Color(0xFF007AFF)),
            ),
          ],
        ),
      );
    }

    final buttonLabel = hasUpdate ? 'UPDATE' : 'GET';

    return GestureDetector(
      onTap: widget.app.downloadUrl.isNotEmpty
          ? () {
              service.startDownload(widget.app);
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          buttonLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildScreenshots(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: SizedBox(
        height: 340,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: widget.app.screenshots.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: widget.app.screenshots[index],
                  height: 340,
                  width: 170,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 170,
                    color: const Color(0xFFE5E5EA),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDescription(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.app.description,
              maxLines: _descExpanded ? null : 3,
              overflow: _descExpanded ? null : TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
            if (widget.app.description.length > 100)
              GestureDetector(
                onTap: () => setState(() => _descExpanded = !_descExpanded),
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _descExpanded ? 'less' : 'more',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF007AFF),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: LiquidGlassCard(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            _infoRow('Version', widget.app.version, theme, isDark),
            _infoRow('Size', widget.app.formattedSize, theme, isDark),
            _infoRow('Category', widget.app.category, theme, isDark),
            _infoRow('Updated', timeago.format(widget.app.updatedAt), theme, isDark),
            _infoRow('Rating', widget.app.ageRating, theme, isDark, showDivider: false),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, ThemeData theme, bool isDark,
      {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Divider(
              height: 0.5,
              thickness: 0.5,
              color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
            ),
          ),
      ],
    );
  }

  Widget _buildPermissions(ThemeData theme, bool isDark) {
    final riskLevel = SecurityService.getRiskLevel(widget.app.permissions);
    final riskColor = riskLevel == 'High'
        ? const Color(0xFFFF3B30)
        : riskLevel == 'Medium'
            ? const Color(0xFFFF9500)
            : const Color(0xFF34C759);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Privacy',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$riskLevel Risk',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: riskColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.app.permissions.length} permissions requested',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatings(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ratings & Reviews',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  widget.app.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < widget.app.rating.round()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 16,
                          color: const Color(0xFFFF9500),
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.app.ratingCount} Ratings',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (widget.app.reviews.isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(
                height: 0.5,
                color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
              ),
              const SizedBox(height: 12),
              ...widget.app.reviews.take(3).map((r) => _reviewTile(r, theme)),
            ],
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showWriteReview,
              child: const Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewTile(AppReview review, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.userName,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                timeago.format(review.date),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < review.rating.round()
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                size: 12,
                color: const Color(0xFFFF9500),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedApps(bool isDark) {
    final appProvider = context.read<AppProvider>();
    final related = appProvider.getRelatedApps(widget.app);
    if (related.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You Might Also Like',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: related.length,
              itemBuilder: (_, i) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => AppDetailScreen(app: related[i]),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: related[i].iconUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: const Color(0xFFE5E5EA),
                              child: const Icon(Icons.apps_rounded, size: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 60,
                          child: Text(
                            related[i].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(
      ThemeData theme, bool isDark, DownloadTask? task, DownloadService service) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
                width: 0.33,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.app.name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.app.formattedSize,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildBottomButton(task, service),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(DownloadTask? task, DownloadService service) {
    final appProvider = context.watch<AppProvider>();
    final hasUpdate = appProvider.hasUpdate(widget.app.id);

    if (task != null && task.status == DownloadStatus.downloading) {
      return SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          value: task.progress,
          strokeWidth: 2.5,
          color: const Color(0xFF007AFF),
          backgroundColor: const Color(0xFFE5E5EA),
        ),
      );
    }

    if (task != null && task.status == DownloadStatus.completed) {
      return GestureDetector(
        onTap: () async {
          await service.installApk(widget.app.id);
          // Track the installed app version
          if (mounted) {
            await appProvider.markAppInstalled(widget.app.id, widget.app.version);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF34C759),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'INSTALL',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    final buttonLabel = hasUpdate ? 'UPDATE' : 'GET';

    return GestureDetector(
      onTap: widget.app.downloadUrl.isNotEmpty
          ? () => service.startDownload(widget.app)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF007AFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          buttonLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showWriteReview() {
    double rating = 0;
    final commentController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(12),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Write a Review',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              itemCount: 5,
              itemSize: 36,
              itemBuilder: (_, __) =>
                  const Icon(Icons.star_rounded, color: Color(0xFFFF9500)),
              onRatingUpdate: (r) => rating = r,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF38383A)
                        : const Color(0xFFE5E5EA),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  if (rating > 0) {
                    context.read<StorageService>().saveReview(widget.app.id, {
                      'rating': rating,
                      'comment': commentController.text,
                      'date': DateTime.now().toIso8601String(),
                    });
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
