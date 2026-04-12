import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import 'package:getwidget/components/dropdown/gf_multiselect.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../services/api_services.dart';
import '../utilities/functions.dart';
import '../utilities/sizeconfig.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:collection/collection.dart';

class MSelectList extends StatefulWidget {
  final item;
  final getFormData;
  final form;
  MSelectList(this.item, this.form, this.getFormData);
  @override
  _MSelectListState createState() => _MSelectListState();
}

class _MSelectListState extends State<MSelectList> {
  var options = [];
  var toptions = [];
  bool _allCheck = false;
  void initState() {
    // print('mmselleccctt${widget.item['name']}');
    TextEditingController _searchCtrl = new TextEditingController();
    addOptions();
  }

  addOptions() {
    options = [];
    toptions = [];
    // print("options--------------");
    // print(widget.item['options']);
    setState(() {
      options.addAll(json.decode(json.encode(widget.item['options'])));
      toptions.addAll(json.decode(json.encode(widget.item['options'])));
    });
    for (var i = 0; i < options.length; i++) {
      if (widget.item['value'].contains(options[i]['value'])) {
        setState(() {
          options[i]['selected'] = true;
          toptions[i]['selected'] = true;
        });
      }
    }
    // print('ooooooooooooooOPTIONS_fromelementBuilderooooooooo}');
    // print('ooooooooooooooooooooooo${options}');
  }

