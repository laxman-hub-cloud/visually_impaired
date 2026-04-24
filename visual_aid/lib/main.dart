import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

String backendUrl = "http://172.26.176.215:5000 ";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Volunteer App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: VolunteerScreen(),
    );
  }
}

class VolunteerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Visual Aid App')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                _speak("Entered visual assistance page");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisualAssistancePage(),
                  ),
                );
              },
              child: Container(
                color: Colors.lightBlue.shade500,
                child: Center(
                  child: Text(
                    'Do you need visual assistance?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VolunteerPage()),
                );
              },
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Text(
                    'Volunteer Page.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VisualAssistancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Visual Assistance Page')),
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _speak(
                  "tap on the upper half for image processing and tap on the below half for video processing",
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageAndVideoProcessing(),
                  ),
                );
              },
              child: Container(
                color: Colors.lightBlue,
                child: Center(
                  child: Text(
                    'Image and Video Processor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                _speak("now you can call your volunteer");
              },
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Text(
                    'Call My Volunteer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageAndVideoProcessing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Image And Video processing ",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                _speak("Capturing Image");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImageUploadScreen()),
                );
              },
              child: Container(
                color: Colors.lightBlue,
                child: Center(
                  child: Text(
                    'Image Processor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                _speak("Entered into Live Video Processing");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoProcessingPage(),
                  ),
                );
              },
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Text(
                    'Video Processor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VolunteerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Volunteer Page')),
      body: LoadConversations(), // 👈 directly load conversations
    );
  }
}

// -------------------------------
class LoadConversations extends StatefulWidget {
  @override
  _LoadConversationsState createState() => _LoadConversationsState();
}

class _LoadConversationsState extends State<LoadConversations> {
  Future<List<dynamic>> fetchConversations() async {
    final response = await http.get(Uri.parse('${backendUrl}/conversations'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchConversations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return Center(child: Text('No conversations found'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final chat = data[index];
              final caption = chat['caption'];
              final imageBase64 = chat['image_file'];
              final imageBytes = base64Decode(imageBase64);

              return ListTile(
                contentPadding: EdgeInsets.all(8.0),
                title: Text(caption ?? 'No Caption'),
                subtitle: SizedBox(
                  height: 350,
                  child: Image.memory(imageBytes, fit: BoxFit.cover),
                ),
              );
            },
          );
        }
      },
    );
  }
}

// -----------------------------------

FlutterTts flutterTts = FlutterTts();

Future<void> _speak(String text) async {
  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(1.0);
  await flutterTts.setSpeechRate(0.5);
  await flutterTts.speak(text);
}

bool checkHazardous(String s) {
  List<String> words = ["knife", "fire", "water", "flames", "couch", "pillow"];
  String text = s.toLowerCase();
  bool found = words.any((word) => text.contains(word));
  return found;
}

final AudioPlayer _audioPlayer = AudioPlayer();
bool _isAlarmPlaying = false;

Future<void> playAlarm() async {
  if (_isAlarmPlaying) return;

  _isAlarmPlaying = true;

  try {
    await _audioPlayer.play(AssetSource('sound/Alarm.mp3'));
  } catch (e) {
    debugPrint("Audio error: $e");
  }

  await Future.delayed(Duration(seconds: 3));
  _isAlarmPlaying = false;
}

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  String _responseMessage = '';

  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCamera();
    });
  }

  // 🔥 Initialize Camera
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();

      _controller = CameraController(
        _cameras![0], // Back camera
        ResolutionPreset.medium,
      );

      await _controller!.initialize();

      // ⏱ Auto capture after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        _captureAndUpload();
      });
    } catch (e) {
      _showSnackbar("Camera init failed: $e");
    }
  }

  // 📸 Auto Capture
  Future<void> _captureAndUpload() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing)
      return;

    _isCapturing = true;

    try {
      final XFile file = await _controller!.takePicture();

      setState(() {
        _image = File(file.path);
      });

      await _uploadImage();
    } catch (e) {
      _showSnackbar("Capture failed: $e");
    }
  }

  // 🌐 Upload (your same logic)
  Future<void> _uploadImage() async {
    if (_image == null) {
      _showSnackbar('No image found');
      return;
    }

    var url = '${backendUrl}/caption';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();

        setState(() {
          _responseMessage = responseBody;
          _speak(_responseMessage);
        });

        if (checkHazardous(responseBody)) {
          await playAlarm();
        }

        _showSnackbar('Image uploaded successfully :)');
      } else {
        _showSnackbar('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // 🚫 UI NOT CHANGED (as requested)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Processing')),
      body: InkWell(
        onTap: () {}, // disabled manual trigger
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image == null
                      ? Text(
                          'No image selected',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        )
                      : Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: Image.file(_image!, fit: BoxFit.contain),
                        ),
                  SizedBox(height: 20),
                  Container(
                    width: 300,
                    child: Text(
                      _responseMessage,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoProcessingPage extends StatefulWidget {
  @override
  _VideoProcessingPageState createState() => _VideoProcessingPageState();
}

class _VideoProcessingPageState extends State<VideoProcessingPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  Timer? _timer;
  bool _isProcessing = false;

  String _responseMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCamera();
    });
  }

  // 🔥 Initialize Camera
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();

      _controller = CameraController(
        _cameras![0], // back camera
        ResolutionPreset.medium,
      );

      await _controller!.initialize();

      // Start live processing
      _startFrameProcessing();

      setState(() {});
    } catch (e) {
      print("Camera init error: $e");
    }
  }

  // 🔁 Capture frame every 10 seconds
  void _startFrameProcessing() {
    _timer = Timer.periodic(Duration(seconds: 6), (timer) async {
      if (_isProcessing || !_controller!.value.isInitialized) return;

      _isProcessing = true;

      try {
        final XFile file = await _controller!.takePicture();
        await _sendFrameToBackend(File(file.path));
      } catch (e) {
        print("Capture error: $e");
      }

      _isProcessing = false;
    });
  }

  // 🌐 Send frame to backend
  Future<void> _sendFrameToBackend(File imageFile) async {
    var url = '${backendUrl}/caption'; // same as image API

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();

        setState(() {
          _responseMessage = responseBody;
          _speak(_responseMessage);
        });

        // Optional: reuse your hazard logic
        if (checkHazardous(responseBody)) {
          await playAlarm();
        }
      }
    } catch (e) {
      print("Upload error: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  // 🎥 UI (replaced video player with camera preview)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Video Processing')),
      body: _controller == null || !_controller!.value.isInitialized
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(_controller!), // live feed

                Positioned(
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    color: Colors.black54,
                    child: Text(
                      _responseMessage,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
