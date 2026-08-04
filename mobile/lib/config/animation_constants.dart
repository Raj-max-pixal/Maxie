import 'package:flutter/animation.dart';

class AnimationConstants {
  const AnimationConstants._();

  static const Duration micro = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve emphasizedCurve = Curves.easeInOutCubicEmphasized;
}
