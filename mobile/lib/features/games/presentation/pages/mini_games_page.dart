import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'widgets/rock_paper_scissors_game.dart';
import 'widgets/memory_game.dart';
import 'widgets/catch_maxie_game.dart';

class MiniGamesPage extends ConsumerStatefulWidget {
  const MiniGamesPage({super.key});

  @override
  ConsumerState<MiniGamesPage> createState() => _MiniGamesPageState();
}

class _MiniGamesPageState extends ConsumerState<MiniGamesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mini Games',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGameCard(
            icon: Icons.rock,
            title: 'Rock Paper Scissors',
            description: 'Classic game against MAXie!',
            onTap: () => _showGame('rock_paper_scissors'),
          ),
          const SizedBox(height: 16),
          _buildGameCard(
            icon: Icons.memory,
            title: 'Memory Game',
            description: 'Test your memory!',
            onTap: () => _showGame('memory'),
          ),
          const SizedBox(height: 16),
          _buildGameCard(
            icon: Icons.touch_app,
            title: 'Catch MAXie',
            description: 'Can you catch me?',
            onTap: () => _showGame('catch_maxie'),
          ),
          const SizedBox(height: 16),
          _buildGameCard(
            icon: Icons.quiz,
            title: 'Quiz',
            description: 'Answer fun questions!',
            onTap: () => _showGame('quiz'),
          ),
          const SizedBox(height: 16),
          _buildGameCard(
            icon: Icons.casino,
            title: 'Spin Wheel',
            description: 'Try your luck!',
            onTap: () => _showGame('spin_wheel'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGame(String gameType) {
    switch (gameType) {
      case 'rock_paper_scissors':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RockPaperScissorsGame()),
        );
        break;
      case 'memory':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MemoryGame()),
        );
        break;
      case 'catch_maxie':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CatchMaxieGame()),
        );
        break;
      // Add other games
    }
  }
}