  void didUpdateWidget(oldwidget) {
    // print("new ${widget.item}");
    // print("old ${oldwidget.item}");
    // if (oldwidget.item['options'].length != widget.item['options'].length) {
    addOptions();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.item['width'],
      decoration:
          BoxDecoration(border: Border.all(color: const Color(0xffeeeeee))),
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.only(left: 8, top: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                  value: _allCheck,
                  onChanged: (val) {
                    setState(() {
                      _allCheck = val!;
                      if (_allCheck) {
                        for (var i = 0; i < options.length; i++) {
                          setState(() {
                            options[i]['selected'] = true;
                            toptions[i]['selected'] = true;
                            widget.item['value'].add(options[i]['value']);

                            widget.form['data'][widget.item['id']] =
                                widget.item['value'];
                          });
                        }
                      } else {
                        for (var i = 0; i < options.length; i++) {
                          setState(() {
                            options[i]['selected'] = false;
                            toptions[i]['selected'] = false;

                            widget.item['value'].remove(options[i]['value']);
                            widget.form['data'][widget.item['id']] =
                                widget.item['value'];
                          });
                        }
                      }
                    });
                  }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    '${widget.item['title']} (${widget.item['value'].length})'),
              ),
            ],
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            width: widget.item['width'],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: widget.item['width'] - 100,
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Search ${widget.item['title']}"),
                    // controller: _searchCtrl,
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        options = [];
                        var tempD = toptions
                            .where((element) => element['title']
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                        // print(tempD);
                        options.addAll(tempD);
                        // print(options);
                        // options.addAll(toptions.where((element) {
                        //   // print(element['title']
                        //   //     .toLowerCase()
                        //   //     .contains(value.toLowerCase()));
                        //   // return true;
                        //   return element['title']
                        //       .toLowerCase()
                        //       .contains(value.toLowerCase());
                        // }));
                        // print(tableData);
                        // tableData.addAll(widget.tableData.where((element) {
                        //   print(element);
                        //   element['data']['_ti'].contains(value);
                        // }));
                      });
                      // print("value----------------$value");
                      // print(toptions);

                      // if (value == null || value == "" || value.isEmpty) {
                      //   setState(() {
                      //    options =
                      //         json.decode(json.encode(toptions));
                      //   });
                      // } else {
                      //   setState(() {
                      //     // widget.item['options'] = [];
                      //     var tempData = toptions.where((element) =>
                      //         element['title']
                      //             .toLowerCase()
                      //             .contains(value.toLowerCase()));
                      //     options = List.from(tempData);
                      //     // widget.item['options'].addAll(tempData);
                      //   });
                      // }
                    },
                  ),
                ),
                // IconButton(
                //     onPressed: () {
                //       setState(() {
                //         // _searchCtrl.clear();
                //         widget.item['options'] = toptions;
                //       });
                //     },
                //     icon: Icon(Icons.close))
              ],
            ),
          ),
          Container(
            height: widget.item['height'],
            width: widget.item['width'],
            child: Scrollbar(
              controller: ScrollController(),
              radius: const Radius.circular(10.0),
              thumbVisibility: true,
              thickness: 7.0,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) => CheckboxListTile(
                  value: options[index]['selected'],
                  title: Text('${options[index]['title']}'),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) {
                    // print(isChecked);
                    // print(itm['selected']);
                    setState(() {
                      options[index]['selected'] = isChecked;
                      if (isChecked!) {
                        widget.item['value'].add(options[index]['value']);
                      } else {
                        widget.item['value'].remove(options[index]['value']);
                      }
                      widget.form['data'][widget.item['id']] =
                          widget.item['value'];
                    });

                    widget.getFormData(widget.form);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SS_VV_apiMSelectList extends StatefulWidget {
  final item;
  final getFormData;
  final form;
  Function? get_page;
  SS_VV_apiMSelectList({this.item, this.form, this.getFormData, this.get_page});
  @override
  _SS_VV_apiMSelectListState createState() => _SS_VV_apiMSelectListState();
}

class _SS_VV_apiMSelectListState extends State<SS_VV_apiMSelectList> {
  var options = [];
  var apioption = [];

  var toptions = [];
  bool _allCheck = false;
  int page = 1;

  bool searchload = false;

  searchSampark() async {
    var searched_samparksutra = [];

    print('sccaf');

    var data = {
      "fn": "common_fn",
      "se": "search_sampark_sutra",
      "data": {"search": ss_search.text}
    };
    print('63456y345grwe54${data}');
    var encodedData = Functions.encodeData(data);

    var tempdata = ss_search.text != ''
        ? Functions.decodeData(await Functions.httpPostwithOneParameter(encodedData))['data']
        : '';
    if (tempdata != 'false') {
      for (var i = 0; i < tempdata.length; i++) {
        // print('dsdsfdhsde${tempdata[i]}');
        setState(() {
          {
            searched_samparksutra.add({
              "name": tempdata[i]['english_title'] != null &&
                      tempdata[i]['english_title'] != ""
                  ? tempdata[i]['hindi_title']
                  : tempdata[i]['hindi_title'] ?? '',
              "title": tempdata[i]['english_title'] != null &&
                      tempdata[i]['english_title'] != ""
                  ? tempdata[i]['english_title'] +
                      (tempdata[i]['designation'] != null &&
                              tempdata[i]['designation'] != ""
                          ? " - ${tempdata[i]['designation']}"
                          : "") +
                      (tempdata[i]['telephone'] != null &&
                              tempdata[i]['telephone'] != "" &&
                              tempdata[i]['telephone'] != "null"
                          ? "(${tempdata[i]['telephone']})"
                          : "")
                  : tempdata[i]['hindi_title'] +
                      (tempdata[i]['designation'] != null &&
                              tempdata[i]['designation'] != ""
                          ? " - ${tempdata[i]['designation']}"
                          : "") +
                      (tempdata[i]['telephone'] != null &&
                              tempdata[i]['telephone'] != "" &&
                              tempdata[i]['telephone'] != "null"
                          ? "(${tempdata[i]['telephone']})"
                          : ""),
              "selected": false,
              "value": tempdata[i]['row_id'],
            });
          }
        });
      }
    }
    setState(() {
      searchload = false;
    });
    return searched_samparksutra;
  }

  void initState() {
    fetchSampark();

    controller.addListener(() async {
      if (controller.position.maxScrollExtent == controller.offset) {
        setState(() {
          page = page + 1;
          // scrollLoading = true;
        });
        var result = await widget.get_page!(page, null, null, options);
        setState(() {
          apioption.addAll(result);
        });
        await apiaddOptions();
      }
    });
    TextEditingController _searchCtrl = new TextEditingController();
    // addOptions();
  }

  fetchSampark() async {
    apioption =
        await widget.get_page!(page, widget.item['value'], null, options);
    await apiaddOptions();

    // print('apiMSelec3243423tLielectList${apioption}');
  }

  apiaddOptions() async {
    options = [];
    toptions = [];
    // // print("options--------------");
    // print('options--------------${widget.item}');
    // print('options--------------${widget.form}');
    // print('options--------------${widget.getFormData}');
    // print('options--------------${widget.item}');
    setState(() {
      // options.addAll(json.decode(json.encode(widget.item['options'])));
      // toptions.addAll(json.decode(json.encode(widget.item['options'])));
      // print('ooooooapiMSelectL${apioption}}');

      options.addAll(json.decode(json.encode(apioption)));
      toptions.addAll(json.decode(json.encode(apioption)));

      print('...3432534${widget.item['value']}..');
    });

    // thisloopistoselectwhenediting==========================================
    for (var i = 0; i < options.length; i++) {
      if (widget.item['value'].contains(options[i]['value'])) {
        setState(() {
          options[i]['selected'] = true;
          toptions[i]['selected'] = true;
          if (!widget.item['valueName'].contains(options[i]['title'])) {
            widget.item['valueName'].add(options[i]['title']);
          }
        });
      }
    }
    // for (var elements in options) {
    //   // print('ccas${elements}');
    //   if (elements['selected'] == true) {
    //     widget.item['value'].add(elements['value']);
    //     widget.item['valueName'].add(elements['title']);
    //   }
    // }
    widget.getFormData(widget.form);
  }

  void didUpdateWidget(oldwidget) {}

  final controller = ScrollController();
  TextEditingController ss_search = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // return Container();

    return Container(
      width: widget.item['width'],
      decoration:
          BoxDecoration(border: Border.all(color: const Color(0xffeeeeee))),
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.only(left: 8, top: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Checkbox(
              //     value: _allCheck,
              //     onChanged: (val) {
              //       setState(() {
              //         _allCheck = val!;
              //         if (_allCheck) {
              //           for (var i = 0; i < options.length; i++) {
              //             setState(() {
              //               options[i]['selected'] = true;
              //               toptions[i]['selected'] = true;
              //               widget.item['value'].add(options[i]['value']);

              //               widget.form['data'][widget.item['id']] =
              //                   widget.item['value'];
              //             });
              //           }
              //         } else {
              //           for (var i = 0; i < options.length; i++) {
              //             setState(() {
              //               options[i]['selected'] = false;
              //               toptions[i]['selected'] = false;

              //               widget.item['value'].remove(options[i]['value']);
              //               widget.form['data'][widget.item['id']] =
              //                   widget.item['value'];
              //             });
              //           }
              //         }
              //       });
              //     }),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    '${widget.item['title']} (${widget.item['valueName'].length})'),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 10),
                  child: Container(
                    // color: Colors.amber,
                    height: 30,
                    width: SizeConfig.blockSizeHorizontal! * 7,
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: apimselectlistSearchButtonColor),
                        onPressed: () async {
                          var searched_samparksutra = [];
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: SizeConfig.blockSizeVertical! * 80,
                                  width: SizeConfig.blockSizeHorizontal! * 50,
                                  child: StatefulBuilder(
                                    builder: (BuildContext context,
                                        void Function(void Function())
                                            setState) {
                                      return AlertDialog(
                                          title: Column(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                    "Search Sampark Sutra"),
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    height: SizeConfig
                                                            .blockSizeVertical! *
                                                        5,
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        25,
                                                    child: TextField(
                                                      decoration:
                                                          InputDecoration(
                                                              fillColor:
                                                                  rsTextFillColor,
                                                              filled: true,
                                                              labelText:
                                                                  "Name or Contact",
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .all(4),
                                                              enabledBorder:
                                                                  const OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              3)),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0xffACACAC),
                                                                        style: BorderStyle
                                                                            .solid,
                                                                      )),
                                                              border:
                                                                  OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              7),
                                                                      borderSide:
                                                                          const BorderSide(
                                                                        color: Color(
                                                                            0xffACACAC),
                                                                        style: BorderStyle
                                                                            .solid,
                                                                      )),
                                                              hintText:
                                                                  "Name or Contact"),
                                                      controller: ss_search,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    child: const Text("Search"),
                                                    onPressed: () async {
                                                      setState(() {
                                                        searchload = true;
                                                      });
                                                      searched_samparksutra =
                                                          await searchSampark();
                                                      setState(() {
                                                        searchload = false;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          actions: <Widget>[
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              icon: Icon(
                                                Icons.arrow_back,
                                                size: 22,
                                              ),
                                              label: Text("Back"),
                                            ),
                                          ],
                                          content: Container(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    50,
                                            width: SizeConfig
                                                    .blockSizeHorizontal! *
                                                25,
                                            child: Scrollbar(
                                              controller: ScrollController(),
                                              radius:
                                                  const Radius.circular(10.0),
                                              thumbVisibility: true,
                                              thickness: 7.0,
                                              child: !searchload
                                                  ? searched_samparksutra
                                                          .isNotEmpty
                                                      ? ListView.builder(
                                                          // controller: controller,
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              searched_samparksutra
                                                                  .length,
                                                          itemBuilder: (context,
                                                                  index) =>
                                                              CheckboxListTile(
                                                            value:
                                                                searched_samparksutra[
                                                                        index][
                                                                    'selected'],
                                                            title: Text(
                                                                '${searched_samparksutra[index]['title']}'),
                                                            controlAffinity:
                                                                ListTileControlAffinity
                                                                    .leading,
                                                            onChanged:
                                                                (isChecked) {
                                                              searched_samparksutra[
                                                                          index]
                                                                      [
                                                                      'selected'] =
                                                                  isChecked;
                                                              {
                                                                // print(
                                                                //     'oooooooooooooooooooooo${options.length}');
                                                                // print(
                                                                //     'oooooooooooooooooooooo${searched_samparksutra[index]['value']}');

                                                                var result = options
                                                                    .firstWhereOrNull(
                                                                        (element) {
                                                                  // print(
                                                                  //     'oooooooooooooooooooooo423${element['value']}');

                                                                  return element[
                                                                          'value'] ==
                                                                      searched_samparksutra[
                                                                              index]
                                                                          [
                                                                          'value'];
                                                                });

                                                                // print(
                                                                //     'oooooooooooooooooooooo1111${result}');

                                                                if (result ==
                                                                    null) {
                                                                  setState(() {
                                                                    options.add(
                                                                        searched_samparksutra[
                                                                            index]);
                                                                    toptions.add(
                                                                        searched_samparksutra[
                                                                            index]);
                                                                    // print(
                                                                    //     'oooooooooooooooooooooo${options.length}');
                                                                  });
                                                                }
                                                              }

                                                              {
                                                                // print(isChecked);
                                                                // print(itm['selected']);
                                                                setState(() {
                                                                  print(
                                                                      'erhbiiinnnnnnssseesesesesefz3423534${searched_samparksutra[index]}');
                                                                  searched_samparksutra[
                                                                              index]
                                                                          [
                                                                          'selected'] =
                                                                      isChecked;
                                                                  apioption[index]
                                                                          [
                                                                          'selected'] =
                                                                      isChecked;
                                                                  print(
                                                                      'erhbfz3423534${widget.item['value']}');

                                                                  if (isChecked!) {
                                                                    widget.item[
                                                                            'value']
                                                                        .add(searched_samparksutra[index]
                                                                            [
                                                                            'value']);
                                                                    widget.item[
                                                                            'valueName']
                                                                        .add(searched_samparksutra[index]
                                                                            [
                                                                            'title']);
                                                                  } else {
                                                                    widget.item[
                                                                            'value']
                                                                        .remove(searched_samparksutra[index]
                                                                            [
                                                                            'value']);
                                                                    widget.item[
                                                                            'valueName']
                                                                        .remove(searched_samparksutra[index]
                                                                            [
                                                                            'title']);
                                                                  }
                                                                  widget.form[
                                                                      'data'][widget
                                                                          .item[
                                                                      'id']] = widget
                                                                          .item[
                                                                      'value'];
                                                                  // widget.form['data'][widget.item['id']]
                                                                  //     ['valueName'] = ['vdvdre'];
                                                                  // widget.item['valueName'].add(options[index]['title']);
                                                                });
                                                                widget.getFormData(
                                                                    widget
                                                                        .form);

                                                                print(
                                                                    'uuuuuuuuuuuuuu${widget.form}');
                                                              }
                                                            },
                                                          ),
                                                        )
                                                      : Center(
                                                          child: Text(
                                                            "Search For Sampark Sutra",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[300]),
                                                          ),
                                                        )
                                                  : Center(
                                                      child: Column(
                                                        children: [
                                                          LinearProgressIndicator(),
                                                          Text(
                                                            "Please Wait",
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        148,
                                                                        148,
                                                                        148)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                            ),
                                          ));
                                    },
                                  ),
                                );
                              });
                        },
                        icon: const Icon(Icons.search),
                        label: const Text(
                          'Search',
                          style: TextStyle(fontSize: 12),
                        )),
                  )),
            ],
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            width: widget.item['width'],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: widget.item['width'] - 100,
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Search ${widget.item['title']}"),
                    // controller: _searchCtrl,
                    onChanged: (value) {
                      print('uuuuuuuuuuuuuu${options.length}');

                      print(value);
                      setState(() {
                        options = [];
                        var tempD = toptions
                            .where((element) => element['title']
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                        // print(tempD);
                        options.addAll(tempD);
                      });
                    },
                  ),
                ),
                // IconButton(
                //     onPressed: () {
                //       setState(() {
                //         // _searchCtrl.clear();
                //         widget.item['options'] = toptions;
                //       });
                //     },
                //     icon: Icon(Icons.close))
              ],
            ),
          ),
          // Text(options.length.toString()),
          Container(
            height: widget.item['height'],
            width: widget.item['width'],
            child: Scrollbar(
              controller: ScrollController(),
              radius: const Radius.circular(10.0),
              thumbVisibility: true,
              thickness: 7.0,
              child: ListView.builder(
                controller: controller,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) => CheckboxListTile(
                  value: options[index]['selected'],
                  title: Text('${options[index]['title']}'),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) {
                    // print(isChecked);
                    // print(itm['selected']);
                    setState(() {
                      print('erhbfz3423534${options[index]}');
                      options[index]['selected'] = isChecked;
                      apioption[index]['selected'] = isChecked;
                      print('erhbfz3423534${widget.item['value']}');

                      if (isChecked!) {
                        widget.item['value'].add(options[index]['value']);
                        widget.item['valueName'].add(options[index]['title']);
                      } else {
                        widget.item['value'].remove(options[index]['value']);
                        widget.item['valueName']
                            .remove(options[index]['title']);
                      }
                      widget.form['data'][widget.item['id']] =
                          widget.item['value'];
                      // widget.form['data'][widget.item['id']]
                      //     ['valueName'] = ['vdvdre'];
                      // widget.item['valueName'].add(options[index]['title']);
                    });
                    widget.getFormData(widget.form);

                    print('uuuuuuuuuuuuuu${widget.form}');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class santVV_api_searchSelectList extends StatefulWidget {
  final item;
  final getFormData;
  final form;
  Function? get_page;
  santVV_api_searchSelectList(
      {this.item, this.form, this.getFormData, this.get_page});
  @override
  _santVV_api_searchSelectListState createState() =>
      _santVV_api_searchSelectListState();
}

class _santVV_api_searchSelectListState
    extends State<santVV_api_searchSelectList> {
  var options = [];
  var apioption = [];

  var toptions = [];
  bool _allCheck = false;
  int page = 1;

  bool searchload = false;

  search_sant_vv() async {
    var searched_sant_vv = [];

    print('sccaf');

    var data = {
      "fn": "common_fn",
      "se": "search_sant_sati",
      "data": {"search": ss_search.text}
    };
    print('63456y345grwe54${data}');
    var encodedData = Functions.encodeData(data);

    var tempdatass = ss_search.text != ''
        ? Functions.decodeData(await Functions.httpPostwithOneParameter(encodedData))['data']
        : '';

    // var tempdatass =
    //     Functions.decodeData(await Functions.httpPost(encodedData))['data'];
    if (tempdatass != 'false') {
      for (var i = 0; i < tempdatass.length; i++) {
        setState(() {
          print(
              'dsbvsgd${tempdatass[i]['diksha_seque'] == null || tempdatass[i]['diksha_seque'] == "null" ? tempdatass[i]['diksha_seque'].runtimeType : '---'}');
          searched_sant_vv.add({
            "title": (tempdatass[i]['title'] ?? tempdatass[i]['hindi_title']) +
                " (${tempdatass[i]['diksha_seque'] != null && tempdatass[i]['diksha_seque'] != '' && tempdatass[i]['diksha_seque'] != "null" ? tempdatass[i]['diksha_seque'] : ""})",
            "selected": false,
            "data": {"row_id": tempdatass[i]['row_id'], "json": tempdatass[i]},
            "diksha": tempdatass[i]['diksha_seque'] != null &&
                    tempdatass[i]['diksha_seque'] != '' &&
                    tempdatass[i]['diksha_seque'] != "null"
                ? tempdatass[i]['diksha_seque']
                : 20000,
            "value": tempdatass[i]['row_id'],
          });
        });
      }
    }
    setState(() {
      searchload = false;
    });
    return searched_sant_vv;
  }

  void initState() {
    fetchSants();

    controller.addListener(() async {
      if (controller.position.maxScrollExtent == controller.offset) {
        setState(() {
          page = page + 1;
          // scrollLoading = true;
        });
        var result = await widget.get_page!(page, null, null, options);
        setState(() {
          apioption.addAll(result);
          widget.item['selected_sant'] = [];
        });
        await apiaddOptions();
      }
    });
    TextEditingController _searchCtrl = new TextEditingController();
    // addOptions();
    print('ccccccccccccccccccc${widget.item['selected_sant']}');
    print('ccccccccccccccccccc${widget.item['selected_sant'].length}');
  }

  fetchSants() async {
    apioption =
        await widget.get_page!(page, null, widget.item['value'], options);
    await apiaddOptions();

    // print('apiMSelec3243423tLielectList${apioption}');
  }

  apiaddOptions() async {
    options = [];
    toptions = [];
    print('options--------------1${widget.item['valueName']}');

    widget.item['valueName'] = [];
    // // print("options--------------");
    print('options--------------2${widget.item['valueName']}');
    // print('options--------------${widget.getFormData}');
    // print('options--------------${widget.item}');
    setState(() {
      options.addAll(json.decode(json.encode(apioption)));
      toptions.addAll(json.decode(json.encode(apioption)));
      // print('...3432534${widget.item['value']}..');
    });
    widget.item['selected_sant'] = [];
    // thisloopistoselectwhenediting==========================================
    for (var i = 0; i < options.length; i++) {
      // var result = widget.item.firstWhereOrNull(
      //   (element) {
      //     print('oooooooooooooooooooooo423${element['value']}');
      //     return element['value'] == options[i]['value'];
      //   },
      // );
      // print('llllllllll44${result}');

      if (widget.item['value'].contains(options[i]['value'])) {
        setState(() {
          // print(
          //     'llllllllll...3432534${widget.item['value'].contains(options[i]['value'])}..');
          options[i]['selected'] = true;
          toptions[i]['selected'] = true;
          // if()
          // widget.item['value'].add(options[i]['value']);
          if (!widget.item['valueName'].contains(options[i]['title'])) {
            widget.item['valueName'].add(options[i]['title']);
            widget.item['selected_sant'].add({
              "title": options[i]['title'],
              "hindi_title": options[i]['data']['json']['hindi_title'],
              "diksha": options[i]['diksha'],
            });
            // print('llllllllll99${options[i]}');
          }
        });
      }
    }
    // for (var elements in options) {
    //   // print('ccas${elements}');
    //   if (elements['selected'] == true) {
    //     widget.item['value'].add(elements['value']);
    //     widget.item['valueName'].add(elements['title']);
    //   }
    // }
    widget.getFormData(widget.form);
    print('options--------------3${widget.item['valueName']}');

    // thisloopistoselectwhenediting==========================================

    print('ooooooactListooooooo}');
    // print('ooooooooooooooooooooooo${options}');
  }

  // addOptions() async {
  //   options = [];
  //   toptions = [];
  //   // print("options--------------");
  //   print('options--------------${widget.item}');
  //   print('options--------------${widget.form}');
  //   print('options--------------${widget.getFormData}');
  //   // print('options--------------${widget.item}');
  //   setState(() {
  //     options.addAll(json.decode(json.encode(widget.item['options'])));
  //     toptions.addAll(json.decode(json.encode(widget.item['options'])));
  //   });
  //   for (var i = 0; i < options.length; i++) {
  //     if (widget.item['value'].contains(options[i]['value'])) {
  //       setState(() {
  //         options[i]['selected'] = true;
  //         toptions[i]['selected'] = true;
  //       });
  //     }
  //   }
  //   print('oSS_VV_apiMSelectListooooooo}');
  //   // print('ooooooooooooooooooooooo${options}');
  // }

  void didUpdateWidget(oldwidget) {
    print('fapapappapdidUpdateWidgeta');
    // apiaddOptions();
    // print("new ${widget.item}");
    // print("old ${oldwidget.item}");
    // if (oldwidget.item['options'].length != widget.item['options'].length) {
    // addOptions();
    // }
  }

  final controller = ScrollController();
  TextEditingController ss_search = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // return Container();

    return Container(
      width: widget.item['width'],
      decoration:
          BoxDecoration(border: Border.all(color: const Color(0xffeeeeee))),
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.only(left: 8, top: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Checkbox(
              //     value: _allCheck,
              //     onChanged: (val) {
              //       setState(() {
              //         _allCheck = val!;
              //         if (_allCheck) {
              //           for (var i = 0; i < options.length; i++) {
              //             setState(() {
              //               options[i]['selected'] = true;
              //               toptions[i]['selected'] = true;
              //               widget.item['value'].add(options[i]['value']);

              //               widget.form['data'][widget.item['id']] =
              //                   widget.item['value'];
              //             });
              //           }
              //         } else {
              //           for (var i = 0; i < options.length; i++) {
              //             setState(() {
              //               options[i]['selected'] = false;
              //               toptions[i]['selected'] = false;

              //               widget.item['value'].remove(options[i]['value']);
              //               widget.form['data'][widget.item['id']] =
              //                   widget.item['value'];
              //             });
              //           }
              //         }
              //       });
              //     }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    '${widget.item['title']} (${widget.item['valueName'].length})'),
              ),

              Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 10),
                  child: Container(
                    // color: Colors.amber,
                    height: 30,
                    width: SizeConfig.blockSizeHorizontal! * 7,
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: apimselectlistSearchButtonColor),
                        onPressed: () async {
                          var searched_search_sant_vv = [];
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: SizeConfig.blockSizeVertical! * 80,
                                  width: SizeConfig.blockSizeHorizontal! * 50,
                                  child: StatefulBuilder(
                                    builder: (BuildContext context,
                                        void Function(void Function())
                                            setState) {
                                      return AlertDialog(
                                          title: Column(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text("Search Sant sati"),
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    height: SizeConfig
                                                            .blockSizeVertical! *
                                                        5,
                                                    width: SizeConfig
                                                            .blockSizeHorizontal! *
                                                        25,
                                                    child: TextField(
                                                      decoration:
                                                          InputDecoration(
                                                              fillColor:
                                                                  rsTextFillColor,
                                                              filled: true,
                                                              labelText:
                                                                  "Name or Diksha Sequance",
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .all(4),
                                                              enabledBorder:
                                                                  const OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              3)),
                                                                      borderSide:
                                                                          BorderSide(
                                                                        color: Color(
                                                                            0xffACACAC),
                                                                        style: BorderStyle
                                                                            .solid,
                                                                      )),
                                                              border:
                                                                  OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              7),
                                                                      borderSide:
                                                                          const BorderSide(
                                                                        color: Color(
                                                                            0xffACACAC),
                                                                        style: BorderStyle
                                                                            .solid,
                                                                      )),
                                                              hintText:
                                                                  "Name or Diksha Sequance"),
                                                      controller: ss_search,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    child: const Text("Search"),
                                                    onPressed: () async {
                                                      setState(() {
                                                        searchload = true;
                                                      });
                                                      searched_search_sant_vv =
                                                          await search_sant_vv();
                                                      setState(() {
                                                        searchload = false;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          actions: <Widget>[
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              icon: Icon(
                                                Icons.arrow_back,
                                                size: 22,
                                              ),
                                              label: Text("Back"),
                                            ),
                                          ],
                                          content: Container(
                                            height:
                                                SizeConfig.blockSizeVertical! *
                                                    50,
                                            width: SizeConfig
                                                    .blockSizeHorizontal! *
                                                25,
                                            child: Scrollbar(
                                              controller: ScrollController(),
                                              radius:
                                                  const Radius.circular(10.0),
                                              thumbVisibility: true,
                                              thickness: 7.0,
                                              child: !searchload
                                                  ? searched_search_sant_vv
                                                          .isNotEmpty
                                                      ? ListView.builder(
                                                          // controller: controller,
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              searched_search_sant_vv
                                                                  .length,
                                                          itemBuilder: (context,
                                                                  index) =>
                                                              CheckboxListTile(
                                                            value:
                                                                searched_search_sant_vv[
                                                                        index][
                                                                    'selected'],
                                                            title: Text(
                                                                '${searched_search_sant_vv[index]['title']}'),
                                                            controlAffinity:
                                                                ListTileControlAffinity
                                                                    .leading,
                                                            onChanged:
                                                                (isChecked) {
                                                              searched_search_sant_vv[
                                                                          index]
                                                                      [
                                                                      'selected'] =
                                                                  isChecked;
                                                              {
                                                                // print(
                                                                //     'oooooooooooooooooooooo${options.length}');
                                                                // print(
                                                                //     'oooooooooooooooooooooo${searched_search_sant_vv[index]['value']}');

                                                                var result = options
                                                                    .firstWhereOrNull(
                                                                        (element) {
                                                                  // print(
                                                                  //     'oooooooooooooooooooooo423${element['value']}');

                                                                  return element[
                                                                          'value'] ==
                                                                      searched_search_sant_vv[
                                                                              index]
                                                                          [
                                                                          'value'];
                                                                });
                                                                // print(
                                                                //     'oooooooooooooooooooooo1111${result}');

                                                                if (result ==
                                                                    null) {
                                                                  setState(() {
                                                                    options.add(
                                                                        searched_search_sant_vv[
                                                                            index]);
                                                                    toptions.add(
                                                                        searched_search_sant_vv[
                                                                            index]);
                                                                    // print(
                                                                    //     'oooooooooooooooooooooo${options.length}');
                                                                  });
                                                                }
                                                              }

                                                              {
                                                                // print(isChecked);
                                                                // print(itm['selected']);
                                                                setState(() {
                                                                  print(
                                                                      'erhbiiinnnnnnssseesesesesefz3423534${searched_search_sant_vv[index]}');
                                                                  searched_search_sant_vv[
                                                                              index]
                                                                          [
                                                                          'selected'] =
                                                                      isChecked;
                                                                  apioption[index]
                                                                          [
                                                                          'selected'] =
                                                                      isChecked;
                                                                  print(
                                                                      'erhbfz3423534${widget.item['value']}');

                                                                  if (isChecked!) {
                                                                    widget.item[
                                                                            'value']
                                                                        .add(searched_search_sant_vv[index]
                                                                            [
                                                                            'value']);
                                                                    widget.item[
                                                                            'valueName']
                                                                        .add(searched_search_sant_vv[index]
                                                                            [
                                                                            'title']);
                                                                    widget.item[
                                                                            'selected_sant']
                                                                        .add({
                                                                      "title": options[
                                                                              index]
                                                                          [
                                                                          'title'],
                                                                      "hindi_title":
                                                                          options[index]['data']['json']
                                                                              [
                                                                              'hindi_title'],
                                                                      "diksha":
                                                                          options[index]
                                                                              [
                                                                              'diksha'],
                                                                    });
                                                                  } else {
                                                                    widget.item[
                                                                            'value']
                                                                        .remove(searched_search_sant_vv[index]
                                                                            [
                                                                            'value']);
                                                                    widget.item[
                                                                            'valueName']
                                                                        .remove(searched_search_sant_vv[index]
                                                                            [
                                                                            'title']);
                                                                    widget.item['selected_sant'].removeWhere((element) =>
                                                                        element[
                                                                            'title'] ==
                                                                        options[index]
                                                                            [
                                                                            'title']);
                                                                  }
                                                                  widget.form[
                                                                      'data'][widget
                                                                          .item[
                                                                      'id']] = widget
                                                                          .item[
                                                                      'value'];
                                                                  // widget.form['data'][widget.item['id']]
                                                                  //     ['valueName'] = ['vdvdre'];
                                                                  // widget.item['valueName'].add(options[index]['title']);
                                                                });
                                                                widget.getFormData(
                                                                    widget
                                                                        .form);

                                                                print(
                                                                    'uuuuuuuuuuuuuu${widget.form}');
                                                              }
                                                            },
                                                          ),
                                                        )
                                                      : Center(
                                                          child: Text(
                                                            "Search For Sant Sati",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[300]),
                                                          ),
                                                        )
                                                  : Center(
                                                      child: Column(
                                                        children: [
                                                          LinearProgressIndicator(),
                                                          Text(
                                                            "Please Wait",
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        148,
                                                                        148,
                                                                        148)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                            ),
                                          ));
                                    },
                                  ),
                                );
                              });
                        },
                        icon: const Icon(
                          Icons.search,
                          // color: Colors.black,
                        ),
                        label: const Text(
                          'Search',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        )),
                  )),
            ],
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            width: widget.item['width'],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: widget.item['width'] - 100,
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Search ${widget.item['title']}"),
                    // controller: _searchCtrl,
                    onChanged: (value) {
                      print('uuuuuuuuuuuuuu${options.length}');

                      print(value);
                      setState(() {
                        options = [];
                        var tempD = toptions
                            .where((element) => element['title']
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                        // print(tempD);
                        options.addAll(tempD);
                      });
                    },
                  ),
                ),
                // IconButton(
                //     onPressed: () {
                //       setState(() {
                //         // _searchCtrl.clear();
                //         widget.item['options'] = toptions;
                //       });
                //     },
                //     icon: Icon(Icons.close))
              ],
            ),
          ),
          // Text(options.length.toString()),
          Container(
            height: widget.item['height'],
            width: widget.item['width'],
            child: Scrollbar(
              controller: ScrollController(),
              radius: const Radius.circular(10.0),
              thumbVisibility: true,
              thickness: 7.0,
              child: ListView.builder(
                controller: controller,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) => CheckboxListTile(
                  value: options[index]['selected'],
                  title: Text('${options[index]['title']}'),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) {
                    setState(() {
                      print('erhbfz3423534${options[index]}');
                      options[index]['selected'] = isChecked;
                      apioption[index]['selected'] = isChecked;

                      if (isChecked!) {
                        widget.item['value'].add(options[index]['value']);
                        widget.item['valueName'].add(options[index]['title']);
                        widget.item['selected_sant'].add({
                          "title": options[index]['title'],
                          "hindi_title": options[index]['data']['json']
                              ['hindi_title'],
                          "diksha": options[index]['diksha'],
                        });
                      } else {
                        widget.item['value'].remove(options[index]['value']);
                        widget.item['valueName']
                            .remove(options[index]['title']);
                        widget.item['selected_sant'].removeWhere((element) =>
                            element['title'] == options[index]['title']);
                      }
                      widget.form['data'][widget.item['id']] =
                          widget.item['value'];
                    });

                    widget.getFormData(widget.form);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectList extends StatefulWidget {
  final items;
  final label;
  final selectedItem;
  final width;
  final Function(String?)? onChanged;
  SelectList(
      {this.selectedItem,
      this.label,
      this.items,
      required this.onChanged,
      this.width});
  @override
  _SelectListState createState() => _SelectListState();
}

class _SelectListState extends State<SelectList> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 8.0, bottom: 8, left: 20, right: 20),
            child: Text(
              widget.label,
              style: labelTextStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              padding: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                border: Border.all(
                  color: rsTextBorderColor,
                  // width: 1,
                ),
                color: rsTextFillColor,
              ),
              height: SizeConfig.blockSizeVertical! * 3,
              width: widget.width,
              child: DropdownButton<String>(
                dropdownColor: Colors.white,
                value: widget.selectedItem,
                underline: Container(),
                isExpanded: true,
                hint: Text('${widget.label}'),
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: widget.onChanged,
                items: widget.items.map<DropdownMenuItem<String>>((element) {
                  return DropdownMenuItem(
                      value: element['value'].toString() as String,
                      child: Text(
                        "${element['title']}",
                        overflow: TextOverflow.ellipsis,
                      ));
                }).toList(),
              ),
            ),
          ),
        ]);
  }
}

