import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utilities/sizeconfig.dart';

class DisplaySelectedDates extends StatefulWidget {
  DisplaySelectedDates({super.key, required this.selctedDates});
  List selctedDates;
  @override
  State<DisplaySelectedDates> createState() => _DisplaySelectedDatesState();
}

class _DisplaySelectedDatesState extends State<DisplaySelectedDates> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    arrange();
  }

  List selctedDates = [];
  arrange() {
    selctedDates = widget.selctedDates;

    var sorted = selctedDates
        .map((e) {
          return e['month'].toString();
        })
        .toSet()
        .toList();
    displayList = [];
    for (var m in sorted) {
      displayList.add({
        'month': m,
        'dates': selctedDates.where((s) {
          return s['month'] == m;
        }).toList()
      });
      selctedDates.sort((a, b) => a['date'].compareTo(b['date']));

      selctedDates.sort((a, b) => DateFormat('MMMM')
          .parse(a['month'])
          .month
          .compareTo(DateFormat('MMMM').parse(b['month']).month));
    }

    // print('sssssssssssssssssffsss${displayList}');
  }

  List displayList = [];
  Widget build(BuildContext context) {
    arrange();
    return Column(
      children: [
        for (var e in displayList)
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      alignment: Alignment.center,
                      color: Colors.blue.shade100,
                      // height: SizeConfig.blockSizeVertical! * 5,
                      width: SizeConfig.blockSizeHorizontal! * 8,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(e['month']),
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (var dates in e['dates'] ?? [])
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.blue.shade300),
                                alignment: Alignment.center,
                                child: Text(
                                  dates['date'].toString(),
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                      ],
                    ),
                  )
                ],
              ),
              Divider()
            ],
          ),
      ],
    );
  }
}
