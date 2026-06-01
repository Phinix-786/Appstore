import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/app_card/app_card.dart';
import '../app_detail/app_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final storage = context.read<StorageService>();
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My List'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Wishlist'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(
              appProvider.getWishlistApps(),
              theme,
              Icons.bookmark_border,
              'Your wishlist is empty',
              'Save apps you want to try later',
              context,
            ),
            _buildList(
              appProvider.getFavoriteApps(),
              theme,
              Icons.favorite_border,
              'No favorites yet',
              'Mark apps as favorites for quick access',
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    List apps,
    ThemeData theme,
    IconData emptyIcon,
    String emptyTitle,
    String emptySubtitle,
    BuildContext context,
  ) {
    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(emptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(emptySubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                )),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        return AppCard(
          app: apps[index],
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AppDetailScreen(app: apps[index]),
            ),
          ),
        );
      },
    );
  }
}