class SearchItem extends StatefulWidget {
  final item;
  final getFormData;
  final form;
  SearchItem({this.item, this.form, this.getFormData});
  @override
  _SearchItemState createState() => _SearchItemState();
}

class _SearchItemState extends State<SearchItem> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 8.0, bottom: 8, left: 20, right: 20),
          child: Text(
            widget.item['title'],
            style: labelTextStyle,
          ),
        ),
        InkWell(
          onTap: () {
            print('p[p[p[pttttttttttttt[]p]]]');

            showSearch(
              context: context,
              delegate: widget.item['search_widget'],
              // delegate: CustomSearchDelegate(
              //     selectedItem: widget.item['fn']['fn'],
              //     queryTb: widget.item['tb']),
            );
          },
          child: SizedBox(
            width: widget.item['width'],
            // height: widget.item['height'],
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.search,
                      size: 34,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: rsTextFillColor,
                          // color: Color(0xffEBEBEB),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                              color: const Color(0xffACACAC),
                              style: BorderStyle.solid),
                        ),
                        width: widget.item['width'] - 70,
                        height: 30,
                        child: Text(
                          (widget.item['name'] != null)
                              ? "${widget.item['name']}"
                              : "${widget.item['title']}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                        )),
                  ),
                ]),
          ),
        ),
      ],
    );
  }
}

