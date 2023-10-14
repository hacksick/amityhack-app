import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

Future<void> compressFile(File file) async {
  var uri = Uri.parse("http://localhost:5000/compress");
  var request = http.MultipartRequest('POST', uri)
    ..files.add(
      http.MultipartFile(
          'file', file.readAsBytes().asStream(), file.lengthSync(),
          filename: basename(file.path)),
    );

  var response = await request.send();

  if (response.statusCode == 200) {
    // Handle response
  } else {
    // Handle error
  }
}

Future<void> decompressFile(File file) async {
  var uri = Uri.parse("http://localhost:5000/decompress");
  var request = http.MultipartRequest('POST', uri)
    ..files.add(
      http.MultipartFile(
          'file', file.readAsBytes().asStream(), file.lengthSync(),
          filename: basename(file.path)),
    );

  var response = await request.send();

  if (response.statusCode == 200) {
    // Handle response
  } else {
    // Handle error
  }
}
