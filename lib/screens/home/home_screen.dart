import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/app_model.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_card/app_card.dart';
import '../../widgets/app_card/featured_card.dart';
import '../../widgets/app_card/horizontal_app_list.dart';
import '../../widgets/shimmer/shimmer_loading.dart';
import '../app_detail/app_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        color: const Color(0xFF007AFF),
        onRefresh: () => appProvider.refreshApps(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        today.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Today',
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
            if (appProvider.isLoading)
              const SliverFillRemaining(child: ShimmerHomeLoading())
            else if (appProvider.error != null && appProvider.allApps.isEmpty)
              SliverFillRemaining(child: _buildError(appProvider, theme))
            else ...[
              if (appProvider.featuredApps.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildFeatured(appProvider.featuredApps, context),
                ),
              if (appProvider.editorChoiceApps.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(
                    context,
                    'Editor\'s Choice',
                    appProvider.editorChoiceApps,
                  ),
                ),
              if (appProvider.trendingApps.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(context, 'Trending', appProvider.trendingApps),
                ),
              if (appProvider.topRated.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(context, 'Top Rated', appProvider.topRated),
                ),
              if (appProvider.topDownloaded.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(context, 'Popular', appProvider.topDownloaded),
                ),
              if (appProvider.newReleases.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(
                      context, 'New Releases', appProvider.newReleases),
                ),
              if (appProvider.allApps.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                    child: Text(
                      'All Apps',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: LiquidGlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          for (int i = 0; i < appProvider.allApps.length; i++) ...[
                            AppCard(
                              app: appProvider.allApps[i],
                              onTap: () => _openApp(context, appProvider.allApps[i]),
                            ),
                            if (i < appProvider.allApps.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 76),
                                child: Divider(
                                  height: 0.5,
                                  color: theme.dividerTheme.color,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatured(List<AppModel> apps, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 320,
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.92),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FeaturedCard(
                app: apps[index],
                onTap: () => _openApp(context, apps[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<AppModel> apps) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 14),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ),
        HorizontalAppList(apps: apps, onAppTap: (app) => _openApp(context, app)),
      ],
    );
  }

  Widget _buildError(AppProvider provider, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to Connect',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => provider.refreshApps(),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openApp(BuildContext context, AppModel app) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AppDetailScreen(app: app)),
    );
  }
}
