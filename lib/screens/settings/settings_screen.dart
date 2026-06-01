import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/storage_service.dart';
import '../../themes/app_theme.dart';
import '../../config/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storage = context.read<StorageService>();
    final themeProvider = context.watch<ThemeProvider>();
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Text(
                  'Settings',
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
            child: _buildGroup(isDark, [
              _buildTile(
                icon: Icons.circle_outlined,
                iconColor: const Color(0xFF007AFF),
                title: 'Appearance',
                trailing: Text(
                  _themeLabel(themeProvider.themeMode),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 15,
                  ),
                ),
                onTap: () => _showThemePicker(themeProvider),
              ),
            ]),
          ),
          SliverToBoxAdapter(
            child: _buildSectionHeader('DOWNLOADS'),
          ),
          SliverToBoxAdapter(
            child: _buildGroup(isDark, [
              _buildSwitchTile(
                icon: Icons.arrow_circle_down_rounded,
                iconColor: const Color(0xFF34C759),
                title: 'Auto-update',
                subtitle: 'Check for updates automatically',
                value: storage.getAutoUpdate(),
                onChanged: (v) async {
                  await storage.setAutoUpdate(v);
                  setState(() {});
                },
              ),
              _buildSwitchTile(
                icon: Icons.update_rounded,
                iconColor: const Color(0xFFFF9500),
                title: 'Background updates',
                subtitle: 'Download and install app updates automatically',
                value: storage.getBackgroundUpdates(),
                onChanged: (v) async {
                  await storage.setBackgroundUpdates(v);
                  setState(() {});
                },
              ),
              _buildSwitchTile(
                icon: Icons.wifi_rounded,
                iconColor: const Color(0xFF007AFF),
                title: 'Wi-Fi only',
                subtitle: 'Only download over Wi-Fi',
                value: storage.getDownloadOverWifiOnly(),
                onChanged: (v) async {
                  await storage.setDownloadOverWifiOnly(v);
                  setState(() {});
                },
              ),
            ]),
          ),
          SliverToBoxAdapter(
            child: _buildSectionHeader('NOTIFICATIONS'),
          ),
          SliverToBoxAdapter(
            child: _buildGroup(isDark, [
              _buildSwitchTile(
                icon: Icons.notifications_rounded,
                iconColor: const Color(0xFFFF3B30),
                title: 'Push notifications',
                value: storage.getNotificationsEnabled(),
                onChanged: (v) async {
                  await storage.setNotificationsEnabled(v);
                  setState(() {});
                },
              ),
            ]),
          ),
          SliverToBoxAdapter(
            child: _buildSectionHeader('SECURITY'),
          ),
          SliverToBoxAdapter(
            child: _buildGroup(isDark, [
              _buildTile(
                icon: Icons.verified_user_rounded,
                iconColor: const Color(0xFF34C759),
                title: 'App verification',
                trailing: Text(
                  'On',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 15,
                  ),
                ),
              ),
              _buildTile(
                icon: Icons.shield_rounded,
                iconColor: const Color(0xFF5856D6),
                title: 'Malware scanning',
                trailing: Text(
                  'On',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 15,
                  ),
                ),
              ),
            ]),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
              child: Center(
                child: Text(
                  'App Store v${AppConstants.appVersion}',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 28, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildGroup(bool isDark, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LiquidGlassCard(
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
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
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }

  void _showThemePicker(ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
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
                  'Appearance',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                _themeOption('Light', ThemeMode.light, themeProvider),
                _themeOption('Dark', ThemeMode.dark, themeProvider),
                _themeOption('System', ThemeMode.system, themeProvider),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _themeOption(String label, ThemeMode mode, ThemeProvider provider) {
    final isSelected = provider.themeMode == mode;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        provider.setThemeMode(mode);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_rounded, color: Color(0xFF007AFF), size: 20),
          ],
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System';
    }
  }
}
