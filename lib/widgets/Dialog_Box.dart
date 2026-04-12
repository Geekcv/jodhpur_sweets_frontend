// ignore_for_file: file_names, use_key_in_widget_constructors, camel_case_types, prefer_const_constructors, deprecated_member_use

import "package:flutter/material.dart";
import "../utilities/sizeconfig.dart";

class dialog_box extends StatefulWidget {
  const dialog_box();

  @override
  State<dialog_box> createState() => _dialog_boxState();
}

class _dialog_boxState extends State<dialog_box> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xff000000), width: 1),
                    borderRadius: BorderRadius.circular(20.0),
                    color: const Color(0xffffffff),
                  ),
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(8.0),
                  height: SizeConfig.blockSizeVertical! * 70,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              color: Color(0xffffffff),
                            ),
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.all(5.0),
                            width: SizeConfig.blockSizeHorizontal! * 80,
                            height: SizeConfig.blockSizeVertical! * 4,
                            child: Text(
                              'Complete Audit',
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Roboto',
                                color: Color(0xff110303),
                              ),
                            )),
                        Container(
                            decoration: BoxDecoration(
                              color: Color(0xffffffff),
                            ),
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(4.0),
                            width: SizeConfig.blockSizeHorizontal! * 80,
                            height: SizeConfig.blockSizeVertical! * 8,
                            child: Text(
                              'Get Audit Completed as soon as possible.Get Audit Completed as soon as possible.Get Audit Completed as soon as possible.Get Audit Completed as soon as possible.',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Roboto',
                                color: Color(0xff110303),
                              ),
                            )),
                        Container(
                            decoration: BoxDecoration(
                              color: Color(0xffffffff),
                            ),
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.all(8.0),
                            width: SizeConfig.blockSizeHorizontal! * 80,
                            height: SizeConfig.blockSizeVertical! * 4,
                            child: Text(
                              'Completion Data : 01- Nov - 2024',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Roboto',
                                color: Color(0xff110303),
                              ),
                            )),
                        Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xffb1afaf), width: 1),
                              borderRadius: BorderRadius.circular(5.0),
                              color: Color(0xffffffff),
                            ),
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(8.0),
                            width: SizeConfig.blockSizeHorizontal! * 80,
                            height: SizeConfig.blockSizeVertical! * 21,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                                width: 80,
                                                child: TextFormField(
                                                  autovalidateMode:
                                                      AutovalidateMode
                                                          .onUserInteraction,
                                                  controller:
                                                      TextEditingController()
                                                        ..text = '',
                                                  textAlign: TextAlign.justify,
                                                  obscureText: false,
                                                  maxLines: 3,
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  obscuringCharacter: '*',
                                                  style: TextStyle(
                                                      color: Color(0xff272727),
                                                      fontSize: 14),
                                                  decoration: InputDecoration(
                                                      filled: true,
                                                      contentPadding:
                                                          EdgeInsets.all(10.0),
                                                      fillColor: Color(
                                                          0xffffffff),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .zero,
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Color(
                                                                    0xffffffff),
                                                                style:
                                                                    BorderStyle
                                                                        .solid,
                                                                width: 1,
                                                              )),
                                                      errorMaxLines: 1,
                                                      errorStyle: TextStyle(
                                                          fontSize: 11),
                                                      border:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .zero,
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Color(
                                                                    0xffffffff),
                                                                style:
                                                                    BorderStyle
                                                                        .solid,
                                                                width: 1,
                                                              )),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              3)),
                                                              borderSide:
                                                                  BorderSide(
                                                                color:
                                                                    Colors.red,
                                                                style:
                                                                    BorderStyle
                                                                        .solid,
                                                              )),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .zero,
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Color(
                                                                    0xffffffff),
                                                                style:
                                                                    BorderStyle
                                                                        .solid,
                                                                width: 1,
                                                              )),
                                                      labelText:
                                                          'Add a Comment',
                                                      labelStyle: TextStyle(
                                                          color: Color(
                                                              0xff0d0d0d)),
                                                      hintText:
                                                          'Add a Comment'),
                                                  onChanged: (value) {},
                                                )),
                                          ),
                                        ],
                                      )),
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                      ),
                                      alignment: Alignment.center,
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 80,
                                      height: SizeConfig.blockSizeVertical! * 6,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xffffffff),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                                margin: EdgeInsets.all(8.0),
                                                width: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    55,
                                                height: SizeConfig
                                                        .blockSizeVertical! *
                                                    5,
                                                child: IconButton(
                                                  onPressed: () {},
                                                  iconSize: 24,
                                                  icon: Icon(
                                                    Icons.attach_file,
                                                    color: Color(0xff1e54a4),
                                                  ),
                                                )),
                                            Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xffffffff),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                                margin: EdgeInsets.all(8.0),
                                                width: SizeConfig
                                                        .blockSizeHorizontal! *
                                                    15,
                                                height: SizeConfig
                                                        .blockSizeVertical! *
                                                    5,
                                                child: IconButton(
                                                  onPressed: () {},
                                                  iconSize: 24,
                                                  icon: Icon(
                                                    Icons.send,
                                                    color: Color(0xff31649b),
                                                  ),
                                                )),
                                          ])),
                                ])),
                        Container(
                            decoration: BoxDecoration(
                              color: Color(0xffffffff),
                            ),
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.all(5.0),
                            width: SizeConfig.blockSizeHorizontal! * 80,
                            height: SizeConfig.blockSizeVertical! * 4,
                            child: Text(
                              'Attechments',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Roboto',
                                color: Color(0xff110303),
                              ),
                            )),
                        Container(
                            decoration: BoxDecoration(
                              color: Color(0xffffffff),
                            ),
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.all(8.0),
                            width: SizeConfig.blockSizeHorizontal! * 80,
                            height: SizeConfig.blockSizeVertical! * 5,
                            child: Text(
                              'Add Team : ',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Roboto',
                                color: Color(0xff110303),
                              ),
                            )),
                        Container(
                            decoration: BoxDecoration(
                              color: Color(0xffffffff),
                            ),
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(8.0),
                            width: SizeConfig.blockSizeHorizontal! * 80,
                            height: SizeConfig.blockSizeVertical! * 9,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.all(8.0),
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 32,
                                      height: SizeConfig.blockSizeVertical! * 5,
                                      child: Text(
                                        'Request Reschedule',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Roboto',
                                          color: Color(0xff110303),
                                        ),
                                      )),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: SizeConfig.blockSizeVertical! * 8,
                                      width:
                                          SizeConfig.blockSizeHorizontal! * 33,
                                      child: ElevatedButton(
                                          onPressed: () {},
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    side: BorderSide(
                                                        color: Color(
                                                            0xffffffff)))),
                                            elevation:
                                                MaterialStateProperty.all(0),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Color(0xff35a716)),
                                            foregroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.white),
                                          ),
                                          child: Text(
                                            'Complete',
                                            style: TextStyle(
                                              fontFamily: "'Roboto'",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xffffffff),
                                            ),
                                          )),
                                    ),
                                  ),
                                ])),
                      ])),
            ],
          ),
        ),
      ),
    );
  }
}
