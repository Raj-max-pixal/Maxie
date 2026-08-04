import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/config/app_state.dart';
import 'package:maxie_mobile/navigation/navigation_items.dart';
import 'package:maxie_mobile/shared/responsive_layout.dart';
import 'package:maxie_mobile/theme/app_spacing.dart';
import 'package:maxie_mobile/widgets/offline_banner.dart';

class AppPage extends ConsumerWidget {
  const AppPage({
    required this.title,
    required this.child,
    super.key,
    this.actions = const [],
    this.showNavigation = true,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final bool showNavigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(offlineProvider);
    final layout = ResponsiveLayout.of(context);
    final currentLocation = GoRouterState.of(context).uri.toString();
    final selectedIndex = appNavigationItems.indexWhere(
      (item) => currentLocation == item.location,
    );

    final pageBody = Column(
      children: [
        if (isOffline) const OfflineBanner(),
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveLayout.contentWidth(context),
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  layout == DeviceLayout.mobile ? AppSpacing.md : AppSpacing.xl,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );

    if (!showNavigation || layout == DeviceLayout.mobile) {
      return Scaffold(
        appBar: AppBar(title: Text(title), actions: actions),
        body: pageBody,
        bottomNavigationBar: showNavigation
            ? NavigationBar(
                selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
                onDestinationSelected: (index) {
                  context.go(appNavigationItems[index].location);
                },
                destinations: [
                  for (final item in appNavigationItems)
                    NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                ],
              )
            : null,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
            extended: layout == DeviceLayout.desktop,
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
          Expanded(
            child: Scaffold(
              appBar: AppBar(title: Text(title), actions: actions),
              body: pageBody,
            ),
          ),
        ],
      ),
    );
  }
}
