// ignore_for_file: file_names, camel_case_types, use_key_in_widget_constructors, prefer_const_constructors

import "package:flutter/material.dart";

import "../utilities/sizeconfig.dart";
import "Dialog_Box.dart";

class task_list_detail extends StatefulWidget {
  const task_list_detail();

  @override
  State<task_list_detail> createState() => _task_list_detailState();
}

class _task_list_detailState extends State<task_list_detail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xff9c9c9c), width: 1),
                color: Color(0xffffffff),
              ),
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 4, right: 0, bottom: 0, left: 0),
              width: SizeConfig.blockSizeHorizontal! * 100,
              height: SizeConfig.blockSizeVertical! * 17,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          color: Color(0xffffffff),
                        ),
                        alignment: Alignment.topCenter,
                        width: SizeConfig.blockSizeHorizontal! * 85,
                        height: SizeConfig.blockSizeVertical! * 5,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const dialog_box()));
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                      ),
                                      alignment: Alignment.topLeft,
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 40,
                                      height: SizeConfig.blockSizeVertical! * 3,
                                      child: Text(
                                        'Complete audit',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Roboto',
                                          color: Color(0xff110303),
                                        ),
                                      ))),
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: Color(0xfffbd798),
                                  ),
                                  alignment: Alignment.center,
                                  width: SizeConfig.blockSizeHorizontal! * 40,
                                  height: SizeConfig.blockSizeVertical! * 3,
                                  child: Text(
                                    '5 days remaining',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Roboto',
                                      color: Color(0xffda9052),
                                    ),
                                  )),
                            ])),
                    Container(
                        decoration: BoxDecoration(
                          color: Color(0xffffffff),
                        ),
                        alignment: Alignment.topLeft,
                        width: SizeConfig.blockSizeHorizontal! * 80,
                        height: SizeConfig.blockSizeVertical! * 10,
                        child: Text(
                          'Get audit completed as soon as possible.Get audit completed as soon as possible.Get audit completed as soon as possible.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Roboto',
                            color: Color(0xff110303),
                          ),
                        )),
                  ])),
        ],
      ),
    );
  }
}
