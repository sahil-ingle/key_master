import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:key_master/Components/credential_card.dart';
import 'package:key_master/Components/my_app_bar.dart';
import 'package:local_auth/local_auth.dart';

class CredentialsPage extends StatefulWidget {
  final String title;
  const CredentialsPage(this.title, {super.key});

  @override
  State<CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends State<CredentialsPage> {
  final storage = FlutterSecureStorage();
  // ignore: unused_field
  List<String> _usernames = [];
  Map<String, String>? _allCredential;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserNameList(widget.title);
    });
  }

  void onTap(context, String userName) async {
    try {
      // Check if biometric authentication is available
      final bool canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        _showCredentialsDirectly(userName);
        return;
      }

      // Perform authentication
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to view credentials',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _showCredentialsDirectly(userName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed')),
        );
      }
    } catch (e) {
      print('Authentication error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showCredentialsDirectly(String userName) async {
    String? email;
    String? password;

    String? storedData = await storage.read(key: userName);
    if (storedData != null) {
      _allCredential = Map<String, String>.from(jsonDecode(storedData));
      email = _allCredential?['email'];
      password = _allCredential?['password'];
    }

    showDialogBox(userName, email, password);
  }

  void showDialogBox(String userName, String? email, String? password) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your Credentials",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              size: 20, color: Colors.grey.shade600),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(Icons.person_outline, "Username", userName),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                        Icons.email_outlined, "Email", email ?? 'N/A'),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                        Icons.lock_outline, "Password", password ?? 'N/A'),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void getUserNameList(String categoryName) async {
    try {
      Map<String, String> allData = await storage.readAll();
      List<String> usernames = [];

      for (String key in allData.keys) {
        String? jsonString = allData[key];
        if (jsonString != null) {
          Map<String, dynamic> credentials = jsonDecode(jsonString);
          if (credentials.containsKey('userName') &&
              credentials['category'] == categoryName) {
            usernames.add(credentials['userName']);
          }
        }
      }

      setState(() {
        _usernames = usernames;
      });
    } catch (e) {
      // Handle errors (e.g., log or show a message)
      print('Error loading usernames: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: widget.title),
      body: _isAuthenticating
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _usernames.length,
              itemBuilder: (context, index) {
                return CredentialCard(
                  username: _usernames[index],
                  onTap: () {
                    setState(() => _isAuthenticating = true);
                    onTap(context, _usernames[index]);
                    setState(() => _isAuthenticating = false);
                  },
                  onIconTap: () {},
                );
              },
            ),
    );
  }
}
