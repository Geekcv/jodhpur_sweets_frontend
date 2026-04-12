import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

List roles = [
  {"title": "User", "value": '0'},
  {"title": "Admin", "value": '1'},
  {"title": "Dept-Admin", "value": '2'},
  {"title": "Top-Management", "value": '3'}
];

String appVersion='';


var buttonStyleBlue = ButtonStyle(
  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(borderRadius:BorderRadius.circular(5),side: BorderSide(color: Color(0xffffffff)))),
  elevation: WidgetStateProperty.all(0),
  backgroundColor:WidgetStateProperty.all<Color>(Color(0xff3081c0)),
  foregroundColor:WidgetStateProperty.all<Color>(Colors.white),
);


List<TextSpan> highlightTextOnSearching(String text, String searchText, TextStyle highlightStyle) {
  if (searchText.isEmpty || searchText == null) {
    return [TextSpan(text: text)];
  }

  List<TextSpan> spans = [];
  int start = 0;
  int indexOfHighlight;

  while ((indexOfHighlight = text.toLowerCase().indexOf(searchText.toLowerCase(), start)) != -1) {
    if (indexOfHighlight > start) {
      spans.add(TextSpan(text: text.substring(start, indexOfHighlight)));
    }
    spans.add(TextSpan(
      text: text.substring(indexOfHighlight, indexOfHighlight + searchText.length),
      style: highlightStyle,
    ));
    start = indexOfHighlight + searchText.length;
  }

  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start)));
  }

  return spans;
}


showToast({required BuildContext context, msg, color}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
  );
}



Widget buildShimmerEffect({required BuildContext context, msg, count}) {
  return Shimmer.fromColors(
    baseColor: const Color(0xFFE5E7EB),
    highlightColor: const Color(0xFFF3F4F6),
    period: const Duration(milliseconds: 1500),
    child: SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: List.generate(5, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular or Square Leading
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Title Bar
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Subtitle Bar (70% width)
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Action Button/Price Skeleton
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        )),
      ),
    ),
  );
}



Widget buildShimmerEffectCard({required BuildContext context}) {
  final size = MediaQuery.of(context).size;
  return Shimmer.fromColors(
    baseColor: const Color(0xFFE5E7EB), // Contrast for white background
    highlightColor: const Color(0xFFF3F4F6),
    period: const Duration(milliseconds: 1500),
    child: GridView.builder(
      padding: const EdgeInsets.all(24),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size.width > 1200 ? 3 : size.width > 800 ? 2 : 1,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        mainAxisExtent: 410, // Aapke original mainAxisExtent ke barabar
      ),
      itemCount: 4, // Jitne cards loading mein dikhane ho
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Shimmer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(width: 20, height: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Container(width: 100, height: 16, color: Colors.white),
                    const Spacer(),
                    Container(width: 70, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Info Tiles Shimmer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (index) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 50, height: 10, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 80, height: 12, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(width: 60, height: 10, color: Colors.white),
                    ],
                  )),
                ),
              ),
              const SizedBox(height: 25),
              // Items Summary Box Shimmer
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(width: 90, height: 10, color: Colors.white),
                          Container(width: 40, height: 10, color: Colors.white),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // List of items skeleton
                      ...List.generate(3, (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                            const SizedBox(width: 12),
                            Container(width: 120, height: 12, color: Colors.white),
                            const Spacer(),
                            Container(width: 40, height: 12, color: Colors.white),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              // Footer Action Shimmer
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(width: 35, height: 35, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}