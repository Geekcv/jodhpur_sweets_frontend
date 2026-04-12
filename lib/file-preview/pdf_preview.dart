import 'dart:io';

// import 'package:btc_crm/widgets/players/pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

import '../../utilities/sizeconfig.dart';
import '../players/pdf_viewer.dart';

class PdfPreview extends StatefulWidget {
  final filePath;
  const PdfPreview({super.key, this.filePath});

  @override
  State<PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<PdfPreview> {
  @override
  void initState() {
    showPdfPreview(widget.filePath);
    super.initState();
  }

  var errorMessage;
  bool isDisposed = false;
  var imageDAta;
  var filePath;

  Future<void> _downloadFile() async {
    try {
      var fileext = widget.filePath.split('.').last;
      var filename = widget.filePath.split('/').last;
      final dir = await getApplicationDocumentsDirectory();
      print('filename: $filename');
      var isExist = await File('${dir.path}/$filename').exists();
      print('isExist: $isExist');
      if (isExist) {
        filePath = '${dir.path}/$filename';
        print('file.path: $filePath');
        // return;
      } else {
        final response = await http.get(Uri.parse(widget.filePath));
        // final filename = '${DateTime.now().millisecondsSinceEpoch}.${fileext}';
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(response.bodyBytes);
        print('file.path: ${file.path}');
        filePath = file.path;
      }
    } catch (e) {
      if (!isDisposed) {
        setState(() {
          errorMessage = 'Error downloading audio: $e';
        });
      }
    }
  }

  Future<void> showPdfPreview(String pdfPath) async {
    // await _downloadFile();
    // // var resp = await http.get(Uri.parse(pdfPath));
    // // var pdfDAta = resp.bodyBytes;
    // var pdfDAta = File(filePath).readAsBytesSync();
    // final document = await PdfDocument.openData(pdfDAta);
    // final page = await document.getPage(1);
    // final image = await page.render(
    //   width: page.width,
    //   height: page.height,
    // );
    // page.close();
    // document.close();
    setState(() {
      // imageDAta = Image.memory(image!.bytes);
      imageDAta = widget.filePath;
    });

    // Image.memory(image!.bytes);
  }

  @override
  Widget build(BuildContext context) {
    if (imageDAta != null) {
      return InkWell(
        onTap: () {
          // showDialog(
          //     barrierDismissible: true,
          //     context: context,
          //     builder: (context) {
          //       return ScaffoldMessenger(
          //         child: Builder(
          //           builder: (context) => Scaffold(
          //             backgroundColor: Colors.transparent,
          //             body: PDFViewer(
          //               pdfPath: widget.filePath,
          //               isnetwork: true,
          //             ),
          //           ),
          //         ),
          //       );
          //     }
          // );
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return PDFViewer(
                pdfPath: widget.filePath,
                isnetwork: true,
              );
            },
          );

          // Navigator.of(context).push(MaterialPageRoute(
          //     builder: (context) => PDFViewer(
          //           pdfPath: widget.filePath,
          //           isnetwork: true,
          //         )));
        },
        child: Icon(
          Icons.picture_as_pdf,
          color: Colors.red,
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(8),
      width: SizeConfig.blockSizeHorizontal! * 60,
      height: 100,
      //     SizeConfig.blockSizeHorizontal! *
      //         60,
      decoration: BoxDecoration(
          color: Color.fromARGB(113, 231, 236, 235),
          // border: Border.all(
          //   color: Colors.blue,
          // ),
          borderRadius: BorderRadius.circular(7)),
      child: Center(
        child: CircularProgressIndicator(
          color: const Color.fromARGB(181, 247, 194, 190),
        ),
      ),
    );
  }
}
