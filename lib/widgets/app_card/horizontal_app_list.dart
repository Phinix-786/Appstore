import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/app_model.dart';
import '../../themes/app_theme.dart';

class HorizontalAppList extends StatelessWidget {
  final List<AppModel> apps;
  final Function(AppModel) onAppTap;

  const HorizontalAppList({
    super.key,
    required this.apps,
    required this.onAppTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: (apps.length / 3).ceil(),
        itemBuilder: (context, groupIndex) {
          final startIdx = groupIndex * 3;
          final items = apps.skip(startIdx).take(3).toList();

          return LiquidGlassCard(
            margin: const EdgeInsets.only(right: 16),
            child: SizedBox(
            width: 300,
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _buildRow(items[i], theme, i + startIdx + 1),
                  if (i < items.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 72),
                      child: Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color: theme.dividerTheme.color,
                      ),
                    ),
                ],
              ],
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(AppModel app, ThemeData theme, int rank) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onAppTap(app),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: app.iconUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 44,
                  height: 44,
                  color: const Color(0xFFE5E5EA),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 44,
                  height: 44,
                  color: const Color(0xFFE5E5EA),
                  child: const Icon(Icons.apps_rounded, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    app.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF3A3A3C)
                    : const Color(0xFFE5E5EA).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'GET',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
