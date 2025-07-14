import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR App',
      theme: ThemeData.dark(),
      home: const OcrHomePage(),
    );
  }
}

class OcrHomePage extends StatefulWidget {
  const OcrHomePage({super.key});
  @override
  State<OcrHomePage> createState() => _OcrHomePageState();
}

class _OcrHomePageState extends State<OcrHomePage> {
  File? _image;
  String _recognizedText = 'Henüz bir metin algılanmadı.';

  Future<void> _pickImage(ImageSource source) async {
    PermissionStatus status;

    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      if (Platform.isAndroid) {
        if (await Permission.photos.request().isGranted ||
            await Permission.storage.request().isGranted) {
          status = PermissionStatus.granted;
        } else {
          status = PermissionStatus.denied;
        }
      } else {
        status = await Permission.photos.request();
      }
    }

    if (!status.isGranted) {
      print('İzin reddedildi');
      return;
    }

    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    setState(() => _image = File(pickedFile.path));

    final inputImage = InputImage.fromFile(_image!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    setState(() {
      _recognizedText = recognizedText.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Görselden Yazı Okuma')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : const Placeholder(fallbackHeight: 200),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Text('Galeriden Seç'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: const Text('Kamera ile Çek'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(_recognizedText, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
