import "package:flutter/material.dart";
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import '../const.dart';

class HelpScreen extends StatefulWidget {
  @override
  HelpScreenState createState() => HelpScreenState();
}

class HelpScreenState extends State<HelpScreen> {

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()..setJavaScriptMode(JavaScriptMode.disabled);
    _loadHtmlFromAssets();
  }

  Future<void> _loadHtmlFromAssets() async {
    final htmlString = await rootBundle.loadString(constHelpFileLocation);
    _controller.loadHtmlString(htmlString);
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
                    child: Text("How to Play $appTitle",
                        style: TextStyle(
                            fontFamily: constAppTitleFont,
                            fontSize: 35)),
                  ),
                  SizedBox(
                    height: 500.0,
                    child: WebViewWidget(
                      controller: _controller,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  const Center(
                    child: Text(appVersion, style: TextStyle(fontFamily: constAppTitleFont,fontSize: 20)),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Center(
                  child: Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 3)),
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Image.asset(
                        sdsLogo,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  )),
                  const Padding(
                    padding: EdgeInsets.all(5.0),
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
                          constButtonOK,
                          style: TextStyle(
                              fontFamily: constAppTitleFont, 
                              color: Colors.black,
                              fontSize: .0),
                        )),
                                        onPressed: () {
                      Navigator.pop(context);
                    },                 
                  ),
                ),
                  ),
                ],
              ),
            ))));
  }
}
