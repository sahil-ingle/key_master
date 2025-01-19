import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<Map<String, String>> _credentials = [];

  @override
  void initState() {
    super.initState();
    _loadCredentials(); // Load credentials when the widget is initialized
  }

  Future<void> _loadCredentials() async {
    _credentials = await getListOfMaps();
    setState(() {});
  }

  Future<List<Map<String, String>>> getListOfMaps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('myListOfMapsKey');

    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString); // Decode the JSON string
      return jsonList
          .map((item) => Map<String, String>.from(item))
          .toList(); // Convert each item to Map<String, String>
    } else {
      return []; // Return an empty list if there is no saved data
    }
  }

  Future<void> _addCredentials() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    setState(() {
      _credentials.add({
        'email': _emailController.text,
        'password': _passwordController.text,
      });
    });

    await saveListOfMaps(_credentials); // Save the updated list

    _emailController.clear();
    _passwordController.clear();
    Navigator.of(context).pop();
  }

  Future<void> saveListOfMaps(List<Map<String, String>> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString =
        jsonEncode(list); // Convert the list of maps to a JSON string
    await prefs.setString('myListOfMapsKey', jsonString);
  }

  void _showAddCredentialsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Credentials',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addCredentials,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCredentialDetails(String email, String password) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Credentials',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text('Email: $email'),
                SizedBox(height: 8),
                Text('Password: $password'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteCredential(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this credential?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _credentials.removeAt(index);
                });
                await saveListOfMaps(
                    _credentials); // Update the saved list after deletion
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: _credentials.isEmpty
          ? Center(child: Text('Press the button to add credentials'))
          : ListView.builder(
              itemCount: _credentials.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(_credentials[index]['email']!),
                    onTap: () => _showCredentialDetails(
                      _credentials[index]['email']!,
                      _credentials[index]['password']!,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteCredential(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCredentialsDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
