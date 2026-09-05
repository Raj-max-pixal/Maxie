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
    icon: Icons.chat_bubble_outline_rounded,
  ),
  NavigationItem(
    label: 'Memory',
    location: AppRoutes.memory,
    icon: Icons.auto_stories_rounded,
  ),
  NavigationItem(
    label: 'Pet',
    location: AppRoutes.pet,
    icon: Icons.smart_toy_outlined,
  ),
  NavigationItem(
    label: 'Shimeji',
    location: AppRoutes.shimeji,
    icon: Icons.auto_awesome_motion_rounded,
  ),
  NavigationItem(
    label: 'Profile',
    location: AppRoutes.profile,
    icon: Icons.person_rounded,
  ),
];
