import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CatchMaxieGame extends ConsumerStatefulWidget {
  const CatchMaxieGame({super.key});

  @override
  ConsumerState<CatchMaxieGame> createState() => _CatchMaxieGameState();
}

class _CatchMaxieGameState extends ConsumerState<CatchMaxieGame> {
  Offset _maxiePosition = const Offset(100, 100);
  int _score = 0;
  int _timeLeft = 30;
  bool _gameStarted = false;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _score = 0;
      _timeLeft = 30;
    });
    _moveMaxie();
    _startTimer();
  }

  void _moveMaxie() {
    if (!_gameStarted || _gameOver) return;

    final random = Random();
    final screenWidth = MediaQuery.of(context).size.width - 100;
    final screenHeight = MediaQuery.of(context).size.height - 300;

    setState(() {
      _maxiePosition = Offset(
        random.nextDouble() * screenWidth,
        random.nextDouble() * screenHeight + 100,
      );
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (_gameStarted && !_gameOver) {
        _moveMaxie();
      }
    });
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_gameStarted && !_gameOver && _timeLeft > 0) {
        setState(() => _timeLeft--);
        return true;
      }
      if (_timeLeft == 0) {
        _endGame();
      }
      return false;
    });
  }

  void _catchMaxie() {
    if (!_gameStarted || _gameOver) return;

    setState(() => _score++);
    _moveMaxie();
  }

  void _endGame() {
    setState(() {
      _gameStarted = false;
      _gameOver = true;
    });
    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Text('You caught MAXie $_score times!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catch MAXie'),
      ),
      body: Stack(
        children: [
          // Game area
          if (!_gameStarted && !_gameOver)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.touch_app, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    'Catch MAXie!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap MAXie before he moves!',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _startGame,
                    child: const Text('Start Game'),
                  ),
                ],
              ),
            ),
          
          // Game UI
          if (_gameStarted)
            Stack(
              children: [
                // Score and timer
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Score: $_score',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Time: $_timeLeft',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                
                // MAXie
                Positioned(
                  left: _maxiePosition.dx,
                  top: _maxiePosition.dy,
                  child: GestureDetector(
                    onTap: _catchMaxie,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pets, size: 48, color: Colors.purple),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
