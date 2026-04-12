// ignore_for_file: unnecessary_null_comparison, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, avoid_print, non_constant_identifier_names, unnecessary_new, unnecessary_brace_in_string_interps, prefer_null_aware_operators, no_leading_underscores_for_local_identifiers, prefer_adjacent_string_concatenation

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:js_order_website/utilities/utils.dart';
// import 'package:universal_io/io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../config/config.dart';

import 'package:location/location.dart';
import 'package:intl/intl.dart';

class Functions {
  // Future<void> writeToDownloads(String fileName, String data) async {
  //   try {
  //     // Get the path to the Downloads directory
  //     final directory = await getExternalStorageDirectory();
  //     final downloadsPath = directory?.parent.path + '/Download';

  //     // Define the path for the file
  //     final path = '$downloadsPath/$fileName';

  //     // Create or overwrite the file
  //     final file = File(path);
  //     await file.writeAsString(data);

  //   // print('File saved at $path');
  //   } catch (e) {
  //   // print('Error writing file: $e');
  //   }
  // }

  static chooseFileUsingFilePicker(token) async {
    PlatformFile? objFile;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowCompression: true,
        // compressionQuality: 50,
        // // type: FileType.custom,
        allowMultiple: true,
        // withReadStream: true,
        withData: true,
        withReadStream: true
        // type: FileType.any,
        );
    // print('file picker data=================$result');
    if (result != null) {
      objFile = result.files.single;
      // print('**==$objFile');
      var res = (await uploadSelectedFile(
        objFile: objFile,
        token: token,
      ));
      // print("upload file chooseFileUsingFilePicker=====${res}==========");
      // print(res);
      return res;
    }
  }

  static chooseFile() async {
    var result = await FilePicker.platform.pickFiles(
      // allowMultiple: true,
      // allowCompression: true,
      withReadStream:
          true, // this will return PlatformFile object with read stream
    );
    // print("rsult.files====${result}");
    if (result != null) {
      // print("result=============${result.files.length}");
      return result.files;
    } else {
      return null;
    }
  }

  static captureImage() async {
    var pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 25)
        .then((pickedFile) => pickedFile != null ? pickedFile.path : null);
    if (pickedImage != null) {
      File image = File(pickedImage);
      return image;
    }
  }

  static captureMultiImage() async {
    var pickedImage = await ImagePicker()
        .pickMultiImage(imageQuality: 25)
        .then((pickedFile) => pickedFile);
    // print("pickedimage==============$pickedImage");
    if (pickedImage != null) {
      var allPickedImg = [];
      for (var i = 0; i < pickedImage.length; i++) {
        File image = File(pickedImage[i].path);
        allPickedImg.add(image);
      }
      return allPickedImg;
    }
    return null;
  }

  static uploadMultipleFiles(files) async {
    var url = serverUrl + '/common/uploads/';
    final request = MultipartRequest(
      "POST",
      Uri.parse(url),
    );

    for (var i = 0; i < files.length; i++) {
      File objFile = files[i];
      request.files.add(MultipartFile(
          "files", objFile.readAsBytes().asStream(), objFile.lengthSync(),
          filename: objFile.path.split("/").last));
    }
    var resp = await request.send();
    String result = await resp.stream.bytesToString();
    // print('request-----resp-----------${result}');

    return json.decode(result);
  }

  static uploadSelectedObjFile(objFile) async {
    var url = serverUrl + 'common/upload/';
    final request = MultipartRequest(
      "POST",
      Uri.parse(url),
    );

    // request.fields["id"] = Utilities().getRandomString(4);
    // var he = {"Authorization": "Bearer ${await ApiController.getUserToken()}"};
    // request.headers.addEntries(he.entries);
    request.files.add(MultipartFile("file", objFile.readStream, objFile.size,
        filename: objFile.name));
    var resp = await request.send();
    String result = await resp.stream.bytesToString();
    // print('request-----resp-----------${result}');

    return json.decode(result);
  }

  static pickAndUploadFiles() async {
    var result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;
    var file = result.files.first;
    // printfile);
  }

  static pickAndUploadVideo() async {
    var result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4'],
        allowCompression: true,
        // withData: true,
        withReadStream: true,
        onFileLoading: (status) {
          //print"loading");
        },
        allowMultiple: true);
    //print"result");
    //printresult);
    // print(result!.files);
    if (result == null) return;
    var file = result.files;
    return file;
    // printfile);
  }

  static getFormattedDate(date, format) {
    // print('rrunntyty${date}----${format}');
    // if (date is String) print('rrunnty-------ty${DateTime.parse(date)}');
    var now = DateTime.parse(date.toString()).toLocal();
    var formatter = new DateFormat(format);
    String formattedDate = formatter.format(now);
    // print("formattedDate-------------");
    // print(formattedDate);
    return formattedDate;
  }

  static calculateDistance(
      {required targetLatController,
      required targetLonController,
      required radius}) async {
    // print('--ttarr${targetLatController}'
    //     '--ttarr${targetLonController}');
//////////////////////Add-on Functions
    double _deg2rad(double deg) {
      return deg * (pi / 180);
    }

    double calculateDistance(
        double lat1, double lon1, double lat2, double lon2) {
      const R = 6371; // Radius of the Earth in kilometers
      double dLat = _deg2rad(lat2 - lat1);
      double dLon = _deg2rad(lon2 - lon1);
      double a = sin(dLat / 2) * sin(dLat / 2) +
          cos(_deg2rad(lat1)) *
              cos(_deg2rad(lat2)) *
              sin(dLon / 2) *
              sin(dLon / 2);
      double c = 2 * atan2(sqrt(a), sqrt(1 - a));
      double distance = R * c; // Distance in kilometers
      return distance;
    }

    checkIfWithinRadius({
      required double userLat,
      required double userLon,
      required double targetLat,
      required double targetLon,
      required double radius,
    }) {
      double distance =
          calculateDistance(userLat, userLon, targetLat, targetLon);
      double distanceOutside = distance - radius;
      // print('zzzzzzzzzz${distance}');
      if (distance <= radius) {
        return {
          'inRadius': true,
          'distance': distanceOutside.toStringAsFixed(2),
          'messege': 'The location is within the radius.'
        };
      } else {
        return {
          'inRadius': false,
          'distance': distanceOutside.toStringAsFixed(2),
          'messege':
              'The location is outside the radius by ${distanceOutside.toStringAsFixed(2)} kilometers.'
        };
      }
    }
//////////////////////Add-on Functions

    try {
      Location location = Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _locationData = await location.getLocation();

      double userLat = _locationData.latitude ?? 0.0;
      double userLon = _locationData.longitude ?? 0.0;

      double targetLat = double.tryParse(targetLatController.toString()) ?? 0.0;
      double targetLon = double.tryParse(targetLonController.toString()) ?? 0.0;

      var return_messege = checkIfWithinRadius(
        userLat: userLat,
        userLon: userLon,
        targetLat: targetLat,
        targetLon: targetLon,
        radius: double.parse(radius.toString()),
      );
      // print('////////////////////5555$return_messege');

      return {
        "user_location": {
          "latitude": userLat,
          "longitude": userLon,
        },
        "distance": return_messege['distance']
      };
    } catch (e) {
      Exception(e);
      // print('////////////////////$e');
      // return e;
    }
  }

  static encodeData(data) {
    var stringData = json.encode(data);
    return base64.encode(utf8.encode(stringData));
  }

  static decodeData(data) {
    // print("data-=---------------------$data");
    var decodedData = json.decode((utf8.decode(base64.decode(data))));
    return decodedData;
  }

  static httpPostToken({data, token}) async {
    var url = '$serverUrl';
    // print("url in httpPost: $url");
    // print("token in httpPost: $token");
    // print("data in httpPost: $data");
    // print("url in httpPostUrl: $url");
    try {
      var response = await post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        // body: {"payload": json.encode(data)},
        body: {"payload": data},
        // encoding: Encoding.getByName("utf-8"));
        // ).timeout(const Duration(seconds: 60));
      );
      // print("api response status code: ${response.body}");
      // print("api response status code: ${response}");
      // var resp = json.decode(response.body);
      // print("httpPostUrl response==================");
      print(response);
      return response.body;
    } catch (e) {
      // print("Error occurred: $e");
    }
  }


  // static httpPostToken(encodedData,token,[String? endpoint]) async {
  //   var url = endpoint != null ? "$serverUrl" + "$endpoint" : "$serverUrl";
  //   // var url = "$serverUrl";
  //
  //   print("url-------$url");
  //
  //   HttpClient httpClient = new HttpClient();
  //   // httpClient.badCertificateCallback =
  //   //     (X509Certificate cert, String host, int port) => true;
  //   try {
  //     // print("encodedData-------ssssss${decodeData(encodedData)}");
  //
  //     HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  //     request.headers.set('content-type', 'application/json');
  //     request.headers.set('Authorization', 'Bearer $token');
  //
  //     // print("token-------${token}");
  //     // print("url-------${request.headers}");
  //
  //     request.add(utf8.encode(json.encode({"payload": encodedData})));
  //
  //     HttpClientResponse response = await request.close();
  //
  //     // var response = await post(Uri.parse(url), headers: {
  //     //   "Accept": "application/json",
  //     //   "Content-Type": "application/x-www-form-urlencoded"
  //     // }, body: {
  //     //   "payload": data
  //     // });va
  //
  //     var resp = await response.transform(utf8.decoder).join();
  //     // print("encodedData----rrrrrrrr${decodeData(resp)}");
  //
  //     return resp;
  //   } catch (ex) {
  //     // print("encodedData----cctttt${ex}");
  //
  //     // print("Exception------40");
  //     // print(ex);
  //     // Future.delayed(Duration(seconds: 2), () {
  //     // httpPost(data);
  //     // });
  //   }
  // }



  static httpPost({data, endPoint}) async {
    var url = '$serverUrl/$endPoint';
    // print("url in httpPostUrl: $url");
    try {
      var response = await post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        // body: {"payload": json.encode(data)},
        body: {"payload": data},
        // encoding: Encoding.getByName("utf-8"));
      );
      // print("api response status code: ${response.body}");
      // print("api response status code: ${response}");
      // var resp = json.decode(response.body);
      // print("httpPostUrl response==================");
      // print(resp);
      return response.body;
    } catch (e) {
      // print("Error occurred: $e");
    }
  }

  // static httpPost(encodedData, String endpoint) async {
  //   var url = "$serverUrl/$endpoint";
  //   // var url = "$serverUrl/common/create-user/";
  //   print("url-------$url");
  //
  //   HttpClient httpClient = new HttpClient();
  //   // httpClient.badCertificateCallback =
  //   //     (X509Certificate cert, String host, int port) => true;
  //   try {
  //     // print("url-------$url");
  //     // print("url-------$encodedData");
  //     // print("url-----67676767--${response.statusCode}");
  //
  //     HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  //     request.headers.set('content-type', 'application/json');
  //     // print("url-------$encodedData");
  //
  //     request.add(utf8.encode(json.encode({"payload": encodedData})));
  //
  //     HttpClientResponse response = await request.close();
  //
  //     // var response = await post(Uri.parse(url), headers: {
  //     //   "Accept": "application/json",
  //     //   "Content-Type": "application/x-www-form-urlencoded"
  //     // }, body: {
  //     //   "payload": data
  //     // });
  //     // print("url-----67676767--${response.statusCode}");
  //     return await response.transform(utf8.decoder).join();
  //   } catch (ex) {
  //     // print("Exception454444444444444----${ex}--40");
  //     // print(ex);
  //     // Future.delayed(Duration(seconds: 2), () {
  //     // httpPost(data);
  //     // });
  //   }
  // }



  static httpPostwithOneParameter(data) async {
    var url = serverUrl + '/common/';
    print("hhhhhhhhhhhhhhhhhhhhhhhhhh546--------$url");
    // var url = 'http://192.168.29.98:8000/common/';
    // print(data);
    var response = await post(Uri.parse(url), headers: {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded"
    }, body: {
      "payload": data
    }
      // encoding: Encoding.getByName("utf-8"));
    );
    // print('httpPosthttpPosthttpPosthttpPosthttpPosthttpPosthttpPost');
    // print('response---------');
    // print(response.statusCode);
    // print(response.body);
    // print(decodeData(response.body));
    return response.body;
  }

  static httpPostURL({raw_url, required encodedData}) async {
    // print("url-------$url");

    HttpClient httpClient = new HttpClient();
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    try {
      HttpClientRequest request = await httpClient.postUrl(Uri.parse(raw_url));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode({"payload": encodedData})));
      HttpClientResponse response = await request.close();

      // var response = await post(Uri.parse(url), headers: {
      //   "Accept": "application/json",
      //   "Content-Type": "application/x-www-form-urlencoded"
      // }, body: {
      //   "payload": data
      // });
      // print(
      //     "rrwrwrwrwrwrwrwxxxxxxxxxxx-----${await response.transform(utf8.decoder).join()}");

      return await response.transform(utf8.decoder).join();
    } catch (ex) {
      // print("Exception------");
      // print(ex);
      // Future.delayed(Duration(seconds: 2), () {
      // httpPost(data);
      // });
    }
  }

  /// Upload Select file to server
  chooseFileUsingFilePicker_({required context, required token}) async {
    Future<String?> showCustomBottomSheet(
        {required BuildContext context, required token}) async {
      return await Navigator.of(context).push(
        PageRouteBuilder<String>(
          opaque: false,
          barrierDismissible: true,
          pageBuilder: (context, animation, secondaryAnimation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1), // Start from bottom
                end: Offset.zero, // Slide to original position
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut, // Smoother animation curve
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    // height: 200,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 236, 236, 236),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.camera_alt),
                          title: Text('Camera'),
                          onTap: () {
                            Navigator.pop(context, 'camera');
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.photo_library),
                          title: Text('Gallery/File Manager'),
                          onTap: () {
                            Navigator.pop(context, 'gallery');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          transitionDuration:
              Duration(milliseconds: 600), // Slower animation duration
        ),
      );
    }

    PlatformFile? objFile;
    final ImagePicker _imagePicker = ImagePicker();

    // Show dialog to choose between camera or gallery/file manager
    String? source = await showCustomBottomSheet(
        context: context, token: token); // A method to display the dialog

    if (source == 'camera') {
      // Capture image using the camera
      final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera, imageQuality: 25);
      if (image != null) {
        objFile = PlatformFile(
            readStream: image.openRead(),
            name: image.name,
            path: image.path,
            size: await image.length());
        // print('Selected from camera: ${objFile.runtimeType}----------');

        var res =
            await Functions.uploadSelectedFile(token: token, objFile: objFile);

        // print('Selected from camera: $res');
        return res;
      }
    } else if (source == 'gallery') {
      // Select image from file manager/gallery
      var result = await FilePicker.platform.pickFiles(
        compressionQuality: 25,
        type: FileType.image,
        allowMultiple: false,
        withReadStream: true,
      );
      if (result != null) {
        objFile = result.files.single;
        var res =
            await Functions.uploadSelectedFile(objFile: objFile, token: token);

        // print('Selected from gallery: $res');
        return res;
      }
    }

    return null; // Return null if no file is picked
  }

  static uploadSelectedFile({required objFile, required token}) async {
    // var url = 'https://demo3.ftisindia.com/upload/';
    // var url = 'http://192.168.29.98:5000/upload/';
    var url = serverUrl + "/uploads";
    final request = MultipartRequest(
      "POST",
      Uri.parse(url),
    );
    request.fields["id"] = Utilities().getRandomString(4);

    request.files.add(MultipartFile("file", objFile.readStream, objFile.size,
        filename: objFile.name));
    request.headers.addAll({'Authorization': 'Bearer $token'});
    // print('fffffffffffffff request.headersfffffffffff${request.headers}');

    // request.headers = 'Authorization', 'Bearer $token';
    //  ('Authorization', 'Bearer $token');
    var resp = await request.send();
    String result = await resp.stream.bytesToString();

    var response = json.decode(result);

    // print('ffffffffffffffffffffffffff${response}');

    response['rsp']['data']['filesInfo'][0]['name'] = objFile.name;
    return response;
  }
}
