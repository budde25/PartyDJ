import 'package:flutter/material.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:spotify_queue/backend/functions.dart';
import 'package:spotify_queue/backend/storageUtil.dart';

class QRViewer extends StatefulWidget {
  @override
  _QRViewerState createState() => _QRViewerState();
}

class _QRViewerState extends State<QRViewer> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String qrText = '';
  //QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            ),
        ],
      ),
    );
  }
}
