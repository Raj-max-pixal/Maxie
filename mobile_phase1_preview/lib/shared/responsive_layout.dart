import 'package:flutter/material.dart';
import 'package:maxie_mobile/shared/breakpoints.dart';

enum DeviceLayout { mobile, tablet, desktop }

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    super.key,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  static DeviceLayout of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.desktop) {
      return DeviceLayout.desktop;
    }
    if (width >= Breakpoints.tablet) {
      return DeviceLayout.tablet;
    }
    return DeviceLayout.mobile;
  }

  static double contentWidth(BuildContext context) {
    return switch (of(context)) {
      DeviceLayout.mobile => double.infinity,
      DeviceLayout.tablet => 680,
      DeviceLayout.desktop => 960,
    };
  }

  @override
  Widget build(BuildContext context) {
    return switch (of(context)) {
      DeviceLayout.mobile => mobile,
      DeviceLayout.tablet => tablet ?? mobile,
      DeviceLayout.desktop => desktop ?? tablet ?? mobile,
    };
  }
}
