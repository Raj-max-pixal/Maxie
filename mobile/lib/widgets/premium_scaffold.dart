import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/config/app_state.dart';
import 'package:maxie_mobile/navigation/navigation_items.dart';
import 'package:maxie_mobile/shared/responsive_layout.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/widgets/offline_banner.dart';

class PremiumScaffold extends ConsumerWidget {
  const PremiumScaffold({
    required this.child,
    super.key,
    this.title,
    this.actions = const [],
    this.showNavigation = true,
  });

  final String? title;
  final Widget child;
  final List<Widget> actions;
  final bool showNavigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(offlineProvider);
    final layout = ResponsiveLayout.of(context);
    final selectedIndex = _selectedIndex(context);

    final content = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkScaffold,
            Color(0xFF101827),
            AppColors.darkScaffold,
          ],
        ),
      ),
      child: Column(
        children: [
          if (isOffline) const OfflineBanner(),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveLayout.contentWidth(context),
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );

    if (!showNavigation || layout == DeviceLayout.mobile) {
      return Scaffold(
        appBar: title == null
            ? null
            : AppBar(title: Text(title!), actions: actions),
        body: content,
        bottomNavigationBar: showNavigation
            ? _PremiumBottomNavigation(selectedIndex: selectedIndex)
            : null,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            extended: layout == DeviceLayout.desktop,
            backgroundColor: AppColors.darkSurface,
            onDestinationSelected: (index) {
              context.go(appNavigationItems[index].location);
            },
            destinations: [
              for (final item in appNavigationItems)
                NavigationRailDestination(
                  icon: Icon(item.icon),
                  label: Text(item.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: content),
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = appNavigationItems.indexWhere(
      (item) => location == item.location,
    );
    return index < 0 ? 0 : index;
  }
}

class _PremiumBottomNavigation extends StatelessWidget {
  const _PremiumBottomNavigation({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.darkSurface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.darkStroke),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var index = 0; index < appNavigationItems.length; index++)
              Expanded(
                child: _NavItem(
                  isSelected: selectedIndex == index,
                  icon: appNavigationItems[index].icon,
                  label: appNavigationItems[index].label,
                  onTap: () => context.go(appNavigationItems[index].location),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFFE9D5FF) : const Color(0xFF7F8EA3);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: 220.ms,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.seed.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: isSelected
                ? Border.all(color: AppColors.seed.withValues(alpha: 0.45))
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 21),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