// class CustomSearchDelegate extends SearchDelegate {
//   final queryTb;
//   final selectedItem;
//   CustomSearchDelegate({this.selectedItem, this.queryTb});
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: const Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }
//
//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
//     if (query.length < 3) {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           const Center(
//             child: Text(
//               "Search term must be longer than two letters.",
//             ),
//           )
//         ],
//       );
//     }
//
//     return Consumer<ApiService>(
//       builder: (context, apiService, child) {
//         return FutureBuilder<dynamic>(
//           future: apiService.getSearchValue(query, queryTb),
//           builder: (context, snapshot) {
//             // print(snapshot.data);
//             if (snapshot.data == false)
//               return const Center(
//                 child: Card(
//                   child: Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Text("No Data Found"),
//                   ),
//                 ),
//               );
//             if (snapshot.hasData) {
//               print('snapshot.data------------');
//               // print(snapshot.data[0].attachment.type);
//               // print(snapshot.data[0].attachment.type.runtimeType);
//               var selDate = snapshot.data;
//               print("selDate[0]----------------------");
//               print(selDate[0]);
//               return ListView.separated(
//                 shrinkWrap: true,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: ListTile(
//                       onTap: () {
//                         selectedItem(selDate[index]);
//                         if (Navigator.canPop(context)) {
//                           Navigator.pop(context);
//                         }
//                       },
//                       leading: selDate[index]['json']['_im'] != null &&
//                               selDate[index]['json']['_im'] != ""
//                           ? CircleAvatar(
//                               // radius: 30,
//                               backgroundColor: Colors.blue[100],
//                               // backgroundColor: Colors.transparent,
//                               backgroundImage: NetworkImage(
//                                   "https://app.ratnasangh.com/uploads/users/${selDate[index]['json']['_im']}"),
//                             )
//                           : CircleAvatar(
//                               backgroundColor: Colors.blue[100],
//                               child: Text(
//                                   "${selDate[index]['json']['_fi_na']!.substring(0, 1)}"),
//                             ),
//                       title: Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: Text("${selDate[index]['json']['_fi_na']}",
//                             style: baseTextStyle.copyWith(
//                                 fontSize: 16, fontWeight: FontWeight.w600)),
//                       ),
//                       subtitle: Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: Text(selDate[index]['json']['_ph_nu'],
//                             style: baseTextStyle.copyWith(
//                                 color: Colors.grey[600],
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w400)),
//                       ),
//                       // Padding(
//                       //   padding: const EdgeInsets.all(4.0),
//                       //   child: Text(_executiveList[index].description,
//                       //       style: baseTextStyle),
//                       // )
//                     ),
//                   );
//                 },
//                 separatorBuilder: (context, index) => Container(
//                   height: 5,
//                 ),
//                 itemCount: selDate.length,
//               );
//             } else {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     // This method is called everytime the search term changes.
//     // If you want to add search suggestions as the user enters their search term, this is the place to do that.
//     return Column();
//   }
// }
//-----------------------------------------------------------------------///

