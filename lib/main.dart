import 'package:flutter/material.dart';
import 'package:amityhack/pages/send_data_page.dart';
import 'package:amityhack/pages/address_page.dart'; // Make sure to import this
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _startingPage;

  @override
  void initState() {
    super.initState();
    _fetchStartingPage();
  }

  _fetchStartingPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? serverAddress = prefs.getString('server_address');

    setState(() {
      if (serverAddress == null || serverAddress.isEmpty) {
        _startingPage = AddressInputScreen();
      } else {
        _startingPage = SendDataPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boson',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
          ),
        ),
      ),
      home: _startingPage ??
          CircularProgressIndicator(), // Show a loader while we determine the starting page
    );
  }
}
