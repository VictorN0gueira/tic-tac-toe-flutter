import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/main_color.dart';

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  bool oTurn = true;
  List<String> displayXO = ['', '', '', '', '', '', '', '', ''];
  List<int> matchedIndexes = [];
  int attempts = 0;

  int oScore = 0;
  int xScore = 0;
  int filledBoxes = 0;
  String resultDeclaration = '';
  bool winnerFound = false;

  static const maxSeconds = 30;
  int seconds = maxSeconds;
  Timer? timer;

  static var customFontWhite = GoogleFonts.coiny(
    textStyle: const TextStyle(
      color: Colors.white,
      letterSpacing: 3,
      fontSize: 28,
    ),
  );

  void startTimer() {
    stopTimer(); // Reinicia o timer sempre que um novo jogador joga
    seconds = maxSeconds;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          stopTimer();
          _declareTimeoutLoss();
        }
      });
    });
  }

  void stopTimer() {
    print("Parando o timer...");
    resetTimer();
    timer?.cancel();
  }

  void resetTimer() => seconds = maxSeconds;

  void _declareTimeoutLoss() {
    setState(() {
      resultDeclaration = 'Player ${oTurn ? 'O' : 'X'} ran out of time! Opponent Wins!';
      winnerFound = true;
    });
    _showPlayAgainDialog();
  }

  void _checkWinner() {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (var pattern in winPatterns) {
      int a = pattern[0], b = pattern[1], c = pattern[2];
      if (displayXO[a] != '' && displayXO[a] == displayXO[b] && displayXO[a] == displayXO[c]) {
        setState(() {
          resultDeclaration = 'Player ${displayXO[a]} Wins!';
          matchedIndexes.addAll([a, b, c]);
          stopTimer();
          _updateScore(displayXO[a]);
        });
        return;
      }
    }

    if (!winnerFound && filledBoxes == 9) {
      print("Empate detectado!");
      setState(() {
        resultDeclaration = 'Nobody Wins!';
        stopTimer();
      });
      _showPlayAgainDialog();
    }
  }

  void _updateScore(String winner) {
    if (winner == 'O') {
      oScore++;
    } else if (winner == 'X') {
      xScore++;
    }
    winnerFound = true;
  }

  void _clearBoard() {
    setState(() {
      for (int i = 0; i < 9; i++) {
        displayXO[i] = '';
      }
      resultDeclaration = '';
      matchedIndexes = [];
      winnerFound = false;
    });
    filledBoxes = 0;
    startTimer();
  }

  void _showPlayAgainDialog() {
    print("Exibindo diálogo de nova partida");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Game Over"),
          content: Text(resultDeclaration),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearBoard();
              },
              child: const Text("Play Again"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColor.primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text('Time left: $seconds', style: customFontWhite),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Player O', style: customFontWhite),
                          Text(oScore.toString(), style: customFontWhite),
                        ],
                      ),
                      const SizedBox(width: 50),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Player X', style: customFontWhite),
                          Text(xScore.toString(), style: customFontWhite),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: GridView.builder(
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    if (displayXO[index] == '' && !winnerFound) {
                      setState(() {
                        displayXO[index] = oTurn ? 'O' : 'X';
                        filledBoxes++;
                        _checkWinner();
                        if (!winnerFound) {
                          oTurn = !oTurn;
                          startTimer();
                        }
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.white)),
                    child: Center(
                      child: Text(displayXO[index], style: customFontWhite),
                    ),
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