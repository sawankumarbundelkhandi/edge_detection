import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:edge_detection/edge_detection.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _imagePath = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String imagePath;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      imagePath = await EdgeDetection.detectEdge;
      if (imagePath != null) {
        print("$imagePath");
      }
    } on PlatformException {
      imagePath = 'Failed to get cropped image path.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _imagePath = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app - Updated'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: RaisedButton(
                onPressed: initPlatformState,
                child: Text('Scan'),
              ),
            ),
            SizedBox(height: 20),
            Text('Cropped image path:'),
            Padding(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
              child: Text(
                '$_imagePath\n',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
