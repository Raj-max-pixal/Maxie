import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:maxie_mobile/features/home/presentation/providers/maxie_state_provider.dart';
import 'package:maxie_mobile/features/home/presentation/providers/overlay_provider.dart';

class FloatingStatusBar extends ConsumerStatefulWidget {
  const FloatingStatusBar({super.key});

  @override
  ConsumerState<FloatingStatusBar> createState() => _FloatingStatusBarState();
}

class _FloatingStatusBarState extends ConsumerState<FloatingStatusBar> {
  final Battery _battery = Battery();
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;

  @override
  void initState() {
    super.initState();
    _initBattery();
  }

  Future<void> _initBattery() async {
    _batteryLevel = await _battery.batteryLevel;
    _battery.onBatteryStateChanged.listen((state) {
      setState(() => _batteryState = state);
    });
  }

  @override
  Widget build(BuildContext context) {
    final overlayState = ref.watch(overlayProvider);
    final maxieState = ref.watch(maxieStateProvider);
    final widget = overlayState.getWidget('status_bar');
    
    if (widget == null || !widget.isVisible) return const SizedBox.shrink();

    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          ref.read(overlayProvider.notifier).updateWidgetPosition(
            'status_bar',
            Offset(widget.position.dx + details.delta.dx, widget.position.dy + details.delta.dy),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(overlayState.transparency * 0.9),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildBatteryIcon(),
                    const SizedBox(width: 8),
                    Text(
                      '$_batteryLevel%',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.pets, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Lvl ${maxieState.friendshipLevel}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.wb_sunny, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      _getWeatherText(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryIcon() {
    IconData icon;
    Color color;

    if (_batteryState == BatteryState.charging) {
      icon = Icons.battery_charging_full;
      color = Colors.green;
    } else if (_batteryLevel > 50) {
      icon = Icons.battery_full;
      color = Colors.green;
    } else if (_batteryLevel > 20) {
      icon = Icons.battery_3_bar;
      color = Colors.orange;
    } else {
      icon = Icons.battery_alert;
      color = Colors.red;
    }

    return Icon(icon, size: 16, color: color);
  }

  String _getWeatherText() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 21) return 'Evening';
    return 'Night';
  }
}
