import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/config/app_state.dart';
import 'package:maxie_mobile/navigation/navigation_items.dart';
import 'package:maxie_mobile/shared/responsive_layout.dart';
import 'package:maxie_mobile/widgets/offline_banner.dart';

/// Shared shell for the mobile companion. The visual language is intentionally
/// quiet: MAXie's character and content get the attention, not a giant chrome.
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
    final selectedIndex = _selectedIndex(context);
    final layout = ResponsiveLayout.of(context);
    final theme = Theme.of(context);
    final content = DecoratedBox(
      decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
      child: Column(
        children: [
          if (ref.watch(offlineProvider)) const OfflineBanner(),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 960),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );

    if (!showNavigation || layout == DeviceLayout.mobile) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: title == null
            ? null
            : AppBar(title: Text(title!), actions: actions),
        body: content,
        bottomNavigationBar: showNavigation
            ? _BottomNavigation(selectedIndex: selectedIndex)
            : null,
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          _SideNavigation(
            selectedIndex: selectedIndex,
            extended: layout == DeviceLayout.desktop,
          ),
          VerticalDivider(
            width: 1,
            color: theme.dividerColor.withValues(alpha: .55),
          ),
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

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({required this.selectedIndex, required this.extended});
  final int selectedIndex;
  final bool extended;

  @override
  Widget build(BuildContext context) => Container(
    width: extended ? 224 : 84,
    color: Theme.of(context).colorScheme.surface,
    padding: const EdgeInsets.fromLTRB(12, 22, 12, 18),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: extended
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: const LinearGradient(
                  colors: [Color(0xFFB8F4DE), Color(0xFF67C6BF)],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF102B31),
                size: 20,
              ),
            ),
            if (extended) ...[
              const SizedBox(width: 10),
              Text(
                'MAXie',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ],
        ),
        const SizedBox(height: 28),
        Expanded(
          child: NavigationRail(
            selectedIndex: selectedIndex,
            extended: extended,
            groupAlignment: -1,
            backgroundColor: Colors.transparent,
            onDestinationSelected: (index) =>
                context.go(appNavigationItems[index].location),
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF9CEED1)
                  : const Color(0xFF168A71),
            ),
            unselectedIconTheme: IconThemeData(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: .58),
            ),
            selectedLabelTextStyle: const TextStyle(
              color: Color(0xFF168A71),
              fontWeight: FontWeight.w800,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: .58),
              fontWeight: FontWeight.w600,
            ),
            indicatorColor: const Color(0xFF9CEED1).withValues(alpha: .12),
            destinations: [
              for (final item in appNavigationItems)
                NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.icon),
                  label: Text(item.label),
                ),
            ],
          ),
        ),
        if (extended)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Your space · private by default',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: .48),
              ),
            ),
          ),
      ],
    ),
  );
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.selectedIndex});
  final int selectedIndex;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: .55),
          ),
        ),
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
    final color = isSelected
        ? (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF9CEED1)
              : const Color(0xFF168A71))
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: .58);
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: .1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
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
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
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