class SearchableSelectList extends StatefulWidget {
  final items;
  final label;
  final bool showLabel;
  final selectedItem;
  final width;
  final Function(String?)? onChanged;
  SearchableSelectList(
      {this.selectedItem,
      this.label,
      this.showLabel = false,
      this.items,
      required this.onChanged,
      this.width});
  @override
  _SearchableSelectListState createState() => _SearchableSelectListState();
}

class _SearchableSelectListState extends State<SearchableSelectList> {
  @override
  Widget build(BuildContext context) {
    var options = [];
    options = widget.items;
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLabel)
            Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8, left: 20, right: 20),
              child: Text(
                widget.label,
                style: labelTextStyle,
              ),
            ),
          Container(
            color: rsTextFillColor,
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: SizedBox(
              height: 40,
              width: widget.width ?? MediaQuery.of(context).size.width * .85,
              child: DropdownSearch<List<String>>(

                  // showIcon: false,
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                  ),
                  // showSearchBox: true,
                  mode: Mode.form,
                  items: (filter, loadProps) {
                    return options.map((map) {
                      // print(map['title']);
                      return [map['title'].toString()];
                    }).toList();
                  },
                  selectedItem: widget.selectedItem,
                  decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                    hintText: widget.label,
                  )),
                  // hint: widget.label,

                  onChanged: (List<String>? value) {
                    if (value != null) {
                      widget.onChanged;
                    }
                  }),
            ),
          ),
        ]);
  }
}

