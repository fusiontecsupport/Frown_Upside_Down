import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';

class CandyCrushGame extends StatefulWidget {
  const CandyCrushGame({Key? key}) : super(key: key);

  @override
  State<CandyCrushGame> createState() => _CandyCrushGameState();
}

class _CandyCrushGameState extends State<CandyCrushGame>
    with TickerProviderStateMixin {
  
  // App theme colors
  final Color kPrimary = const Color(0xFF4A6FA5);
  final Color kSecondary = const Color(0xFF5B7DB1);
  final Color kAccent = const Color(0xFF6B8FC3);
  
  // Game state
  bool _gameActive = false;
  bool _gameStarted = false;
  int _score = 0;
  int _timeLeft = 60;
  int _level = 1;
  int _target = 1000;
  
  // Grid system
  List<List<Candy>> _grid = [];
  final int _gridSize = 8;
  
  // Swipe state
  bool _isProcessing = false;
  Offset? _swipeStart;
  Offset _swipeDelta = Offset.zero;
  bool _hasSwappedThisGesture = false;
  int? _swipingRow;
  int? _swipingCol;
  
  // Animations
  late AnimationController _crushController;
  late AnimationController _fallController;
  late AnimationController _scoreController;
  
  // Emoji types for matching
  final List<String> _emojiTypes = [
    '😊', // Happy - Yellow
    '😢', // Sad - Blue  
    '😍', // Love - Pink
    '😎', // Cool - Purple
    '🤔', // Thinking - Orange
    '😴', // Sleepy - Green
  ];
  
  final List<Color> _emojiColors = [
    Colors.yellow,
    Colors.blue,
    Colors.pink,
    Colors.purple,
    Colors.orange,
    Colors.green,
  ];
  
  @override
  void initState() {
    super.initState();
    
    _crushController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fallController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _crushController.dispose();
    _fallController.dispose();
    _scoreController.dispose();
    super.dispose();
  }
  
  void _startGame() {
    setState(() {
      _gameActive = true;
      _gameStarted = true;
      _score = 0;
      _timeLeft = 60;
      _level = 1;
      _target = 1000;
      _isProcessing = false;
      _swipeStart = null;
      _swipeDelta = Offset.zero;
      _hasSwappedThisGesture = false;
      _swipingRow = null;
      _swipingCol = null;
    });
    
    _initializeGrid();
    _removeInitialMatches();
    
    // Start countdown timer
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_gameActive) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _gameActive = false;
          timer.cancel();
          _checkGameEnd();
        }
      });
    });
  }
  
  void _initializeGrid() {
    final random = Random();
    _grid = List.generate(_gridSize, (row) =>
      List.generate(_gridSize, (col) {
        return Candy(
          type: _emojiTypes[random.nextInt(_emojiTypes.length)],
          color: _emojiColors[random.nextInt(_emojiColors.length)],
          row: row,
          col: col,
        );
      })
    );
  }
  
  void _removeInitialMatches() {
    // Ensure no initial matches exist
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize; col++) {
        while (_hasMatchAt(row, col)) {
          final random = Random();
          _grid[row][col] = Candy(
            type: _emojiTypes[random.nextInt(_emojiTypes.length)],
            color: _emojiColors[random.nextInt(_emojiColors.length)],
            row: row,
            col: col,
          );
        }
      }
    }
  }
  
  bool _hasMatchAt(int row, int col) {
    final candy = _grid[row][col];
    
    // Check horizontal match
    int horizontalCount = 1;
    // Check left
    for (int i = col - 1; i >= 0 && _grid[row][i].type == candy.type; i--) {
      horizontalCount++;
    }
    // Check right
    for (int i = col + 1; i < _gridSize && _grid[row][i].type == candy.type; i++) {
      horizontalCount++;
    }
    
    // Check vertical match
    int verticalCount = 1;
    // Check up
    for (int i = row - 1; i >= 0 && _grid[i][col].type == candy.type; i--) {
      verticalCount++;
    }
    // Check down
    for (int i = row + 1; i < _gridSize && _grid[i][col].type == candy.type; i++) {
      verticalCount++;
    }
    
    return horizontalCount >= 3 || verticalCount >= 3;
  }
  
  void _onPanStart(DragStartDetails details, int row, int col) {
    if (!_gameActive || _isProcessing) return;

    setState(() {
      _swipeStart = details.localPosition;
      _swipeDelta = Offset.zero;
      _hasSwappedThisGesture = false;
      _swipingRow = row;
      _swipingCol = col;
    });
    HapticFeedback.selectionClick();
  }

  void _onPanUpdate(DragUpdateDetails details, int row, int col) {
    if (!_gameActive || _isProcessing || _swipeStart == null || _hasSwappedThisGesture) {
      return;
    }

    _swipeDelta += details.delta;
    final dx = _swipeDelta.dx;
    final dy = _swipeDelta.dy;

    // Only process if swipe is significant enough (minimum 30 pixels)
    if (dx.abs() > 28 || dy.abs() > 28) {
      int targetRow = row;
      int targetCol = col;

      // Determine swipe direction based on larger movement
      if (dx.abs() > dy.abs()) {
        // Horizontal swipe
        if (dx > 0) {
          targetCol++; // Swipe right
        } else {
          targetCol--; // Swipe left
        }
      } else {
        // Vertical swipe
        if (dy > 0) {
          targetRow++; // Swipe down
        } else {
          targetRow--; // Swipe up
        }
      }
      
      // Check if target position is valid
      if (targetRow >= 0 && targetRow < _gridSize && 
          targetCol >= 0 && targetCol < _gridSize) {

        final startCandy = _grid[row][col];
        final targetCandy = _grid[targetRow][targetCol];

        _performSwap(startCandy, targetCandy);
        setState(() {
          _hasSwappedThisGesture = true;
          _swipingRow = targetRow;
          _swipingCol = targetCol;
        });
      }

      // Reset swipe state to prevent multiple swaps
      _swipeStart = null;
    }
  }

  void _onPanEnd(DragEndDetails details, int row, int col) {
    // Reset swipe state
    setState(() {
      _swipeStart = null;
      _swipeDelta = Offset.zero;
      _hasSwappedThisGesture = false;
      _swipingRow = null;
      _swipingCol = null;
    });
  }
  
  bool _areAdjacent(Candy candy1, Candy candy2) {
    final rowDiff = (candy1.row - candy2.row).abs();
    final colDiff = (candy1.col - candy2.col).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }
  
  void _performSwap(Candy candy1, Candy candy2) {
    setState(() {
      _isProcessing = true;
    });
    
    // Swap positions
    final tempRow = candy1.row;
    final tempCol = candy1.col;
    
    candy1.row = candy2.row;
    candy1.col = candy2.col;
    candy2.row = tempRow;
    candy2.col = tempCol;
    
    _grid[candy1.row][candy1.col] = candy1;
    _grid[candy2.row][candy2.col] = candy2;
    
    // Check for matches
    final matches = _findAllMatches();
    
    if (matches.isNotEmpty) {
      // Valid move
      _processMatches(matches);
      HapticFeedback.mediumImpact();
    } else {
      // Invalid move - swap back
      candy1.row = candy2.row;
      candy1.col = candy2.col;
      candy2.row = tempRow;
      candy2.col = tempCol;
      
      _grid[candy1.row][candy1.col] = candy1;
      _grid[candy2.row][candy2.col] = candy2;
      
      setState(() {
        _isProcessing = false;
      });
      
      HapticFeedback.lightImpact();
    }
    
    _checkGameEnd();
  }
  
  List<Candy> _findAllMatches() {
    final matches = <Candy>{};
    
    // Find horizontal matches
    for (int row = 0; row < _gridSize; row++) {
      for (int col = 0; col < _gridSize - 2; col++) {
        final candy = _grid[row][col];
        if (_grid[row][col + 1].type == candy.type &&
            _grid[row][col + 2].type == candy.type) {
          matches.add(candy);
          matches.add(_grid[row][col + 1]);
          matches.add(_grid[row][col + 2]);
          
          // Check for longer matches
          for (int i = col + 3; i < _gridSize && _grid[row][i].type == candy.type; i++) {
            matches.add(_grid[row][i]);
          }
        }
      }
    }
    
    // Find vertical matches
    for (int col = 0; col < _gridSize; col++) {
      for (int row = 0; row < _gridSize - 2; row++) {
        final candy = _grid[row][col];
        if (_grid[row + 1][col].type == candy.type &&
            _grid[row + 2][col].type == candy.type) {
          matches.add(candy);
          matches.add(_grid[row + 1][col]);
          matches.add(_grid[row + 2][col]);
          
          // Check for longer matches
          for (int i = row + 3; i < _gridSize && _grid[i][col].type == candy.type; i++) {
            matches.add(_grid[i][col]);
          }
        }
      }
    }
    
    return matches.toList();
  }
  
  void _processMatches(List<Candy> matches) {
    // Calculate score
    int points = matches.length * 50;
    if (matches.length >= 4) points *= 2; // Bonus for 4+ matches
    if (matches.length >= 5) points *= 2; // Extra bonus for 5+ matches
    
    setState(() {
      _score += points;
    });
    
    _scoreController.forward().then((_) {
      _scoreController.reverse();
    });
    
    // Remove matched candies
    _crushController.forward().then((_) {
      _crushController.reverse();
      
      for (final candy in matches) {
        _grid[candy.row][candy.col] = Candy.empty();
      }
      
      // Apply gravity
      _applyGravity();
      
      // Fill empty spaces
      _fillEmptySpaces();
      
      // Check for new matches
      Timer(const Duration(milliseconds: 300), () {
        final newMatches = _findAllMatches();
        if (newMatches.isNotEmpty) {
          // Chain reaction!
          _processMatches(newMatches);
        } else {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    });
  }
  
  void _applyGravity() {
    _fallController.forward().then((_) {
      _fallController.reverse();
    });
    
    for (int col = 0; col < _gridSize; col++) {
      // Collect non-empty candies
      final candies = <Candy>[];
      for (int row = _gridSize - 1; row >= 0; row--) {
        if (!_grid[row][col].isEmpty) {
          candies.add(_grid[row][col]);
        }
      }
      
      // Clear column
      for (int row = 0; row < _gridSize; row++) {
        _grid[row][col] = Candy.empty();
      }
      
      // Place candies at bottom
      for (int i = 0; i < candies.length; i++) {
        final row = _gridSize - 1 - i;
        _grid[row][col] = candies[i];
        _grid[row][col].row = row;
        _grid[row][col].col = col;
      }
    }
  }
  
  void _fillEmptySpaces() {
    final random = Random();
    
    for (int col = 0; col < _gridSize; col++) {
      for (int row = 0; row < _gridSize; row++) {
        if (_grid[row][col].isEmpty) {
          _grid[row][col] = Candy(
            type: _emojiTypes[random.nextInt(_emojiTypes.length)],
            color: _emojiColors[random.nextInt(_emojiColors.length)],
            row: row,
            col: col,
          );
        }
      }
    }
    
    setState(() {});
  }
  
  void _checkGameEnd() {
    if (_timeLeft <= 0) {
      if (_score >= _target) {
        _showWinDialog();
      } else {
        _showLoseDialog();
      }
    }
  }
  
  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 Level Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $_score', 
              style: TextStyle(fontSize: 18, color: kPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Target: $_target', 
              style: TextStyle(fontSize: 16, color: kSecondary)),
            const SizedBox(height: 16),
            const Text('😊 Amazing! You matched all those emotions!',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextLevel();
            },
            child: const Text('Next Level'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Home'),
          ),
        ],
      ),
    );
  }
  
  void _showLoseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('😔 Game Over'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $_score', 
              style: TextStyle(fontSize: 18, color: kPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Target: $_target', 
              style: TextStyle(fontSize: 16, color: kSecondary)),
            const SizedBox(height: 16),
            const Text('😔 So close! Try matching more emotions next time!',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Home'),
          ),
        ],
      ),
    );
  }
  
  void _nextLevel() {
    setState(() {
      _level++;
      _timeLeft = 60;
      _target = _target + (500 * _level);
    });
    
    _initializeGrid();
    _removeInitialMatches();
    
    // Restart timer for next level
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_gameActive) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _gameActive = false;
          timer.cancel();
          _checkGameEnd();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F1FF),
              Color(0xFFE0EBFF),
              Color(0xFFD6E4FF),
            ],
          ),
        ),
        child: SafeArea(
          child: _gameStarted ? _buildGameScreen() : _buildStartScreen(),
        ),
      ),
    );
  }
  
  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Game title
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('😊', style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 16),
                    const Text(
                      '🎮 Emotion Match',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A6FA5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Match 3 or more emotions!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          // Start button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4A6FA5),
                  Color(0xFF5B7DB1),
                  Color(0xFF6B8FC3),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A6FA5).withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Start Game',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRule(String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF8B4B9C).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGameScreen() {
    return Column(
      children: [
        // Header
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.15),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kPrimary.withOpacity(0.3),
                            kSecondary.withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(Icons.arrow_back, color: kPrimary, size: 24),
                    ),
                  ),
                  Row(
                    children: [
                      _buildStat('Level $_level', kPrimary),
                      const SizedBox(width: 12),
                      AnimatedBuilder(
                        animation: _scoreController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_scoreController.value * 0.2),
                            child: _buildStat('$_score', kSecondary),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildStat('${_timeLeft}s', kAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Target progress
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Target: $_target',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_score / _target).clamp(0.0, 1.0),
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Game grid
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: AnimatedBuilder(
              animation: Listenable.merge([_crushController, _fallController]),
              builder: (context, child) {
                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridSize,
                    childAspectRatio: 1,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _gridSize * _gridSize,
                  itemBuilder: (context, index) {
                    final row = index ~/ _gridSize;
                    final col = index % _gridSize;
                    final candy = _grid[row][col];
                    
                    return GestureDetector(
                      onPanStart: (details) => _onPanStart(details, row, col),
                      onPanUpdate: (details) => _onPanUpdate(details, row, col),
                      onPanEnd: (details) => _onPanEnd(details, row, col),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()
                          ..scale(_crushController.isAnimating ? 
                              1.0 - (_crushController.value * 0.3) : 1.0),
                        decoration: BoxDecoration(
                          color: (_swipingRow == row && _swipingCol == col)
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: (_swipingRow == row && _swipingCol == col)
                              ? Border.all(color: Colors.blue, width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: candy.isEmpty ? null : Center(
                          child: Text(
                            candy.type,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStat(String text, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Candy {
  String type;
  Color color;
  int row;
  int col;
  bool isEmpty;
  
  Candy({
    required this.type,
    required this.color,
    required this.row,
    required this.col,
    this.isEmpty = false,
  });
  
  Candy.empty() : 
    type = '',
    color = Colors.transparent,
    row = -1,
    col = -1,
    isEmpty = true;
}
