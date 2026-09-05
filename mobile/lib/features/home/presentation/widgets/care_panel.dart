import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maxie_mobile/features/home/presentation/providers/maxie_state_provider.dart';

class CarePanel extends ConsumerWidget {
  final VoidCallback onSpawnCookie;
  final VoidCallback onSpawnApple;
  final VoidCallback onSpawnBall;
  final VoidCallback onSpawnYarn;

  const CarePanel({
    super.key,
    required this.onSpawnCookie,
    required this.onSpawnApple,
    required this.onSpawnBall,
    required this.onSpawnYarn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxieState = ref.watch(maxieStateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Care & Interaction',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade950,
            ),
          ),
          const SizedBox(height: 16),

          // Pet Stats Card
          _buildStatsCard(context, maxieState),
          const SizedBox(height: 24),

          // Quick Care Actions (Spawning items)
          Text(
            'Interact with Toys & Food',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInteractionButton(
                emoji: '🍪',
                label: 'Cookie',
                color: Colors.amber,
                onTap: onSpawnCookie,
              ),
              _buildInteractionButton(
                emoji: '🍎',
                label: 'Apple',
                color: Colors.redAccent,
                onTap: onSpawnApple,
              ),
              _buildInteractionButton(
                emoji: '⚽',
                label: 'Ball',
                color: Colors.blueAccent,
                onTap: onSpawnBall,
              ),
              _buildInteractionButton(
                emoji: '🧶',
                label: 'Yarn',
                color: Colors.pinkAccent,
                onTap: onSpawnYarn,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Accessory Shop
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Accessory Shop',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${maxieState.points} Pts',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade950,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildShopGrid(ref, maxieState),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, MaxieState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.indigo.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade950.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow('Hunger', state.hunger, Colors.orangeAccent),
          const SizedBox(height: 14),
          _buildStatRow('Energy', state.energy, Colors.tealAccent.shade700),
          const SizedBox(height: 14),
          _buildStatRow('Mood', state.mood, Colors.pinkAccent),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double val, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 65,
          child: Text(
            label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: val,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(val * 100).toInt()}%',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInteractionButton({
    required String emoji,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopGrid(WidgetRef ref, MaxieState state) {
    final shopItems = [
      {'id': 'crown', 'name': 'Crown', 'emoji': '👑', 'cost': 150},
      {'id': 'detective_hat', 'name': 'Detective Hat', 'emoji': '🕵️‍♂️', 'cost': 80},
      {'id': 'wizard_hat', 'name': 'Wizard Hat', 'emoji': '🧙', 'cost': 100},
      {'id': 'sunglasses', 'name': 'Sunglasses', 'emoji': '😎', 'cost': 50},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.15,
      ),
      itemCount: shopItems.length,
      itemBuilder: (context, index) {
        final item = shopItems[index];
        final id = item['id'] as String;
        final name = item['name'] as String;
        final emoji = item['emoji'] as String;
        final cost = item['cost'] as int;

        final isOwned = state.equippedAccessories.contains(id);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade150),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              Text(
                name,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isOwned) {
                        ref.read(maxieStateProvider.notifier).toggleAccessory(id);
                      } else {
                        final success = ref.read(maxieStateProvider.notifier).buyAccessory(id, cost);
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Not enough points! Play games to earn more! 🎮'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOwned ? Colors.indigo : Colors.amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    child: Text(
                      isOwned ? 'Equipped' : '$cost Pts',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
