import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:key_master/Components/credential_card.dart';
import 'package:key_master/Components/my_app_bar.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CredentialsPage extends StatefulWidget {
  final String title;
  const CredentialsPage(this.title, {super.key});

  @override
  State<CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends State<CredentialsPage> {
  final storage = FlutterSecureStorage();
  List<String> _usernames = [];
  Map<String, String>? _allCredential;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _searchQuery = '';

  // Key to save the order for this category
  String get _orderKey => 'order_${widget.title}';

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
          constraints: const BoxConstraints(maxWidth: 400),
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

  // Modified getUserNameList to load and apply saved ordering.
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

      // Retrieve saved order from SharedPreferences (if it exists)
      final prefs = await SharedPreferences.getInstance();
      List<String>? savedOrder = prefs.getStringList(_orderKey);

      if (savedOrder != null) {
        // Build a new list by preserving the saved order.
        List<String> orderedUsernames = [];
        for (String username in savedOrder) {
          if (usernames.contains(username)) {
            orderedUsernames.add(username);
          }
        }
        // Append any usernames not in the saved order (new items)
        for (String username in usernames) {
          if (!orderedUsernames.contains(username)) {
            orderedUsernames.add(username);
          }
        }
        usernames = orderedUsernames;
      }

      setState(() {
        _usernames = usernames;
      });
    } catch (e) {
      print('Error loading usernames: $e');
    }
  }

  List<String> get _filteredUsernames {
    if (_searchQuery.isEmpty) return _usernames;
    return _usernames
        .where((username) =>
            username.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: widget.title),
      body: Column(
        children: [
          // Material themed search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search credentials...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchQuery.isEmpty
                ? ReorderableListView(
                    onReorder: (int oldIndex, int newIndex) async {
                      if (newIndex > oldIndex) newIndex--;
                      setState(() {
                        final item = _usernames.removeAt(oldIndex);
                        _usernames.insert(newIndex, item);
                      });
                      // Save the new order in SharedPreferences so it persists.
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setStringList(_orderKey, _usernames);
                    },
                    children: [
                      for (int index = 0; index < _usernames.length; index++)
                        CredentialCard(
                          key: ValueKey(_usernames[index]),
                          username: _usernames[index],
                          onTap: () {
                            setState(() => _isAuthenticating = true);
                            onTap(context, _usernames[index]);
                            setState(() => _isAuthenticating = false);
                          },
                          onIconTap: () {},
                        ),
                    ],
                  )
                : ListView.builder(
                    itemCount: _filteredUsernames.length,
                    itemBuilder: (context, index) {
                      final username = _filteredUsernames[index];
                      return CredentialCard(
                        key: ValueKey(username),
                        username: username,
                        onTap: () {
                          onTap(context, username);
                        },
                        onIconTap: () {},
                      );
                    },
                  ),
          ),
          if (_isAuthenticating)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
