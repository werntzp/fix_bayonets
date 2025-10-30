import 'package:flutter/material.dart';
import 'screens/help_screen.dart';
import 'screens/game_screen.dart';
import 'const.dart';

void main() {
  runApp(const FixBayonetsApp());
}

class FixBayonetsApp extends StatelessWidget {
  const FixBayonetsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      home: FixBayonetsHome(),
    );
  }
}

class FixBayonetsHome extends StatelessWidget {
   FixBayonetsHome({Key? key}) : super(key: key);

  void _showHelpScreen(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HelpScreen()),
    );
  }

  void _showGameScreen(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  GameScreen(key: UniqueKey())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Stack(
      children: <Widget>[
        Image(
          image: const AssetImage(appSplashGraphic),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),
        const Padding(
          padding: EdgeInsets.all(25.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              appTitle,
              style: TextStyle(
                  fontFamily: constAppTitleFont,
                  color: Colors.black,
                  fontSize: 68.0),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 3)),
            child: Image(
              image: AssetImage(sdsLogo),
              width: 75.0,
              height: 75.0,
              fit: BoxFit.cover,
            )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(height: 175),
                SizedBox(
                  width: 160.0,
                  height: 55.0,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black, // Text and icon color
                      backgroundColor: Colors.white, // Background color
                      side: BorderSide(color: Colors.black,   width: 3.0,), // Border color
                    ),                    
                    child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Play",
                          style: TextStyle(
                              fontFamily: constAppTitleFont,
                              color: Colors.black,
                              fontSize: 30.0),
                        )),
                    onPressed: () {
                      _showGameScreen(context);
                    },
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                SizedBox(
                  width: 160.0,
                  height: 55.0,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black, // Text and icon color
                      backgroundColor: Colors.white, // Background color
                      side: BorderSide(color: Colors.black,   width: 3.0,), // Border color
                    ),     
                    child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Help",
                          style: TextStyle(
                              fontFamily: constAppTitleFont,
                              color: Colors.black,
                              fontSize: 30.0),
                        )),
                    onPressed: () {
                      _showHelpScreen(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    )));
  }
}