class TextInput extends StatefulWidget {
  final label;
  final type;
  final maxLines;
  final controller;
  final secure;
  final showLabel;
  TextInput(
      {this.label,
      this.controller,
      this.secure = false,
      this.showLabel = true,
      this.maxLines = 1,
      this.type = 'text'});
  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLabel)
            Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8, left: 20, right: 20),
              child: Text(
                widget.label,
                style: labelTextStyle,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(

                // alignment: Alignment.centerLeft,
                // padding: EdgeInsets.all(8),
                height: widget.maxLines > 1 ? null : 40,
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty && value.length != 10) {
                      return "Can't be empty";
                    }
                    return null;
                  },
                  controller: widget.controller,
                  maxLines: widget.maxLines,
                  obscureText: widget.secure,
                  keyboardType: widget.maxLines > 1
                      ? TextInputType.multiline
                      : widget.type == 'num'
                          ? TextInputType.number
                          : TextInputType.text,
                  decoration: InputDecoration(
                    hintText: widget.label,
                    contentPadding: const EdgeInsets.all(4),
                    // border: OutlineInputBorder(),
                    fillColor: rsTextFillColor,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    // labelStyle: labelTextStyle,
                    // labelText: "Password",
                  ),
                  onChanged: (text) {
                    setState(() {});
                  },
                )),
          ),
        ]);
  }
}

