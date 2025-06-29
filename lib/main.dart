import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const SnakeGame());

class SnakeGame extends StatelessWidget {
  const SnakeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SnakeHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SnakeHomePage extends StatefulWidget {
  const SnakeHomePage({super.key});

  @override
  State<SnakeHomePage> createState() => _SnakeHomePageState();
}

enum Direction { up, down, left, right }

class _SnakeHomePageState extends State<SnakeHomePage> {
  final int totalSquares = 400; // 20x20 grid
  final int rowSize = 20;
  List<int> snakePosition = [45, 65, 85];
  int foodPosition = 105;
  Direction direction = Direction.down;
  Timer? gameLoop;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    gameLoop = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        moveSnake();
        checkGameOver();
      });
    });
  }

  void moveSnake() {
    int newHead;

    switch (direction) {
      case Direction.up:
        newHead = snakePosition.last - rowSize;
        break;
      case Direction.down:
        newHead = snakePosition.last + rowSize;
        break;
      case Direction.left:
        newHead = snakePosition.last - 1;
        break;
      case Direction.right:
        newHead = snakePosition.last + 1;
        break;
    }

    snakePosition.add(newHead);

    if (newHead == foodPosition) {
      generateNewFood();
    } else {
      snakePosition.removeAt(0); // remove tail
    }
  }

  void generateNewFood() {
    foodPosition = Random().nextInt(totalSquares);
    while (snakePosition.contains(foodPosition)) {
      foodPosition = Random().nextInt(totalSquares);
    }
  }

  void checkGameOver() {
    int head = snakePosition.last;

    // Check wall collision
    if (head < 0 || head >= totalSquares) {
      gameOver();
    }

    // Check left/right overflow
    if (direction == Direction.left &&
        (head + 1) % rowSize == 0) {
      gameOver();
    } else if (direction == Direction.right &&
        head % rowSize == 0) {
      gameOver();
    }

    // Check self collision
    if (snakePosition.sublist(0, snakePosition.length - 1).contains(head)) {
      gameOver();
    }
  }

  void gameOver() {
    gameLoop?.cancel();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Your score: ${snakePosition.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              restartGame();
            },
            child: const Text("Restart"),
          ),
        ],
      ),
    );
  }

  void restartGame() {
    setState(() {
      snakePosition = [45, 65, 85];
      foodPosition = 105;
      direction = Direction.down;
      startGame();
    });
  }

  void changeDirection(Direction newDirection) {
    // Prevent snake from reversing
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    direction = newDirection;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: totalSquares,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowSize,
              ),
              itemBuilder: (context, index) {
                if (snakePosition.contains(index)) {
                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                } else if (index == foodPosition) {
                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  );
                } else {
                  return Container(
                    margin: const EdgeInsets.all(1),
                    color: Colors.grey[900],
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_up, color: Colors.white),
                      iconSize: 40,
                      onPressed: () => changeDirection(Direction.up),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_left, color: Colors.white),
                          iconSize: 40,
                          onPressed: () => changeDirection(Direction.left),
                        ),
                        const SizedBox(width: 50),
                        IconButton(
                          icon: const Icon(Icons.arrow_right, color: Colors.white),
                          iconSize: 40,
                          onPressed: () => changeDirection(Direction.right),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      iconSize: 40,
                      onPressed: () => changeDirection(Direction.down),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
