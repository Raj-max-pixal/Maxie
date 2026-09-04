import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/maxie_state_provider.dart';

class ProfilePanel extends ConsumerWidget {
  const ProfilePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maxieStateProvider);
    final xpNeeded = state.friendshipLevel * 100;
    final xpFactor = (state.friendshipXP / xpNeeded).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Friendship Profile',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade900,
            ),
          ),
          const SizedBox(height: 20),

          // Friendship Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade800, Colors.deepPurple.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.shade800.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.pinkAccent,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MAXie Level',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Level ${state.friendshipLevel}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // XP Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Friendship XP',
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '${state.friendshipXP} / $xpNeeded XP',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: xpFactor,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Stats Section
          Text(
            'Adventure Stats',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade900,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.6,
            children: [
              _buildStatTile('Pocket Points', '${state.points} Pts', Icons.stars_rounded, Colors.amber),
              _buildStatTile('Emotion State', state.currentEmotion.toUpperCase(), Icons.face_retouching_natural_rounded, Colors.green),
              _buildStatTile('Accessory Count', '${state.equippedAccessories.length} Owned', Icons.backpack_rounded, Colors.purple),
              _buildStatTile('Current Status', state.currentActivity.toUpperCase(), Icons.directions_run_rounded, Colors.blue),
            ],
          ),
          const SizedBox(height: 28),

          // Achievements/Badges
          Text(
            'Friendship Badges',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade900,
            ),
          ),
          const SizedBox(height: 12),
          _buildBadgesRow(state),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesRow(MaxieState state) {
    final badges = [
      {
        'title': 'Pioneer',
        'desc': 'Early companion user',
        'emoji': '🚀',
        'unlocked': true,
      },
      {
        'title': 'Fashion Star',
        'desc': 'Equipped accessories',
        'emoji': '✨',
        'unlocked': state.equippedAccessories.isNotEmpty,
      },
      {
        'title': 'Golden Friend',
        'desc': 'Level 3 friendship',
        'emoji': '🏆',
        'unlocked': state.friendshipLevel >= 3,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: badges.map((badge) {
        final isUnlocked = badge['unlocked'] as bool;
        return Opacity(
          opacity: isUnlocked ? 1.0 : 0.4,
          child: Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.amber.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isUnlocked ? Colors.amber.shade200 : Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Text(
                  badge['emoji'] as String,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  badge['title'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.amber.shade900 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  badge['desc'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 8.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
