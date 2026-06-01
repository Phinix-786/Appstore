import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_constants.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_card/app_card.dart';
import '../../themes/app_theme.dart';
import '../app_detail/app_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appProvider = context.watch<AppProvider>();
    final isDark = theme.brightness == Brightness.dark;

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
                  children: [
                    if (_selectedCategory != null)
                      GestureDetector(
                        onTap: () => setState(() => _selectedCategory = null),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 20,
                            color: const Color(0xFF007AFF),
                          ),
                        ),
                      ),
                    Text(
                      _selectedCategory != null
                          ? AppConstants.categories
                              .firstWhere((c) => c.id == _selectedCategory)
                              .name
                          : 'Browse',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_selectedCategory == null) ...[
            const SliverPadding(padding: EdgeInsets.only(top: 20)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: LiquidGlassCard(
                  child: Column(
                    children: [
                      for (int i = 0; i < AppConstants.categories.length; i++) ...[
                        _buildCategoryRow(AppConstants.categories[i], theme),
                        if (i < AppConstants.categories.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 56),
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
          ] else ...[
            const SliverPadding(padding: EdgeInsets.only(top: 16)),
            _buildCategoryApps(appProvider, isDark),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(CategoryInfo category, ThemeData theme) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedCategory = category.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(category.icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryApps(AppProvider appProvider, bool isDark) {
    final apps = appProvider.getAppsByCategory(_selectedCategory!);

    if (apps.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.apps_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 12),
              Text(
                'No apps yet',
                style: TextStyle(
                  fontSize: 17,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: LiquidGlassCard(
          child: Column(
            children: [
              for (int i = 0; i < apps.length; i++) ...[
                AppCard(
                  app: apps[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AppDetailScreen(app: apps[i]),
                    ),
                  ),
                ),
                if (i < apps.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 76),
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
    );
  }
}
