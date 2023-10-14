import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amityhack/pages/send_data_page.dart';

class AddressInputScreen extends StatefulWidget {
  @override
  _AddressInputScreenState createState() => _AddressInputScreenState();
}

class _AddressInputScreenState extends State<AddressInputScreen> {
  TextEditingController _addressController = TextEditingController();
  String? _errorMessage;

  Future<void> _checkAndSaveAddress() async {
    final address = _addressController.text;

    try {
      final response = await http.get(Uri.parse(
          "http://$address:5000/compress")); // assuming you have a /health endpoint
      print(response.statusCode);
      if (response.statusCode == 400 || response.statusCode == 405) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('server_address', address);
        setState(() {
          _errorMessage = null;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SendDataPage()), // Navigate to the MembershipPage
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server address saved!'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Server not found!';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error: ${error.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Enter Server Address',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Server Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Colors.white), // Rounded corners
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: Colors.white), // Rounded corners
                  ),
                  errorText: _errorMessage,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkAndSaveAddress,
                child: Text(
                  'Check',
                  style: TextStyle(
                    fontSize: 20, // Bigger text
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0), // Rounded button
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
