import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:widget_zoom/widget_zoom.dart';
import 'package:path_provider/path_provider.dart';

import '../../utilities/sizeconfig.dart';

class ImagePreview extends StatefulWidget {
  final filePath;
  const ImagePreview({super.key, this.filePath});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
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
    imageDAta = widget.filePath;

    // Image.memory(image!.bytes);
  }

  @override
  void didUpdateWidget(covariant ImagePreview oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return imageDAta != null
        ? WidgetZoom(
            maxScaleFullscreen: 2.0,
            maxScaleEmbeddedView: 2.0,
            heroAnimationTag: 'chat-img',
            zoomWidget: Image.network(
              imageDAta,
              width: SizeConfig.blockSizeHorizontal! * 35,
              height: 200,
            ))
        // Image.file(
        //     imageDAta,
        //     width: SizeConfig.blockSizeHorizontal! * 35,
        //     height: 200,

        //   )
        : Container(
            padding: EdgeInsets.all(8),
            width: SizeConfig.blockSizeHorizontal! * 35,
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
