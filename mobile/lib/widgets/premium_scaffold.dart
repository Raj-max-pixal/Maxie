import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/config/app_state.dart';
import 'package:maxie_mobile/navigation/navigation_items.dart';
import 'package:maxie_mobile/shared/responsive_layout.dart';
import 'package:maxie_mobile/theme/app_colors.dart';
import 'package:maxie_mobile/widgets/maxie_atmosphere.dart';
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

    final content = Stack(
      fit: StackFit.expand,
      children: [
        const MaxieAtmosphere(),
        Column(
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
      ],
    );

    if (!showNavigation || layout == DeviceLayout.mobile) {
      return Scaffold(
        extendBody: true,
        backgroundColor: AppColors.midnight,
        appBar: title == null
            ? null
            : AppBar(
                title: Text(
                  title!,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                actions: actions,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
              ),
        body: content,
        bottomNavigationBar: showNavigation
            ? _PremiumBottomNavigation(selectedIndex: selectedIndex)
            : null,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 0, 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.04),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.seed.withValues(alpha: 0.16),
                        blurRadius: 26,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: NavigationRail(
                    selectedIndex: selectedIndex,
                    extended: layout == DeviceLayout.desktop,
                    backgroundColor: Colors.transparent,
                    indicatorColor: AppColors.seed.withValues(alpha: 0.2),
                    selectedIconTheme: const IconThemeData(
                      color: Color(0xFFF5E9FF),
                    ),
                    unselectedIconTheme: const IconThemeData(
                      color: Color(0xFF96A2B8),
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
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
                ),
              ),
            ),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.05),
                    AppColors.seed.withValues(alpha: 0.04),
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.seed.withValues(alpha: 0.28),
                    blurRadius: 34,
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
                        onTap: () =>
                            context.go(appNavigationItems[index].location),
                      ),
                    ),
                ],
              ),
            ),
          ),
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
    final color = isSelected ? const Color(0xFFF5E9FF) : const Color(0xFF8B97AD);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: 240.ms,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.seed.withValues(alpha: 0.55),
                      AppColors.calmTeal.withValues(alpha: 0.28),
                    ],
                  )
                : null,
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.transparent,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.seed.withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22)
                  .animate(target: isSelected ? 1 : 0)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.12, 1.12),
                    duration: 220.ms,
                  ),
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
