import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:prosys_app/widgets/CusCalSeldate.dart';

import '../utilities/sizeconfig.dart';
import 'CusCalSeldate.dart';

class CustomCalender extends StatefulWidget {
  CustomCalender(
      {super.key, this.getSelectedDates, required this.currentSelectedDates});
  Function? getSelectedDates;
  List currentSelectedDates;
  @override
  State<CustomCalender> createState() => _CustomCalenderState();
}

class _CustomCalenderState extends State<CustomCalender> {
  List selctedDates = [];
  String currentDisplayMonth = DateFormat('MMMM').format(DateTime.now());
  void _changeMonth({required int change}) {
    {
      setState(() {
        DateTime currentDate = DateFormat('MMMM').parse(currentDisplayMonth);
        DateTime newDate =
            DateTime(DateTime.now().year, currentDate.month + change);
        print(newDate.year);
        if (newDate.year == DateTime.now().year) {
          currentDisplayMonth = DateFormat('MMMM').format(newDate);
        } else {
          currentDisplayMonth = DateFormat('MMMM')
              .format(DateTime(DateTime.now().year, DateTime.now().month));
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selctedDates = widget.currentSelectedDates;
    setState(() {});
    // _changeMonth()
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: AlertDialog(
        insetPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        actionsPadding: EdgeInsets.zero,
        title: Column(
          children: [
            Text("Select Date"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    _changeMonth(change: -1);
                  },
                ),
                Text(
                  currentDisplayMonth ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    _changeMonth(change: 1);
                  },
                ),
              ],
            ),
          ],
        ),
        content: SizedBox(
          // height: SizeConfig.blockSizeVertical! * 100,
          width: SizeConfig.blockSizeHorizontal! * 30,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: List.generate(7, (index) {
                  //     return Expanded(
                  //       child: Center(
                  //         child: Text(
                  //           DateFormat('EEE').format(
                  //             DateTime(2022, 1, index + 3),
                  //           ),
                  //           style: TextStyle(fontWeight: FontWeight.bold),
                  //         ),
                  //       ),
                  //     );
                  //   }),
                  // ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    // height: SizeConfig.blockSizeVertical! * 45,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7, // Number of columns
                        mainAxisSpacing: 5.0, // Vertical spacing
                        crossAxisSpacing: 5.0, // Horizontal spacing
                        // childAspectRatio: 1, // Adjust for calendar view
                      ),

                      itemCount: DateTime(
                        DateFormat('MMMM').parse(currentDisplayMonth).year,
                        DateFormat('MMMM').parse(currentDisplayMonth).month + 1,
                        0,
                      ).day,
                      // itemCount: DateTime(
                      //       DateFormat('MMMM').parse(currentDisplayMonth).year,
                      //       DateFormat('MMMM')
                      //               .parse(currentDisplayMonth)
                      //               .month +
                      //           1,
                      //       0,
                      //     ).day +
                      //     DateTime(
                      //       DateFormat('MMMM').parse(currentDisplayMonth).year,
                      //       DateFormat('MMMM').parse(currentDisplayMonth).month,
                      //       1,
                      //     ).weekday -
                      //     1,
                      itemBuilder: (context, index) {
                        int firstDayOfMonth = DateTime(
                          DateFormat('MMMM').parse(currentDisplayMonth).year,
                          DateFormat('MMMM').parse(currentDisplayMonth).month,
                          1,
                        ).weekday;
                        // int date = index - firstDayOfMonth + 2;
                        int date = index + 1;
                        // if (date < 1) {
                        //   return Container();
                        // }
                        var item = {
                          'date': date,
                          'month': currentDisplayMonth,
                          // 'year': DateFormat('MMMM').parse(currentDisplayMonth).year,
                          'year': DateTime.now().year,
                        };
                        bool exists = selctedDates.any((e) =>
                            e['date'] == item['date'] &&
                            e['month'] == item['month'] &&
                            e['year'] == item['year']);
                        bool disabledDate = false;

                        //  (DateTime.now().day > date &&
                        //     DateTime.now().month ==
                        //         DateFormat('MMMM')
                        //             .parse(currentDisplayMonth)
                        //             .month);

                        return InkWell(
                          onTap: disabledDate
                              ? null
                              : () {
                                  if (exists) {
                                    selctedDates.removeWhere((e) =>
                                        e['date'] == item['date'] &&
                                        e['month'] == item['month'] &&
                                        e['year'] == item['year']);
                                  } else {
                                    selctedDates.add(item);
                                  }
                                  widget.getSelectedDates!(selctedDates);
                                  setState(() {});
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              border: DateTime.now().day == date &&
                                      DateTime.now().month ==
                                          DateFormat('MMMM')
                                              .parse(currentDisplayMonth)
                                              .month
                                  ? Border.all(
                                      strokeAlign:
                                          BorderSide.strokeAlignOutside,
                                      color: const Color.fromARGB(
                                          255, 6, 117, 207),
                                      width: 1.5)
                                  : null,
                              borderRadius: BorderRadius.circular(5),
                              color: disabledDate
                                  ? const Color.fromARGB(255, 216, 216, 216)
                                  : exists
                                      ? Colors.blue.shade300
                                      : Colors.blue.shade50,
                            ),
                            // padding: EdgeInsets.all(15),
                            alignment: Alignment.center,
                            // height: 50,
                            child: Text(
                              date.toString(),
                              style: TextStyle(
                                  color: exists || disabledDate
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  DisplaySelectedDates(selctedDates: selctedDates)
                ],
              ),
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10,bottom: 10),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ),
        ],
      ),
    );
  }
}
