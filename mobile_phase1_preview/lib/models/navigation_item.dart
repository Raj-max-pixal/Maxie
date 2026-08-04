import 'package:flutter/widgets.dart';

class NavigationItem {
  const NavigationItem({
    required this.label,
    required this.location,
    required this.icon,
  });

  final String label;
  final String location;
  final IconData icon;
}