class FormTextInput extends StatefulWidget {
  final label;
  final type;
  final maxLines;
  final controller;
  final secure;
  final showLabel;
  final onChanged;
  final height;
  final width;
  FormTextInput(
      {this.label,
      this.controller,
      this.secure = false,
      this.showLabel = true,
      this.maxLines = 1,
      this.onChanged,
      this.height,
      this.width,
      this.type = 'text'});
  @override
  _FormTextInputState createState() => _FormTextInputState();
}

class _FormTextInputState extends State<FormTextInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLabel)
            Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 8, left: 20, right: 20),
              child: Text(
                widget.label,
                style: labelTextStyle,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(

                // alignment: Alignment.centerLeft,
                // padding: EdgeInsets.all(8),
                height: widget.height,
                width: widget.width,
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty && value.length != 10) {
                      return "Can't be empty";
                    }
                    return null;
                  },
                  controller: widget.controller,
                  maxLines: widget.maxLines,
                  obscureText: widget.secure,
                  keyboardType: widget.maxLines > 1
                      ? TextInputType.multiline
                      : widget.type == 'num'
                          ? TextInputType.number
                          : TextInputType.text,
                  decoration: InputDecoration(
                    hintText: widget.label,
                    contentPadding: const EdgeInsets.all(4),
                    // border: OutlineInputBorder(),
                    fillColor: rsTextFillColor,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    // labelStyle: labelTextStyle,
                    // labelText: "Password",
                  ),
                  onChanged: widget.onChanged,
                )),
          ),
        ]);
  }
}

class DateInput extends StatefulWidget {
  final label;
  final controller;
  final showLabel;
  const DateInput({this.label, this.showLabel = true, this.controller});

