import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:http/http.dart' as http;

import '../utilities/sizeconfig.dart';

class PDFViewer extends StatefulWidget {
  final String pdfPath;
  final String title;
  final bool isnetwork;

  PDFViewer(
      {required this.pdfPath,
      this.isnetwork = false,
      this.title = 'PDf Viewer'});

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  int currentPage = 0;
  bool isReady = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("pdffffffffffffff${widget.pdfPath}");
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))
      ),
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${widget.title}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            splashRadius: 20,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            icon: Icon(Icons.cancel_outlined),
            color: Colors.red,
            tooltip: 'Close',
            onPressed: () {
              Navigator.pop(context);
            },
          )],
      ),
      content: Column(
        children: [
          Divider(),
          Container(
            padding: EdgeInsets.all(30),
           width: SizeConfig.blockSizeHorizontal!*65,
           height: SizeConfig.blockSizeVertical!*80,
           // color: Colors.green,
           child: SfPdfViewerTheme(
               data: SfPdfViewerThemeData(
                 // progressBarColor: Colors.green, // Apply dark theme
                 backgroundColor: Colors.white, //<----
               ),
               child: SfPdfViewer.network(widget.pdfPath)),
          ),
        ],
      ),
    );
  }
}
