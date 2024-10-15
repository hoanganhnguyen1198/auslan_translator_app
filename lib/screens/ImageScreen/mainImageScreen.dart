import 'dart:io';
import 'dart:typed_data';
import 'package:csit998_capstone_g16/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:video_player/video_player.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  File? _image;
  File? _video;
  VideoPlayerController? _videoController;
  final picker = ImagePicker();
  late Interpreter _interpreter;
  late Interpreter _videoInterpreter;
  String _result = '';
  List<bool> _isSelected = [true, false]; // Initial state for ToggleButtons
  String _modelPath =
      'assets/tensorflowModel/asl_words_model.tflite'; // Default model path
  String _videoModelPath =
      'assets/tensorflowModel/video_model.tflite'; // Default video model path

  @override
  void initState() {
    super.initState();
    _loadModel(); // Load the initial model
  }

  Future<void> _loadModel() async {
    try {
      final options = InterpreterOptions();
      _interpreter = await Interpreter.fromAsset(_modelPath, options: options);
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> _loadVideoModel() async {
    try {
      final options = InterpreterOptions();
      _videoInterpreter =
          await Interpreter.fromAsset(_videoModelPath, options: options);
    } catch (e) {
      print("Error loading video model: $e");
    }
  }

  Future<void> getImageFromGallery() async {
    Navigator.pop(context);
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        if (_isSelected[0]) {
          _predictImage(_image!); // Call the prediction function for Model 1
        } else {
          _predictNewModel(_image!); // Call the prediction function for Model 2
        }
      });
    }
  }

  Future<void> getImageFromCamera() async {
    Navigator.pop(context);
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        if (_isSelected[0]) {
          _predictImage(_image!); // Call the prediction function for Model 1
        } else {
          _predictNewModel(_image!); // Call the prediction function for Model 2
        }
      });
    }
  }

  // Future<void> getImageFromGallery() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //       _predictImage(_image!);
  //     });
  //   }
  // }

  // Future<void> getImageFromCamera() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //       _predictImage(_image!);
  //     });
  //   }
  // }

  Future<void> getVideoFromGallery() async {
    Navigator.pop(context);
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
        _videoController = VideoPlayerController.file(_video!)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.play();
          });
        _predictVideo(_video!);
      });
    }
  }

  Future<void> getVideoFromCamera() async {
    Navigator.pop(context);
    final pickedFile = await picker.pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
        _videoController = VideoPlayerController.file(_video!)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.play();
          });
        _predictVideo(_video!);
      });
    }
  }

  Future<void> _predictImage(File imageFile) async {
    try {
      final image = await _loadImage(imageFile);
      final input = imageToByteListFloat32(image, 224, 224);

      final inputTensor = input.reshape([1, 224, 224, 3]);
      final output = List.filled(29, 0.0).reshape([1, 29]);
      _interpreter.run(inputTensor, output);

      final outputList = output[0] as List<double>;
      final maxIndex =
          outputList.indexOf(outputList.reduce((a, b) => a > b ? a : b));

      final labels = [
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L',
        'M',
        'N',
        'O',
        'P',
        'Q',
        'R',
        'S',
        'T',
        'U',
        'V',
        'W',
        'X',
        'Y',
        'Z',
        'del',
        'Nothing',
        'space'
      ];
      final predictedLabel = labels[maxIndex];
      setState(() {
        _result = 'Prediction: $predictedLabel';
      });
    } catch (e) {
      print("Error during prediction: $e");
    }
  }

  Future<void> _predictNewModel(File imageFile) async {
    try {
      // Load the image and preprocess it into a tensor input
      final image = await _loadImage(imageFile);
      final input = imageToByteListFloat32(image, 224, 224);

      // Reshape the input tensor to match the new model's input size
      final inputTensor = input.reshape([1, 224, 224, 3]);

      // Prepare the output tensor with the correct shape and size (16 labels)
      final output = List.filled(16, 0.0).reshape([1, 16]);

      // Run the model inference
      _interpreter.run(inputTensor, output);

      // Extract the output as a list of probabilities
      final outputList = output[0] as List<double>;

      // Get the index of the maximum probability
      final maxIndex =
          outputList.indexOf(outputList.reduce((a, b) => a > b ? a : b));

      // Define the new set of labels
      final labels = [
        'r',
        'u',
        'g',
        's',
        'a',
        'f',
        'o',
        'd',
        'v',
        'x',
        'e',
        'b',
        'k',
        'l',
        'y',
        'w'
      ];

      // Get the predicted label
      final predictedLabel = labels[maxIndex];

      // Update the result on the UI
      setState(() {
        _result = 'Prediction: $predictedLabel';
      });
    } catch (e) {
      print("Error during prediction: $e");
    }
  }

  Future<void> _predictVideo(File videoFile) async {
    // Implement video prediction logic here
    print("Processing video: ${videoFile.path}");
    // Use _videoInterpreter to make predictions
  }

  Future<Uint8List> _loadImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      print("Image loaded successfully. Byte length: ${bytes.length}");
      return bytes;
    } catch (e) {
      print("Error loading image: $e");
      rethrow;
    }
  }

  Float32List imageToByteListFloat32(Uint8List image, int width, int height) {
    final imgImage = img.decodeImage(image)!;
    final resizedImage = img.copyResize(imgImage, width: width, height: height);

    final input =
        Float32List(1 * width * height * 3); // (1, width, height, channels)

    int index = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = resizedImage.getPixel(x, y);
        final r = (img.getRed(pixel) - 127.5) / 127.5; // Normalize to [-1, 1]
        final g = (img.getGreen(pixel) - 127.5) / 127.5;
        final b = (img.getBlue(pixel) - 127.5) / 127.5;

        input[index++] = r;
        input[index++] = g;
        input[index++] = b;
      }
    }

    return input;
  }

  void captureFromCamera(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: bgColor,
          title: const Text(
            'Choose an option',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  child: const Text('Capture Image'),
                ),
              ),
              SizedBox(
                height: 10,
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
                  onPressed: getVideoFromCamera,
                  child: const Text('Capture Video'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void uploadFromGallery(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: bgColor,
          title: const Text(
            'Choose an option',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  child: const Text('Upload Image'),
                ),
              ),
              SizedBox(
                height: 10,
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
                  onPressed: getVideoFromGallery,
                  child: const Text('Upload Video'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Top button with two options
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ToggleButtons(
                  isSelected: _isSelected,
                  onPressed: (int index) {
                    setState(() {
                      for (int i = 0; i < _isSelected.length; i++) {
                        _isSelected[i] =
                            i == index; // Ensure only one is selected at a time
                      }
                      // Switch the model based on the selected option
                      if (_isSelected[0]) {
                        _modelPath =
                            'assets/tensorflowModel/asl_words_model.tflite'; // Default model
                        _videoModelPath =
                            'assets/tensorflowModel/video_model.tflite'; // Video model
                        _loadModel();
                      } else {
                        _modelPath =
                            'assets/tensorflowModel/auslan_alphabet_model.tflite'; // New model
                        _videoModelPath =
                            'assets/tensorflowModel/new_video_model.tflite'; // New video model
                        _loadModel();
                        _loadVideoModel(); // Load the video model as well
                      }
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('ASL'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('AUSLAN'),
                    ),
                  ],
                ),
              ),

              if (_image != null)
                SingleChildScrollView(
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
                      const SizedBox(height: 20),
                      Text(
                        _result,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else if (_video != null)
                Column(
                  children: [
                    _videoController != null
                        ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                        : const Text('No video selected'),
                    const SizedBox(height: 20),
                    Text(
                      _result,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              else
                Column(
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
                    const SizedBox(height: 50),
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
                        onPressed: () {
                          uploadFromGallery(
                              context); // Use a closure to pass context
                        },
                        child: const Text('Upload from Gallery'),
                      ),
                    ),
                    const SizedBox(height: 30),
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
                        onPressed: () {
                          captureFromCamera(context);
                        },
                        child: const Text('Capture Video'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
