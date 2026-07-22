import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class MemoryGame extends ConsumerStatefulWidget {
  const MemoryGame({super.key});

  @override
  ConsumerState<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends ConsumerState<MemoryGame> {
  final List<String> _emojis = ['🐾', '❤️', '⭐', '🎮', '🎵', '📚', '💪', '🔥'];
  late List<String> _cards;
  List<bool> _flipped = [];
  List<bool> _matched = [];
  int? _firstIndex;
  int? _secondIndex;
  bool _isChecking = false;
  int _moves = 0;
  int _matches = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _cards = [..._emojis, ..._emojis];
    _cards.shuffle();
    _flipped = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
    _moves = 0;
    _matches = 0;
    _firstIndex = null;
    _secondIndex = null;
    _isChecking = false;
  }

  void _flipCard(int index) {
    if (_isChecking || _flipped[index] || _matched[index]) return;

    setState(() {
      _flipped[index] = true;

      if (_firstIndex == null) {
        _firstIndex = index;
      } else {
        _secondIndex = index;
        _moves++;
        _checkMatch();
      }
    });
  }

  void _checkMatch() {
    _isChecking = true;

    if (_cards[_firstIndex!] == _cards[_secondIndex!]) {
      setState(() {
        _matched[_firstIndex!] = true;
        _matched[_secondIndex!] = true;
        _matches++;
        _firstIndex = null;
        _secondIndex = null;
        _isChecking = false;
      });

      if (_matches == _emojis.length) {
        _showWinDialog();
      }
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _flipped[_firstIndex!] = false;
          _flipped[_secondIndex!] = false;
          _firstIndex = null;
          _secondIndex = null;
          _isChecking = false;
        });
      });
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('You Won!'),
        content: Text('Completed in $_moves moves!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _initializeGame());
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _initializeGame()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Moves: $_moves',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _flipCard(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _flipped[index] || _matched[index]
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _flipped[index] || _matched[index]
                          ? Text(
                              _cards[index],
                              style: const TextStyle(fontSize: 32),
                            )
                          : const Icon(
                              Icons.help_outline,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
