// import 'package:btc_crm/utilities/sizeconfig.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import '../players/audio_player.dart';
import '../players/video_player.dart';
import '../utilities/sizeconfig.dart';
import '../widgets/audio_player_inline.dart';
import 'image_preview.dart';
import 'pdf_preview.dart';
import 'package:flutter/material.dart';

import 'video_preview.dart';

class FilePreview extends StatefulWidget {
  final filePath;
  const FilePreview({super.key, this.filePath});

  @override
  State<FilePreview> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<FilePreview> {


  Future<void> forceDownloadWeb(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));

    final bytes = response.bodyBytes;

    final blob = html.Blob([bytes]);
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: blobUrl)
      ..download = fileName
      ..click();

    html.Url.revokeObjectUrl(blobUrl);
  }


  @override
  Widget build(BuildContext context) {
    // print("File Path: ${filePath.toString().endsWith(".mp4")}");
    if (widget.filePath.toString().endsWith(".jpg") ||
        widget.filePath.toString().endsWith(".jpeg") ||
        widget.filePath.toString().endsWith(".png") ||
        widget.filePath.toString().endsWith(".gif")) {
      return InkWell(
        // onTap: () => Navigator.of(context).push(MaterialPageRoute(
        //     builder: (context) => PdfPreview(
        //           filePath: filePath,
        //         ))),
        child: Container(
          margin: EdgeInsets.only(top: 4),
          height: SizeConfig.blockSizeHorizontal! * 25,
          width: SizeConfig.blockSizeHorizontal! * 25,
          decoration:
              BoxDecoration(
                  borderRadius:BorderRadius.circular(8),
                  border: Border.all(color: Color(0xffA9A9A9))),
          child: ImagePreview(
            filePath: widget.filePath,
          ),
        ),
      );
    }
    if (widget.filePath.toString().endsWith(".pdf")) {
      return InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PdfPreview(
                  filePath: widget.filePath,
                ))),
        child: Container(
          height: SizeConfig.blockSizeHorizontal! * 30,
          width: SizeConfig.blockSizeHorizontal! * 30,
          decoration:
              BoxDecoration(
                  borderRadius:BorderRadius.circular(8),
                  border: Border.all(color: Color(0xffA9A9A9))),
          child: PdfPreview(
            filePath: widget.filePath,
          ),
        ),
      );
    }
    //'mp3', 'wav', 'aac'
    if (widget.filePath.toString().endsWith(".mp3") ||
        widget.filePath.toString().endsWith(".wav") ||
        widget.filePath.toString().endsWith(".aac")) {
      return AudioPlayerInline(widget.filePath);
      // return AudioWavePlayer(audioUrl: widget.filePath);
    }
    //'mp4', 'avi', 'mkv'
    if (widget.filePath.toString().endsWith(".mp4") ||
        widget.filePath.toString().endsWith(".avi") ||
        widget.filePath.toString().endsWith(".mkv")) {
      // return VideoPreview(
      //   videoPath: filePath,
      // );
      return Container(
        height: SizeConfig.blockSizeHorizontal! * 45,
        width: SizeConfig.blockSizeHorizontal! * 45,
        decoration: BoxDecoration(
            borderRadius:BorderRadius.circular(8),
            border: Border.all(color: Color(0xffA9A9A9))),
        child: Player(
          videoLink: widget.filePath,
          page: false,
        ),
      );
    }

    if (widget.filePath.toString().endsWith(".xls") || widget.filePath.toString().endsWith(".xlsx")) {
      return InkWell(
        // onTap: () => openFileExternally(widget.filePath),
          onTap: () async {
            String url = widget.filePath.toString();
            String fileName = url.split('/').last;

            await forceDownloadWeb(url, fileName);
          },
        child: Container(
          padding: EdgeInsets.all(12),
          height: SizeConfig.blockSizeHorizontal! * 30,
          width: SizeConfig.blockSizeHorizontal! * 30,
          decoration: BoxDecoration(
              borderRadius:BorderRadius.circular(8),
              border: Border.all(color: Color(0xffA9A9A9))),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.table_view, size: 20, color: Colors.green),
                  SizedBox(height: 5),
                  Text("Excel",style: TextStyle(fontSize: 10))
                ],
              )),
        ),
      );
    }


    if (widget.filePath.toString().endsWith(".doc") || widget.filePath.toString().endsWith(".docx")) {
      return InkWell(
        // onTap: () => openFileExternally(widget.filePath),
        onTap: () async {
          String url = widget.filePath.toString();
          String fileName = url.split('/').last;

          await forceDownloadWeb(url, fileName);
        },
        child: Container(
          padding: EdgeInsets.all(12),
          height: SizeConfig.blockSizeHorizontal! * 30,
          width: SizeConfig.blockSizeHorizontal! * 30,
          decoration: BoxDecoration(
              borderRadius:BorderRadius.circular(8),
              border: Border.all(color: Color(0xffA9A9A9,))),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description, size: 20, color: Colors.blue),
                  SizedBox(height: 5),
                  Text("Word",style: TextStyle(fontSize: 10))
                ],
              )),
        ),
      );
    }

    if (widget.filePath.toString().endsWith(".txt")) {
      return InkWell(
        onTap: () async {
          String url = widget.filePath.toString();
          String fileName = url.split('/').last;

          await forceDownloadWeb(url, fileName);
        },
        child: Container(
          padding: EdgeInsets.all(12),
          height: SizeConfig.blockSizeHorizontal! * 30,
          width: SizeConfig.blockSizeHorizontal! * 30,
          decoration: BoxDecoration(
              borderRadius:BorderRadius.circular(8),
              border: Border.all(color: Color(0xffA9A9A9))),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.text_snippet_outlined, size: 20, color: Colors.grey[700]),
                  SizedBox(height: 5),
                  Text("Text File", style: TextStyle(fontSize: 10))
                ],
              )),
        ),
      );
    }



    return const Placeholder();
  }
}
