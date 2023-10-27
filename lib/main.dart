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
    return const MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      home: FixBayonetsHome(),
    );
  }
}

class FixBayonetsHome extends StatelessWidget {
  const FixBayonetsHome({Key? key}) : super(key: key);

  void _showHelpScreen(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HelpScreen()),
    );
  }

  void _showGameScreen(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
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
                  fontFamily: 'HeadlinerNo45',
                  color: Colors.black,
                  fontSize: 75.0),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Image(
              image: AssetImage(sdsLogo),
              width: 75.0,
              height: 75.0,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(
                  width: 125.0,
                  height: 40.0,
                  child: OutlinedButton(
                    child: const Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          "Play",
                          style: TextStyle(
                              fontFamily: 'HeadlinerNo45',
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
                  width: 125.0,
                  height: 40.0,
                  child: OutlinedButton(
                    child: const Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          "Help",
                          style: TextStyle(
                              fontFamily: 'HeadlinerNo45',
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
