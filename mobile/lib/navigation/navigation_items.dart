import 'package:flutter/material.dart';
import 'package:maxie_mobile/models/navigation_item.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';

const appNavigationItems = <NavigationItem>[
  NavigationItem(
    label: 'Home',
    location: AppRoutes.home,
    icon: Icons.home_rounded,
  ),
  NavigationItem(
    label: 'Chat',
    location: AppRoutes.aiChat,
    icon: Icons.auto_awesome_rounded,
  ),
  NavigationItem(
    label: 'Profile',
    location: AppRoutes.profile,
    icon: Icons.person_rounded,
  ),
  NavigationItem(
    label: 'Settings',
    location: AppRoutes.settings,
    icon: Icons.settings_rounded,
  ),
];
