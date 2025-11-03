import "package:flutter/material.dart";
import '../main.dart';
import '../const.dart';

class GameOverScreen extends StatelessWidget {

final bool won;

const GameOverScreen({super.key, required this.won});

String _dialogText() {
  if (won) {
    return constVictoryMessage;
  } else {
    return constDefeatMessage;
  }
}

String _graphic() {
  if (won) {
    return constAmericanVictory;
  } else {
    return constGermanVictory;
  }
}

  // main build function
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Stack(
              children: <Widget>[
                Image(
                  image: AssetImage(_graphic()),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                ),              
              Padding(
                padding: EdgeInsets.all(1.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child:  Text(
                    _dialogText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: constAppTextFont,
                        color: Colors.white,
                        fontSize: 35.0),
                  ),
                ),
              ),
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                  ),
                Positioned(
                  top: 750,
                  left: 125, 
                child: Center(
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
                              fontFamily: constAppTextFont, 
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
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
                  )),
              ],)

            ));
  }
}
