import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class Level {
  final int id;
  final String emojis;
  final String answer;
  final bool isCompleted;

  Level({
    this.id = 0,
    this.emojis = '',
    this.answer = '',
    this.isCompleted = false,
  });

  Level copyWith({
    int? id,
    String? emojis,
    String? answer,
    bool? isCompleted,
  }) {
    return Level(
      id: id ?? this.id,
      emojis: emojis ?? this.emojis,
      answer: answer ?? this.answer,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] ?? 0,
      emojis: json['emojis'] ?? '',
      answer: json['answer'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emojis': emojis,
      'answer': answer,
      'isCompleted': isCompleted,
    };
  }
}

class GameProvider extends ChangeNotifier {
  List<Level> _levels = [];
  int _currentLevelIndex = 0;
  int _score = 0;
  bool _isGameWon = false;

  List<Level> get levels => _levels;
  int get currentLevelIndex => _currentLevelIndex;
  int get score => _score;
  bool get isGameWon => _isGameWon;

  Level get currentLevel => _levels.isNotEmpty ? _levels[_currentLevelIndex] : Level();

  void checkAnswer(String input) {
    if (_levels.isEmpty) return;

    if (input.toLowerCase().trim() == currentLevel.answer.toLowerCase().trim()) {
      _levels[_currentLevelIndex] = currentLevel.copyWith(isCompleted: true);
      _score += 10;
      notifyListeners();
    }
  }

  void nextLevel() {
    if (_currentLevelIndex < _levels.length - 1) {
      _currentLevelIndex++;
    } else {
      _isGameWon = true;
    }
    notifyListeners();
  }

  void loadProgress() {
    // Logic to load from local storage would go here
    notifyListeners();
  }

  void saveProgress() {
    // Logic to save to local storage would go here
    notifyListeners();
  }

  void resetGame() {
    _currentLevelIndex = 0;
    _score = 0;
    _isGameWon = false;
    _levels = _levels.map((level) => level.copyWith(isCompleted: false)).toList();
    notifyListeners();
  }

  void setLevels(List<Level> levels) {
    _levels = levels;
    notifyListeners();
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  void _startApp() async {
    // Load progress from the provider
    context.read<GameProvider>().loadProgress();
    
    // Delay for splash screen effect
    await Future.delayed(Duration(seconds: 3));
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueAccent,
              Colors.purpleAccent,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                '🧩',
                style: TextStyle(fontSize: 80),
              ),
            ),
            SizedBox(height: 24),
            Text(
              '2 Emojis 1 Word',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Can you guess the word?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 60),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Level',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final levels = gameProvider.levels;

          if (levels.isEmpty) {
            return Center(
              child: Text(
                'No levels available',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                final bool isCompleted = level.isCompleted;

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/game');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? Colors.green 
                          : Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '${level.id}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isCompleted)
                          Positioned(
                            right: 5,
                            top: 5,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                gameProvider.resetGame();
              },
              child: Text(
                'Reset Progress',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        if (provider.isGameWon) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Game Complete!'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Congratulations!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Final Score: ${provider.score}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      provider.resetGame();
                    },
                    child: const Text('Play Again'),
                  ),
                ],
              ),
            ),
          );
        }

        final currentLevel = provider.currentLevel;
        final isCompleted = currentLevel.isCompleted;

        return Scaffold(
          appBar: AppBar(
            title: Text('Level ${provider.currentLevelIndex + 1} / ${provider.levels.length}'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    'Score: ${provider.score}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentLevel.emojis,
                  style: const TextStyle(
                    fontSize: 80,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (!isCompleted) ...[
                  TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Enter your answer',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      provider.checkAnswer(value);
                      if (provider.currentLevel.isCompleted) {
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.checkAnswer(_controller.text);
                        setState(() {});
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Correct!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _controller.clear();
                        provider.nextLevel();
                      },
                      child: const Text('Next Level'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class WinScreen extends StatelessWidget {
  const WinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🏆',
              style: TextStyle(
                fontSize: 100,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'You Won!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Amazing job! You have successfully completed all the emoji puzzles.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'FINAL SCORE',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${gameProvider.score}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  context.read<GameProvider>().resetGame();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'PLAY AGAIN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emojis 1 Word',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings?.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => SplashScreen());
          case '/level_selection':
            return MaterialPageRoute(builder: (context) => const LevelSelectionScreen());
          case '/game':
            return MaterialPageRoute(builder: (context) => const GameScreen());
          case '/win':
            return MaterialPageRoute(builder: (context) => const WinScreen());
          default:
            return MaterialPageRoute(builder: (context) => SplashScreen());
        }
      },
    );
  }
}
