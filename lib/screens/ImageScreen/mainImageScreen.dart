import 'dart:io';
import 'dart:typed_data';
import 'package:csit998_capstone_g16/utils/colors.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
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
  late int frameCount;
  late Duration frameInterval;
  String displayText = "Translate Asl gestures into text instantly.";
  VideoPlayerController? _videoController;
  final ImagePicker picker = ImagePicker();
  late Interpreter _interpreter;
  late Interpreter? _videoInterpreter; // Change to nullable
  String _result = '';
  List<bool> _isSelected = [true, false]; // Initial state for ToggleButtons
  String _modelPath =
      'assets/tensorflowModel/asl_alphabet_model.tflite'; // Default model path
  String _videoModelPath =
      'assets/tensorflowModel/asl_words_model.tflite'; // Default video model path

  @override
  void initState() {
    super.initState();
    print("Initializing models...");
    _loadModel().then((_) {
      print("Main model loaded.");
      _loadVideoModel().then((_) {
        print("Video model loading complete.");
      });
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();

    super.dispose();
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
    print('Loading video model...');
    try {
      final options = InterpreterOptions();
      _videoInterpreter =
          await Interpreter.fromAsset(_videoModelPath, options: options);
      print('Video model loaded successfully.');
    } catch (e) {
      print("Error loading video model: $e");
      _videoInterpreter = null; // Set to null in case of failure
    }
  }

  Future<void> getImageFromGallery() async {
    Navigator.pop(context);
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        if (_isSelected[0]) {
          _predictASLModel(_image!); // Call the prediction function for Model 1
        } else {
          _predictAUSLANModel(
              _image!); // Call the prediction function for Model 2
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
          _predictASLModel(_image!); // Call the prediction function for Model 1
        } else {
          _predictAUSLANModel(
              _image!); // Call the prediction function for Model 2
        }
      });
    }
  }

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
        if (_isSelected[0]) {
          _predictASLModelFromVideo(
              _video!); // Call the prediction function for Model 1
        } else {
          _predictAUSLANModelFromVideo(
              _video!); // Call the prediction function for Model 2
        }
      });
    }
  }

  Future<void> getVideoFromCamera() async {
    Navigator.pop(context); // Close the overlay if applicable.

    try {
      final pickedFile = await picker.pickVideo(source: ImageSource.camera);

      if (pickedFile != null) {
        _video = File(pickedFile.path);

        // Initialize video player
        _videoController = VideoPlayerController.file(_video!)
          ..initialize().then((_) {
            setState(() {
              _videoController!.play(); // Autoplay video after picking
            });
          });
        if (_isSelected[0]) {
          _predictASLModelFromVideo(
              _video!); // Call the prediction function for Model 1
        } else {
          _predictAUSLANModelFromVideo(
              _video!); // Call the prediction function for Model 2
        }
      }
    } catch (e) {
      print('Error picking video: $e');
    }
  }

  Future<void> _predictASLModel(File imageFile) async {
    try {
      // Load the image and preprocess it into a tensor input
      final image = await _loadImage(imageFile);
      final input = imageToByteListFloat32(image, 224, 224);

      // Reshape the input tensor to match the model's input size
      final inputTensor = input.reshape([1, 224, 224, 3]);

      // Prepare the output tensor with the correct shape and size (29 labels)
      final output = List.filled(29, 0.0).reshape([1, 29]);

      // Run the model inference
      _interpreter.run(inputTensor, output);

      // Extract the output as a list of probabilities
      final outputList = output[0] as List<double>;

      // Get the index of the maximum probability
      final maxIndex =
          outputList.indexOf(outputList.reduce((a, b) => a > b ? a : b));

      // Define the set of labels (29 labels)
      final labels = [
        'space',
        'N',
        'C',
        'O',
        'del',
        'Z',
        'H',
        'U',
        'X',
        'S',
        'G',
        'L',
        'E',
        'M',
        'P',
        'J',
        'W',
        'R',
        'Y',
        'Q',
        'V',
        'I',
        'B',
        'K',
        'nothing',
        'F',
        'A',
        'T',
        'D'
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

  Future<void> _predictAUSLANModel(File imageFile) async {
    try {
      // Load the image and preprocess it into a tensor input
      final image = await _loadImage(imageFile);
      final input = imageToByteListFloat32(image, 224, 224);

      // Reshape the input tensor to match the new model's input size
      final inputTensor = input.reshape([1, 224, 224, 3]);

      // Prepare the output tensor with the correct shape and size (assumed 22 labels here)
      final output = List.filled(22, 0.0).reshape([1, 22]);

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
        'i',
        'n',
        'g',
        't',
        's',
        'a',
        'f',
        'o',
        'm',
        'c',
        'd',
        'v',
        'x',
        'e',
        'b',
        'k',
        'l',
        'y',
        'p',
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

  Future<void> _predictModelFromVideo(
      File videoFile, List<String> labels, int labelCount) async {
    try {
      print('Starting prediction...');

      // Load video and extract frames
      await _loadVideo(videoFile);

      // Prepare the output tensor
      final output = List.filled(labelCount, 0.0).reshape([1, labelCount]);
      final List<List<double>> allFrameOutputs = [];

      // Extract and process frames
      for (int i = 0; i < frameCount; i++) {
        // Seek to the specific frame
        await _videoController?.seekTo(frameInterval * i);
        await Future.delayed(
            const Duration(milliseconds: 100)); // Allow time for the seek

        // Extract the frame and check for success
        final Uint8List frameData = await _extractFrame(videoFile, i);

        if (frameData.isNotEmpty) {
          // Preprocess frame and run the interpreter
          final frameDataProcessed = _preprocessFrame(frameData);

          if (frameDataProcessed.isNotEmpty) {
            _videoInterpreter?.run(frameDataProcessed, output);
            allFrameOutputs.add(List<double>.from(output[0]));
          } else {
            print("Processed frame data is empty for frame $i.");
          }
        } else {
          print("Frame data is empty for frame $i.");
        }
      }

      // Check if frames were processed
      if (allFrameOutputs.isNotEmpty) {
        // Average the probabilities across all frames
        final averagedOutput = List<double>.generate(labelCount, (i) => 0.0);
        for (var frameOutput in allFrameOutputs) {
          for (var i = 0; i < labelCount; i++) {
            averagedOutput[i] += frameOutput[i];
          }
        }
        for (var i = 0; i < labelCount; i++) {
          averagedOutput[i] /= allFrameOutputs.length;
        }

        // Get the label with the maximum probability
        final maxIndex = averagedOutput
            .indexOf(averagedOutput.reduce((a, b) => a > b ? a : b));
        final predictedLabel = labels[maxIndex];

        setState(() {
          _result = 'Prediction: $predictedLabel';
        });
      } else {
        print("No valid frame outputs for prediction.");
      }
    } catch (e) {
      print("Error during prediction: $e");
    }
  }

  Future<void> _predictASLModelFromVideo(File videoFile) async {
    final labels = [
      'thank you',
      'goodbye',
      'sorry',
      'hello',
      'no',
      'help',
      'yes'
    ];
    await _predictModelFromVideo(videoFile, labels, labels.length);
  }

  Future<void> _predictAUSLANModelFromVideo(File videoFile) async {
    final labels = [
      'egg',
      'use',
      'do',
      'jay',
      'tools',
      'tool',
      'pattern',
      'wool',
      'map',
      'wood'
    ];
    await _predictModelFromVideo(videoFile, labels, labels.length);
  }

// Helper function to load the video and extract frames
  Future<void> _loadVideo(File videoFile) async {
    _videoController = VideoPlayerController.file(videoFile);
    await _videoController?.initialize();

    // Video duration and frame interval for extraction
    final duration = _videoController?.value.duration;
    frameInterval =
        Duration(milliseconds: 500); // Extract frames every 0.5 seconds
    frameCount =
        (duration!.inMilliseconds / frameInterval.inMilliseconds).ceil();
  }

// Extract a frame using FFmpeg
  Future<Uint8List> _extractFrame(File videoFile, int frameIndex) async {
    print('Extracting frame $frameIndex from video ${videoFile.path}');

    final tempDir = Directory.systemTemp;
    String outputPath = '${tempDir.path}/frame-$frameIndex.png';

    String command =
        "-i ${videoFile.path} -ss ${frameInterval.inSeconds * frameIndex} -vframes 1 -an $outputPath";
    print('Executing FFmpeg command: $command');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('Frame extracted successfully: $outputPath');
      Uint8List frameBytes = await File(outputPath).readAsBytes();
      await File(outputPath).delete(); // Clean up the temporary file
      return frameBytes;
    } else {
      print("Failed to extract frame: Return code: $returnCode");
      print(await session.getOutput());
      return Uint8List(0); // Return empty bytes on failure
    }
  }

// Preprocess the frame to fit the model's input requirements
  Uint8List _preprocessFrame(Uint8List frameData) {
    img.Image? originalImage = img.decodeImage(frameData);

    if (originalImage == null) {
      throw Exception("Error decoding the frame.");
    }

    img.Image resizedImage =
        img.copyResize(originalImage, width: 224, height: 224);
    Uint8List inputImage = _imageToByteListUint8(resizedImage, 224);

    return inputImage;
  }

// Converts an image to Uint8List format (RGB)
  Uint8List _imageToByteListUint8(img.Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = ByteData.view(convertedBytes.buffer);

    int pixelIndex = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        int pixel = image.getPixel(x, y);
        buffer.setUint8(pixelIndex++, img.getRed(pixel));
        buffer.setUint8(pixelIndex++, img.getGreen(pixel));
        buffer.setUint8(pixelIndex++, img.getBlue(pixel));
      }
    }

    return convertedBytes;
  }

  // Future<Uint8List> _loadVideo(File videoFile) async {
  //   // Load the video file as bytes
  //   final Uint8List videoBytes = await videoFile.readAsBytes();

  //   return videoBytes; // Return the video bytes directly
  // }

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
                        displayText =
                            "Translate Asl gestures into text instantly.";
                        _modelPath =
                            'assets/tensorflowModel/asl_alphabet_model.tflite'; // Default model
                        _videoModelPath =
                            'assets/tensorflowModel/asl_words_model.tflite'; // Video model
                        _loadModel();
                        _loadVideoModel(); // Load the video model as well
                      } else {
                        displayText =
                            "Translate Auslan gestures into text instantly.";
                        _modelPath =
                            'assets/tensorflowModel/auslan_alphabet_model.tflite'; // New model
                        _videoModelPath =
                            'assets/tensorflowModel/auslan_test.tflite'; // New video model
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
                          child: Image.file(_image!),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else if (_video != null)
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _videoController != null
                          ? Column(
                              children: [
                                AspectRatio(
                                  aspectRatio:
                                      16 / 9, // Adjust aspect ratio as needed
                                  child: VideoPlayer(_videoController!),
                                ),
                                VideoProgressIndicator(
                                  _videoController!,
                                  allowScrubbing: true,
                                ),
                                IconButton(
                                  icon: Icon(
                                    _videoController!.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _videoController!.value.isPlaying
                                          ? _videoController!.pause()
                                          : _videoController!.play();
                                    });
                                  },
                                ),
                              ],
                            )
                          : const Text('No video selected'),
                      const SizedBox(height: 20),
                      Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(35),
                      child: Text(
                        displayText,
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
                        child: const Text('Capture from Camera'),
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
