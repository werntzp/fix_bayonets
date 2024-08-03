import "package:flutter/material.dart";
import 'package:webview_flutter/webview_flutter.dart';
import '../const.dart';

class HelpScreen extends StatelessWidget {
  HelpScreen({Key? key}) : super(key: key);

  final _controller = WebViewController()..loadFlutterAsset('assets/help.html');

  // main build function
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
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
                    child: Text("How to Play",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontSize: 25)),
                  ),
                  SizedBox(
                    height: 425.0,
                    child: WebViewWidget(
                      controller: _controller,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  const Center(
                    child: Text(appTitle,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const Center(
                    child: Text(appVersion, style: TextStyle(fontSize: 15)),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(1.0),
                  ),
                  Center(
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Image.asset(
                        sdsLogo,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(1.0),
                  ),
                  Center(
                    child: FloatingActionButton(
                        heroTag: "fab1",
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        backgroundColor: Colors.white,
                        tooltip: "Back",
                        mini: true,
                        child: const Icon(Icons.arrow_back)),
                  ),
                ],
              ),
            ))));
  }
}
