import '../const.dart';
import 'package:flutter/material.dart';

Future<Object?> showMoveChoiceDialog(BuildContext context) {
  return showDialog<Object?>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 129, 128, 108),
      content: 
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          const Text(
            constMoveChoiceMessage,
            style: TextStyle(fontSize: 25, fontFamily: constAppTextFont,),
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, EnumMoveChoice.one),
                child: Container(
                  height: 90,
                  width: 80,
                  margin: EdgeInsets.only(right: 16),
                  child: Image.asset(constMoveAllDirections, fit: BoxFit.fill),
                )
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () => Navigator.pop(context, EnumMoveChoice.all),
                child: Container(
                  height: 89,
                  width: 80,
                  margin: EdgeInsets.only(right: 16),
                  child: Image.asset(constMoveForwardOnly, fit: BoxFit.fill),
                )
              ),
            ],
            ),
          ),
          const SizedBox(height: 24),
          ],
        ),
        actions: [ SizedBox(
                    width: 130.0,
                    height: 50.0,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black, // Text and icon color
                        backgroundColor: Colors.white, // Background color
                        overlayColor: Colors.blueAccent.withValues(), // pressed ripple
                        side: BorderSide(color: Colors.black,   width: 5.0,),),     
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(constButtonCancel,
                            style: TextStyle(
                                fontFamily: constAppTextFont,
                                color: Colors.black,
                                fontSize: 25.0),
                          )),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
          ],
    ),
  );
}
      

