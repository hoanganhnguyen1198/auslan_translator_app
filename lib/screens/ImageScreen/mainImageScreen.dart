import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:sizer/sizer.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  File? _image;
  final picker = ImagePicker();
  late Interpreter _interpreter;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _predictImage(_image!);
      });
    }
  }

  Future<void> getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _predictImage(_image!);
      });
    }
  }

  Future<void> _predictImage(File imageFile) async {
    try {
      // Load and preprocess the image
      final image = await _loadImage(imageFile);
      final input = imageToByteListFloat32(
          image, 224, 224); // Adjust size as per model input
      final output =
          List.filled(1 * 1000, 0).reshape([1, 1000]); // Adjust output size

      _interpreter.run(input, output);

      // Process results
      setState(() {
        _result = 'Prediction: ${output[0]}'; // Process output as needed
      });
    } catch (e) {
      print("Error during prediction: $e");
    }
  }

  Future<Uint8List> _loadImage(File file) async {
    // Load image file into Uint8List
    final data = await file.readAsBytes();
    return data;
  }

  Future<List> imageToByteListFloat32(
      Uint8List image, int width, int height) async {
    final input =
        List.filled(width * height * 3, 0.0).reshape([height, width, 3]);

    // Convert image to byte list
    // Implementation depends on your image format and preprocessing needs
    // You can use image package to convert image to raw bytes

    return input;
  }

  Future<void> showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _image != null
            ? Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 50.h,
                      width: 50.w,
                      child: _image == null
                          ? const Text('No Image selected')
                          : Image.file(_image!),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _result,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(35),
                    child: Text(
                      'Translate Auslan gestures into text instantly.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                    width: 80.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                          height: 1.2,
                          fontFamily: 'Dubai',
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: getImageFromGallery,
                      child: const Text('Upload from Gallery'),
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Container(
                    width: 80.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                          height: 1.2,
                          fontFamily: 'Dubai',
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: getImageFromCamera,
                      child: const Text('Take Photo'),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
      ),
    );
  }
}
