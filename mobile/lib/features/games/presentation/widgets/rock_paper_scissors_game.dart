import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

class RockPaperScissorsGame extends ConsumerStatefulWidget {
  const RockPaperScissorsGame({super.key});

  @override
  ConsumerState<RockPaperScissorsGame> createState() => _RockPaperScissorsGameState();
}

class _RockPaperScissorsGameState extends ConsumerState<RockPaperScissorsGame> {
  late ConfettiController _confettiController;
  String? _playerChoice;
  String? _maxieChoice;
  String? _result;
  int _playerScore = 0;
  int _maxieScore = 0;

  final List<String> _choices = ['rock', 'paper', 'scissors'];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _play(String choice) {
    setState(() {
      _playerChoice = choice;
      _maxieChoice = _choices[(DateTime.now().millisecond) % 3];
      _result = _determineWinner(choice, _maxieChoice!);
      
      if (_result == 'You win!') {
        _playerScore++;
        _confettiController.play();
      } else if (_result == 'MAXie wins!') {
        _maxieScore++;
      }
    });
  }

  String _determineWinner(String player, String maxie) {
    if (player == maxie) return 'It\'s a tie!';
    
    if ((player == 'rock' && maxie == 'scissors') ||
        (player == 'paper' && maxie == 'rock') ||
        (player == 'scissors' && maxie == 'paper')) {
      return 'You win!';
    }
    
    return 'MAXie wins!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rock Paper Scissors'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Score
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildScoreCard('You', _playerScore),
                    _buildScoreCard('MAXie', _maxieScore),
                  ],
                ),
              ),
              
              // Result
              if (_result != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _result!,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              
              // Choices display
              if (_playerChoice != null && _maxieChoice != null)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildChoiceDisplay(_playerChoice!),
                      const Text('VS'),
                      _buildChoiceDisplay(_maxieChoice!),
                    ],
                  ),
                ),
              
              const Spacer(),
              
              // Player choices
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _choices.map((choice) {
                    return _buildChoiceButton(choice);
                  }).toList(),
                ),
              ),
            ],
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, int score) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceDisplay(String choice) {
    return Column(
      children: [
        _getChoiceIcon(choice),
        const SizedBox(height: 8),
        Text(
          choice.toUpperCase(),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildChoiceButton(String choice) {
    return GestureDetector(
      onTap: () => _play(choice),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: _getChoiceIcon(choice),
      ),
    );
  }

  Widget _getChoiceIcon(String choice) {
    switch (choice) {
      case 'rock':
        return const Icon(Icons.radio_button_checked, size: 48);
      case 'paper':
        return const Icon(Icons.description, size: 48);
      case 'scissors':
        return const Icon(Icons.content_cut, size: 48);
      default:
        return const Icon(Icons.help, size: 48);
    }
  }
}
