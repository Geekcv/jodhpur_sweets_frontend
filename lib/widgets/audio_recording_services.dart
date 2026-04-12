// import 'dart:math';
// import 'package:flutter/widgets.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart';

// class AudioRecordingService {
//   // Singleton pattern implementation
//   static final AudioRecordingService _instance =
//       AudioRecordingService._internal(null);
//   factory AudioRecordingService() => _instance;
//   AudioRecordingService._internal(this._recorder);

//   AudioRecorder? _recorder;
//   bool _isInitialized = false;
//   bool _isRecording = false;
//   String? _recordedFilePath;

//   // Initialize the recorder
//   Future<void> initRecorder() async {
//     if (_isInitialized) return;
//     if (_recorder != null) {
//       await _recorder!.dispose();
//     }
//     // Request microphone permissions
//     var status = await Permission.microphone.request();
//     // if (!status.isGranted) {
//     //   throw 'Microphone permission not granted';
//     // }

//     _recorder = AudioRecorder();

//     _isInitialized = true;
//   }

//   String _generateRandomId() {
//     const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
//     final random = Random();
//     return List.generate(
//       10,
//       (index) => chars[random.nextInt(chars.length)],
//       growable: false,
//     ).join();
//   }

//   // Start recording
//   Future<void> startRecording() async {
//     if (!_isInitialized) {
//       throw 'Recorder not initialized';
//     }
//     if (_isRecording) return;

//     try {
//       debugPrint(
//           '=========>>>>>>>>>>> RECORDING!!!!!!!!!!!!!!! <<<<<<===========');

//       String filePath = await getApplicationDocumentsDirectory()
//           .then((value) => '${value.path}/${_generateRandomId()}.wav');

//       await _recorder!.start(
//         const RecordConfig(
//           encoder: AudioEncoder.wav,
//         ),
//         path: filePath,
//       );
//       _recordedFilePath = filePath;
//       _isRecording = true;
//       // print('Recording started: $filePath');
//     } catch (e) {
//       debugPrint('ERROR WHILE RECORDING: $e');
//     }
//   }

//   // Stop recording
//   Future stopRecording() async {
//     if (!_isRecording) return;

//     String? path = await _recorder!.stop();
//     _isRecording = false;
//     // print('Recording stopped: $path');
//     // await dispose();
//     return path;
//   }

//   // Dispose of the recorder
//   Future<void> dispose() async {
//     // print("dispose recorder");
//     await _recorder!.dispose();

//     await _recorder!.cancel();
//     if (_isInitialized) {
//       await _recorder!.cancel();
//       _isInitialized = false;
//     }
//   }
// }
