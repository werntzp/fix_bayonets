import "package:flutter/material.dart";
import '../main.dart';
import '../const.dart';

class GameOverScreen extends StatelessWidget {

final bool won;

const GameOverScreen({super.key, required this.won});

String _dialogText() {
  if (won) {
    return 'You won!';
  } else {
    return 'You lost!';
  }
}

  // main build function
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor:       const Color.fromARGB(255, 129, 128, 108),
            body: Center(
                child: Container(
              margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  const Center(
                    child: Text("Game Over!",
                        style: TextStyle(
                            fontFamily: constAppTitleFont,
                            fontSize: 40)),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                   Center(
                    child: Text(_dialogText(),
                        style: TextStyle(
                            fontFamily: constAppTitleFont,
                            fontSize: 30)),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                  ),
                Center(
                  child: SizedBox(
                  width: 160.0,
                  height: 55.0,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black, // Text and icon color
                      backgroundColor: Colors.white, // Background color
                      side: BorderSide(color: Colors.black,   width: 5.0,), // Border color
                    ),   
                                        child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          constButtonHome,
                          style: TextStyle(
                              fontFamily: constAppTitleFont, 
                              color: Colors.black,
                              fontSize: 28.0),
                        )),
                        onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FixBayonetsApp()),
                            );
                    },                 
                  ),
                ),
                  ),
                ],
              ),
            ))));
  }
}
