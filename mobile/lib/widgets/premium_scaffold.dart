import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxie_mobile/config/app_state.dart';
import 'package:maxie_mobile/navigation/navigation_items.dart';
import 'package:maxie_mobile/widgets/offline_banner.dart';

/// MAXie is phone-first. On wider screens the exact mobile experience is
/// centered as a device canvas instead of turning into a desktop dashboard.
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
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = constraints.maxWidth > 480
            ? 480.0
            : constraints.maxWidth;
        final isWidePreview = constraints.maxWidth > 520;
        final body = DecoratedBox(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: isWidePreview
                ? Border.symmetric(
                    vertical: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: .08),
                    ),
                  )
                : null,
            boxShadow: isWidePreview
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: theme.brightness == Brightness.dark ? .26 : .10,
                      ),
                      blurRadius: 36,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              if (ref.watch(offlineProvider)) const OfflineBanner(),
              if (title != null) _MobileTopBar(title: title!, actions: actions),
              Expanded(child: child),
            ],
          ),
        );

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Center(
            child: SizedBox(width: canvasWidth, child: body),
          ),
          bottomNavigationBar: showNavigation
              ? Align(
                  heightFactor: 1,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: canvasWidth,
                    child: _MobileBottomNavigation(
                      selectedIndex: selectedIndex,
                    ),
                  ),
                )
              : null,
        );
      },
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

class _MobileTopBar extends StatelessWidget {
  const _MobileTopBar({required this.title, required this.actions});
  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 58,
        child: Row(
          children: [
            if (canPop)
              IconButton(
                tooltip: 'Back',
                onPressed: context.pop,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              )
            else
              const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            ...actions,
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _MobileBottomNavigation extends StatelessWidget {
  const _MobileBottomNavigation({required this.selectedIndex});
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: .08),
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
    final theme = Theme.of(context);
    final selectedColor = theme.brightness == Brightness.dark
        ? const Color(0xFF9CEED1)
        : const Color(0xFF168A71);
    final color = isSelected
        ? selectedColor
        : theme.colorScheme.onSurface.withValues(alpha: .55);
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor.withValues(alpha: .12) : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
