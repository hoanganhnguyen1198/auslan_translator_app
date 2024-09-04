import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

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
      final options = InterpreterOptions();

      // Example of adding a delegate, if needed:
      // options.addDelegate(GpuDelegate());

      _interpreter = await Interpreter.fromAsset(
        'assets/tensorflowModel/model.tflite',
        options: options,
      );
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

        // Debugging: Print file path and check if file exists
        print("Image file path: ${_image!.path}");
        if (File(_image!.path).existsSync()) {
          print("Image file exists.");
          _predictImage(_image!);
        } else {
          print("Image file does not exist.");
        }
      });
    } else {
      print("No image selected.");
    }
  }

  Future<void> _predictImage(File imageFile) async {
    try {
      final image = await _loadImage(imageFile);
      final input = imageToByteListFloat32(
          image, 224, 224); // Adjust size as per model input

      // Reshape input to [1, height, width, channels]
      final inputTensor = input.reshape([1, 224, 224, 3]);

      // Define output tensor with the correct shape
      final output = List.filled(1 * 29, 0.0)
          .reshape([1, 29]); // Adjust output size to match the model's output

      print(output);

      // Run the model
      _interpreter.run(inputTensor, output);
      print(output);
      setState(() {
        _result = 'Prediction: ${output[0]}'; // Process output as needed
      });
    } catch (e) {
      print("Error during prediction: $e");
    }
  }

  Future<Uint8List> _loadImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      print("Image loaded successfully. Byte length: ${bytes.length}");
      return bytes;
    } catch (e) {
      print("Error loading image: $e");
      rethrow; // Re-throw the exception to handle it elsewhere if needed
    }
  }

  Float32List imageToByteListFloat32(Uint8List image, int width, int height) {
    final imgImage = img.decodeImage(image)!;
    final resizedImage = img.copyResize(imgImage, width: width, height: height);

    final input =
        Float32List(1 * height * width * 3); // Ensure this is Float32List

    int index = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = resizedImage.getPixel(x, y);
        final r = (img.getRed(pixel) / 255.0).toDouble();
        final g = (img.getGreen(pixel) / 255.0).toDouble();
        final b = (img.getBlue(pixel) / 255.0).toDouble();

        input[index++] = r;
        input[index++] = g;
        input[index++] = b;
      }
    }

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
            ? SingleChildScrollView(
                // Add scroll functionality
                child: Column(
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
