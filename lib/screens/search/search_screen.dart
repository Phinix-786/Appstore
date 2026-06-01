import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/app_card/app_card.dart';
import '../../themes/app_theme.dart';
import '../app_detail/app_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final storage = context.read<StorageService>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final searchHistory = storage.getSearchHistory();

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
                child: Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: GlassContainer(
                borderRadius: 10,
                enableBlur: true,
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Games, Apps, Stories...',
                    border: InputBorder.none,
                    filled: false,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              appProvider.search('');
                              setState(() {});
                            },
                            child: Icon(
                              Icons.cancel_rounded,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                              size: 18,
                            ),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 16),
                  onChanged: (value) {
                    appProvider.search(value);
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    if (value.isNotEmpty) storage.addSearchHistory(value);
                  },
                ),
              ),
            ),
          ),
          if (_searchController.text.isEmpty) ...[
            if (searchHistory.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await storage.clearSearchHistory();
                          setState(() {});
                        },
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
            if (searchHistory.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: LiquidGlassCard(
                    child: Column(
                      children: [
                        for (int i = 0; i < searchHistory.length; i++) ...[
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              _searchController.text = searchHistory[i];
                              appProvider.search(searchHistory[i]);
                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 18,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      searchHistory[i],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Icon(
                                    Icons.north_west_rounded,
                                    size: 14,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (i < searchHistory.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 46),
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
            if (searchHistory.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 56,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Discover apps',
                        style: TextStyle(
                          fontSize: 17,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ] else ...[
            if (appProvider.filteredApps.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No results',
                    style: TextStyle(
                      fontSize: 17,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              )
            else ...[
              const SliverPadding(padding: EdgeInsets.only(top: 16)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: LiquidGlassCard(
                    child: Column(
                      children: [
                        for (int i = 0;
                            i < appProvider.filteredApps.length;
                            i++) ...[
                          AppCard(
                            app: appProvider.filteredApps[i],
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AppDetailScreen(
                                    app: appProvider.filteredApps[i]),
                              ),
                            ),
                          ),
                          if (i < appProvider.filteredApps.length - 1)
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
              ),
            ],
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}