  @override
  State<DateInput> createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel)
          Padding(
            padding:
                const EdgeInsets.only(top: 8.0, bottom: 8, left: 20, right: 20),
            child: Text(
              widget.label,
              style: labelTextStyle,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Container(

              // alignment: Alignment.centerLeft,
              // padding: EdgeInsets.all(8),
              height: 40,
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty && value.length != 10) {
                    return "Can't be empty";
                  }
                  return null;
                },
                controller: widget.controller,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(4),
                  hintText: widget.label,
                  // border: OutlineInputBorder(),
                  fillColor: rsTextFillColor,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  // labelStyle: labelTextStyle,
                  // labelText: "Password",
                ),
                onTap: () async {
                  DateTime date = DateTime(2000);
                  FocusScope.of(context).requestFocus(new FocusNode());
                  var initial_date = widget.controller.text != null &&
                          widget.controller.text.isNotEmpty
                      ? DateFormat('MM-dd-yyyy').parse(widget.controller.text)
                      : DateTime.now();
                  date = (await showDatePicker(
                      context: context,
                      initialDate: initial_date,
                      firstDate: DateTime(1920),
                      lastDate: DateTime(2100)))!;

                  widget.controller.text =
                      Functions.getFormattedDate(date, 'MM-dd-yyyy');
                  setState(() {});
                },
              )),
        ),
      ],
    );
  }
}

class DateTimeInput extends StatefulWidget {
  final label;
  final controller;
  final showLabel;
  const DateTimeInput({this.label, this.showLabel = true, this.controller});

  @override
  State<DateTimeInput> createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInput> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime dateTime = DateTime.now();
  bool showDate = false;
  bool showTime = false;
  bool showDateTime = false;

  // Select for Date
  Future<DateTime> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
    return selectedDate;
  }

// Select for Time
  Future<TimeOfDay> _selectTime(BuildContext context) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (selected != null && selected != selectedTime) {
      setState(() {
        selectedTime = selected;
      });
    }
    return selectedTime;
  }
  // select date time picker

  Future _selectDateTime(BuildContext context) async {
    final date = await _selectDate(context);
    if (date == null) return;

    final time = await _selectTime(context);

    if (time == null) return;
    setState(() {
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      widget.controller.text = dateTime.toString();
    });
    // print("SeleDat4eTime-------${dateTime.toString()}");
    // print("SeleDat4eTime-------${dateTime.toIso8601String()}");
    // print("SeleDat4eTime-------${dateTime.toLocal()}");
  }

//---------------------------------//
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel)
          Padding(
            padding:
                const EdgeInsets.only(top: 8.0, bottom: 8, left: 20, right: 20),
            child: Text(
              widget.label,
              style: labelTextStyle,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Container(

              // alignment: Alignment.centerLeft,
              // padding: EdgeInsets.all(8),
              height: 40,
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty && value.length != 10) {
                    return "Can't be empty";
                  }
                  return null;
                },
                controller: widget.controller,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(4),
                  hintText: widget.label,
                  // border: OutlineInputBorder(),
                  fillColor: rsTextFillColor,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  // labelStyle: labelTextStyle,
                  // labelText: "Password",
                ),
                onTap: () async {
                  _selectDateTime(context);
                  // DateTime date = DateTime(2000);
                  // FocusScope.of(context).requestFocus(new FocusNode());
                  // var initial_date = widget.controller.text != null &&
                  //         widget.controller.text.isNotEmpty
                  //     ? DateFormat('MM-dd-yyyy').parse(widget.controller.text)
                  //     : DateTime.now();
                  // date = (await showDatePicker(
                  //     context: context,
                  //     initialDate: initial_date,
                  //     firstDate: DateTime(1920),
                  //     lastDate: DateTime(2100)))!;
                },
              )),
        ),
      ],
    );
  }
}

class SwitchToggleButton extends StatelessWidget {
  final label;

  final selvalue;
  final width;
  final Function(bool?)? onChanged;
  SwitchToggleButton(
      {this.label, this.selvalue, this.width, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16),
          child: Switch(
            value: selvalue,
            onChanged: onChanged,
            activeTrackColor: const Color.fromARGB(126, 63, 116, 216),
            activeColor: const Color.fromARGB(255, 42, 20, 209),
          ),
        ),
        Container(
          width: width ?? SizeConfig.blockSizeHorizontal! * 70,
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16),
          child: Text(
            "$label",
            style: labelTextStyle,
          ),
        ),
      ],
    );
  }
}

class MultiSelectList extends StatelessWidget {
  final items;
  final label;
  final onChanged;
  const MultiSelectList({this.items, this.label, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 8.0, bottom: 8, left: 20, right: 20),
          child: Text(
            label,
            style: labelTextStyle,
          ),
        ),
        Container(
          child: GFMultiSelect(
            items: items,
            onSelect: onChanged,
            dropdownTitleTileText: label,
            dropdownTitleTileColor: Colors.grey[200],
            dropdownTitleTileMargin:
                const EdgeInsets.only(top: 22, left: 18, right: 18, bottom: 5),
            dropdownTitleTilePadding: const EdgeInsets.all(10),
            dropdownUnderlineBorder:
                const BorderSide(color: Colors.transparent, width: 2),
            dropdownTitleTileBorder:
                Border.all(color: Colors.grey[300]!, width: 1),
            dropdownTitleTileBorderRadius: BorderRadius.circular(5),
            expandedIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black54,
            ),
            collapsedIcon: const Icon(
              Icons.keyboard_arrow_up,
              color: Colors.black54,
            ),
            dropdownTitleTileTextStyle:
                const TextStyle(fontSize: 14, color: Colors.black54),
            padding: const EdgeInsets.all(6),
            margin: const EdgeInsets.all(6),
            type: GFCheckboxType.basic,
            activeBgColor: const Color.fromARGB(126, 64, 118, 255),
            inactiveBorderColor: const Color.fromARGB(255, 64, 166, 255),
          ),
        ),
      ],
    );
  }
}

class SearchableMultiSelectList extends StatelessWidget {
  final List<MultiSelectItem<dynamic>> items;
  final label;
  final onChanged;
  final onSelect;
  const SearchableMultiSelectList(
      {required this.items, this.label, this.onChanged, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 8.0, bottom: 8, left: 20, right: 20),
          child: Text(
            label,
            style: labelTextStyle,
          ),
        ),
        Container(
          child: MultiSelectDialogField(
            chipDisplay: MultiSelectChipDisplay(
              scroll: true,
            ),
            searchHint: "Search",
            onSelectionChanged: onSelect,
            searchable: true,
            items: items,
            title: Text("$label"),
            selectedColor: Colors.blue,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              border: Border.all(
                color: Colors.blue,
                width: 2,
              ),
            ),
            buttonIcon: const Icon(
              Icons.location_city,
              color: Colors.blue,
            ),
            buttonText: Text(
              "$label",
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 16,
              ),
            ),
            onConfirm: onChanged,
          ),
        ),
      ],
    );
  }
}
