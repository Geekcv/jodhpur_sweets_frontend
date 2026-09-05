import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CustomPdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final String fileName;

  const CustomPdfViewerScreen({
    super.key,
    required this.pdfUrl,
    this.title = "Document Preview",
    this.fileName = "Document.pdf",
  });

  @override
  State<CustomPdfViewerScreen> createState() => _CustomPdfViewerScreenState();
}

class _CustomPdfViewerScreenState extends State<CustomPdfViewerScreen> {
  String _viewId = "";
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && widget.pdfUrl.isNotEmpty) {
      _viewId = 'pdf-frame-${DateTime.now().millisecondsSinceEpoch}';

      // Google Docs Viewer URL (Bypasses Web CORS issues completely)
      final String embeddedUrl =
          "https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(widget.pdfUrl)}";

      ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
        final iframe = html.IFrameElement()
          ..src = embeddedUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      });
    }
  }

  void _triggerDownload() {
    if (widget.pdfUrl.isEmpty) return;
    setState(() => _isDownloading = true);

    try {
      if (kIsWeb) {
        final anchor = html.AnchorElement(href: widget.pdfUrl)
          ..setAttribute("download", widget.fileName)
          ..setAttribute("target", "_blank")
          ..click();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar Header
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xff1E1E1E),
                border: Border(bottom: BorderSide(color: Color(0xff2C2C2C), width: 1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, color: Color(0xffE0E0E0), size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xffF3F4F6)),
                        ),
                        Text(
                          widget.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Color(0xff9CA3AF)),
                        ),
                      ],
                    ),
                  ),
                  // ElevatedButton.icon(
                  //   onPressed: _isDownloading ? null : _triggerDownload,
                  //   icon: const Icon(Icons.file_download_outlined, size: 16),
                  //   label: Text(_isDownloading ? "Saving..." : "Download"),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: const Color(0xff2563EB),
                  //     foregroundColor: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            ),

            // Main PDF Content Body
            Expanded(
              child: widget.pdfUrl.trim().isEmpty
                  ? const Center(
                child: Text("PDF URL empty", style: TextStyle(color: Colors.white)),
              )
                  : kIsWeb
                  ? HtmlElementView(viewType: _viewId)
                  : SfPdfViewer.network(widget.pdfUrl),
            ),
          ],
        ),
      ),
    );
  }
}