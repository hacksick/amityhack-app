import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:math';
import 'package:amityhack/pages/address_page.dart'; // Make sure to import this
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// ... Other imports ...
import 'dart:io';

Future<void> removeAddress() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("server_address");
}

Future<String> getAddress() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("server_address")!;
}

class SendDataPage extends StatefulWidget {
  @override
  _SendDataPageState createState() => _SendDataPageState();
}

class _SendDataPageState extends State<SendDataPage> {
  File? _file;
  int? compressedSize;

  // ... All your methods and functions here like pickFile, uploadFile, etc...
  Future<void> pickFile(FileType fileType) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: fileType);

    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    } else {
      print('User canceled the picker');
    }
  }

  Future<void> uploadFile() async {
    if (_file == null) return;
    String server_address = await getAddress();
    var uri = Uri.parse("http://$server_address:5000/compress");
    var request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile(
            'file', _file!.readAsBytes().asStream(), _file!.lengthSync(),
            filename: _file!.path.split('/').last),
      );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = json.decode(responseData);
        setState(() {
          compressedSize = data['compressed_size'];
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('File uploaded!')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed!')));
        Navigator.pop(context); // Pop the current screen if an API error occurs
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('API error')));
      removeAddress();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AddressInputScreen()), // Navigate to the MembershipPage
      ); // Pop the current screen if an exception is thrown
    }
  }

  // Function to convert byte size to human-readable format
  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (log(bytes) / log(1024)).floor();
    return "${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}";
  }

  Widget buildGridButton(String label, FileType fileType) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: () => pickFile(fileType),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boson', style: TextStyle(fontSize: 30)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  buildGridButton('Photos', FileType.image),
                  buildGridButton('Videos', FileType.video),
                  buildGridButton('Audio', FileType.any),
                  buildGridButton('Others', FileType.any),
                ],
              ),
            ),
            // ... inside your Column widget
            if (_file != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 20.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original Size: ${formatBytes(_file!.lengthSync(), 2)}',
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    if (compressedSize != null)
                      Text(
                        'Compressed Size: ${formatBytes(compressedSize!, 2)}',
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
// ...

            FloatingActionButton(
              onPressed: uploadFile,
              child: Icon(Icons.upload_file),
              backgroundColor: Colors.blue,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

Future<void> pickAndCompressFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result != null) {
    File file = File(result.files.single.path!);
    // Basic compression using GZip
    List<int> compressedData = GZipCodec().encode(file.readAsBytesSync());
    // Send to server with metadata
    await sendToServer(compressedData, {'type': result.files.single.extension});
  } else {
    print('User canceled the picker');
  }
}

Future<void> sendToServer(List<int> data, Map<String, dynamic> metadata) async {
  var uri = Uri.parse("http://localhost:5000/compress");
  var request = http.MultipartRequest('POST', uri)
    ..files.add(
        http.MultipartFile.fromBytes('file', data, filename: "compressedFile"))
    ..fields.addAll(metadata.map((key, value) =>
        MapEntry(key, value.toString()))); // Convert all values to String

  var response = await request.send();
  if (response.statusCode == 200) {
    // Handle further compressed data if necessary
  } else {
    print('Upload failed');
  }
}
