import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('myBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  String _imageBase64 = '';
  bool _isDataSaved = false;

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }




  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      List<int> imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(imageBytes);
      });
    } else {
      _showSnackbar("No image selected", Colors.red);
    }
  }

  void _removeImage() {
    setState(() {
      _imageBase64 = '';
    });
    _showSnackbar("Image removed", Colors.red);
  }

  Future<void> _saveData() async {
    if (_textController.text.isEmpty) {
      _showSnackbar("Please enter text.", Colors.red);
      return;
    }

    if ( _imageBase64.isEmpty) {
      _showSnackbar("select an image.", Colors.red);
      return;
    }

    var box = await Hive.openBox('myBox');
    await box.put('textData', _textController.text);
    await box.put('imageData', _imageBase64);

    setState(() {
      _isDataSaved = true;
    });

    _showSnackbar("Data saved locally", Colors.green);
  }

  Future<void> _sendDataToServer() async {
    var box = await Hive.openBox('myBox');
    var textData = box.get('textData', defaultValue: '');
    var imageData = box.get('imageData', defaultValue: '');

    if (textData.isEmpty || imageData.isEmpty) {
      _showSnackbar("No data available to send.", Colors.red);
      return;
    }

_showSnackbar("Data send to live server", Colors.green);
//  _showSnackbar("Data pushed successfully", Colors.green);
      await box.clear(); // Clear Hive data after successful push
      setState(() {
        _isDataSaved = false;
        _textController.clear();
        _imageBase64 = '';
      });
// clear hive data

    


  //   var url = Uri.parse('https://yourserver.com/endpoint');
  //   var response = await http.post(
  //     url,
  //     body: json.encode({
  //       'textData': textData,
  //       'imageData': imageData,
  //     }),
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     _showSnackbar("Data pushed successfully", Colors.green);
  //   } else {
  //     _showSnackbar("Failed to push data: Status Code - \${response.statusCode}", Colors.red);
  //   }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
    
      appBar: AppBar(title: Text("Demo"),
      centerTitle: true,
      backgroundColor: Colors.blueAccent,),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Enter Text',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            if (_imageBase64.isNotEmpty)
              Column(
                children: [
                  Image.memory(
                    base64Decode(_imageBase64),
                    height: 150,
                  ),
                  TextButton(
                    onPressed: _removeImage,
                    child: Text("Remove Image", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Pick Image"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveData,
              child: Text("Save Data"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 16),
            if (_isDataSaved)
              ElevatedButton(
                onPressed: _sendDataToServer,
                child: Text("Push to Server"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}












