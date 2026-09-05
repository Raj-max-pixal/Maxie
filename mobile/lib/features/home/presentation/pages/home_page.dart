import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/games/presentation/pages/mini_games_page.dart';
import 'package:maxie_mobile/features/settings/presentation/providers/settings_provider.dart';
import 'package:maxie_mobile/features/home/presentation/widgets/maxie_character.dart';
import 'package:maxie_mobile/features/home/presentation/widgets/maxie_overlay.dart';
import 'package:maxie_mobile/features/home/presentation/widgets/maxie_dialogue.dart';
import 'package:maxie_mobile/features/home/presentation/widgets/floating_quick_actions.dart';
import 'package:maxie_mobile/features/home/presentation/widgets/floating_status_bar.dart';
import 'package:maxie_mobile/features/home/presentation/widgets/floating_music_player.dart';
import 'package:maxie_mobile/features/home/presentation/widgets/floating_pomodoro_timer.dart';
import 'package:maxie_mobile/features/home/presentation/widgets/draggable_app_icon.dart';
import 'package:maxie_mobile/features/home/presentation/widgets/toy_item.dart';
import 'package:maxie_mobile/features/home/presentation/widgets/care_panel.dart';
import 'package:maxie_mobile/features/home/presentation/widgets/profile_panel.dart';
import 'package:maxie_mobile/features/home/presentation/providers/maxie_state_provider.dart';
import 'package:maxie_mobile/features/home/presentation/providers/overlay_provider.dart';
import 'package:maxie_mobile/features/home/presentation/providers/apps_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final maxieState = ref.watch(maxieStateProvider);
    final overlayState = ref.watch(overlayProvider);
    final settings = ref.watch(settingsProvider);
    final appsState = ref.watch(appsProvider);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Update bounds dynamically so wandering and dragging stay on screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(maxieStateProvider.notifier).updateScreenBounds(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
          });

          return Stack(
            children: [
              // Beautiful Animated Gradient Background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
                    ],
                  ),
                ),
              ),

              // Tab views
              SafeArea(
                bottom: false,
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    // Tab 0: Home desktop screen
                    Stack(
                      children: [
                        // Draggable Apps all over the mobile screen
                        if (appsState.hasLoaded)
                          ...appsState.apps.map((app) {
                            return DraggableAppIcon(
                              app: app,
                              onTap: () {
                                if (app.id == 'games') {
                                  setState(() => _currentIndex = 1);
                                } else if (app.id == 'care') {
                                  setState(() => _currentIndex = 2);
                                } else if (app.id == 'music') {
                                  ref.read(overlayProvider.notifier).toggleWidgetVisibility('music_player');
                                } else if (app.id == 'pomodoro') {
                                  ref.read(overlayProvider.notifier).toggleWidgetVisibility('pomodoro_timer');
                                } else {
                                  Navigator.pushNamed(context, app.route);
                                }
                              },
                            );
                          }),

                        // Spawned Toy/Food item
                        if (maxieState.spawnedToyPosition != null && maxieState.spawnedToyType != null)
                          ToyItem(
                            position: maxieState.spawnedToyPosition!,
                            type: maxieState.spawnedToyType!,
                          ),

                        // Draggable & Wandering Pet
                        Positioned(
                          left: maxieState.petPosition.dx,
                          top: maxieState.petPosition.dy,
                          child: const MaxieCharacter(),
                        ),

                        // Speech Bubble floats above the pet dynamically
                        if (maxieState.currentMessage.isNotEmpty && !maxieState.isSleeping)
                          _buildSpeechBubble(maxieState, constraints.maxWidth, constraints.maxHeight, settings.maxieSize),

                        // Friendship Indicator overlay (Floating)
                        Positioned(
                          top: 20,
                          left: 20,
                          child: _buildFriendshipIndicator(maxieState.friendshipLevel),
                        ),

                        // Quick action launcher overlay (Floating)
                        Positioned(
                          top: 20,
                          right: 20,
                          child: _buildQuickActions(),
                        ),
                      ],
                    ),

                    // Tab 1: Games Screen
                    const MiniGamesPage(),

                    // Tab 2: Care & Shop Screen
                    CarePanel(
                      onSpawnCookie: () => _triggerToySpawn('cookie', constraints),
                      onSpawnApple: () => _triggerToySpawn('apple', constraints),
                      onSpawnBall: () => _triggerToySpawn('ball', constraints),
                      onSpawnYarn: () => _triggerToySpawn('yarn', constraints),
                    ),

                    // Tab 3: Profile Screen
                    const ProfilePanel(),
                  ],
                ),
              ),

              // System Overlays (when active)
              if (overlayState.isEnabled) ...[
                const FloatingStatusBar(),
                const FloatingQuickActions(),
                const FloatingMusicPlayer(),
                const FloatingPomodoroTimer(),
              ],

              // Premium Glassmorphic Bottom Navigation
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomNav(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _triggerToySpawn(String type, BoxConstraints constraints) {
    // Spawn toy in the middle area of the Home screen
    final spawnPos = Offset(constraints.maxWidth / 2, constraints.maxHeight * 0.45);
    ref.read(maxieStateProvider.notifier).spawnToy(type, spawnPos);
    
    // Switch to Home screen
    setState(() {
      _currentIndex = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dropped a $type! Watch MAXie go! 🐾✨'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.indigo,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSpeechBubble(MaxieState state, double screenWidth, double screenHeight, double sizeFactor) {
    final double petSize = 100.0 * sizeFactor;
    final double dialogueWidth = 240;

    // Centered above the pet
    final double petCenter = state.petPosition.dx + petSize / 2;
    final double dialogueLeft = (petCenter - dialogueWidth / 2).clamp(10.0, screenWidth - dialogueWidth - 10);
    
    // Height adjustments
    final double dialogueTop = (state.petPosition.dy - 75).clamp(20.0, screenHeight - 140);

    return Positioned(
      left: dialogueLeft,
      top: dialogueTop,
      child: SizedBox(
        width: dialogueWidth,
        child: MaxieDialogue(
          message: state.currentMessage,
          emotion: state.currentEmotion,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          onTap: () => Navigator.pushNamed(context, '/chat'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.settings_outlined,
          onTap: () => Navigator.pushNamed(context, '/settings'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.layers_outlined,
          onTap: () {
            ref.read(overlayProvider.notifier).toggleOverlay();
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.indigo.shade950),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildFriendshipIndicator(int level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite_rounded, color: Colors.pink, size: 20),
          const SizedBox(width: 8),
          Text(
            'Lvl $level',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade950,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 'Home', 0),
                _buildNavItem(Icons.sports_esports_rounded, 'Games', 1),
                _buildNavItem(Icons.favorite_rounded, 'Care', 2),
                _buildNavItem(Icons.person_rounded, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? primaryColor : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? primaryColor : Colors.grey.shade600,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
