import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

final loadingProvider = StateProvider<bool>((ref) => false);

final offlineProvider = StateProvider<bool>((ref) => false);
