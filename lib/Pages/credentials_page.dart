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
  Map<String, String> _emails = {}; // Map to store emails keyed by username.
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _searchQuery = '';

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
      final bool canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        _showCredentialsDirectly(userName);
        return;
      }

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
      final credentials = jsonDecode(storedData);
      email = credentials['email'];
      password = credentials['password'];
    }

    showDialogBox(userName, email, password);
  }

  void showDialogBox(String userName, String? email, String? password) {
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    bool _isObscure = true;
    bool _isEditing = false;

    _usernameController.text = userName;
    _emailController.text = email ?? '';
    _passwordController.text = password ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.key_rounded,
                              size: 28,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Credential Details",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Credential Presentation
                    !_isEditing
                        ? Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.person_rounded),
                                title: const Text("Username"),
                                subtitle: Text(
                                  userName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.email_rounded),
                                title: const Text("Email"),
                                subtitle: Text(
                                  email ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.lock_rounded),
                                title: const Text("Password"),
                                subtitle: Text(
                                  password ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildEditableField(
                                context,
                                label: "Username",
                                controller: _usernameController,
                                icon: Icons.person_rounded,
                                isEditing: _isEditing,
                              ),
                              const SizedBox(height: 16),
                              _buildEditableField(
                                context,
                                label: "Email",
                                controller: _emailController,
                                icon: Icons.email_rounded,
                                isEditing: _isEditing,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _isObscure,
                                enabled: _isEditing,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  prefixIcon: const Icon(Icons.lock_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () => setState(
                                        () => _isObscure = !_isObscure),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 32),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_isEditing)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _usernameController.text = userName;
                                _emailController.text = email ?? '';
                                _passwordController.text = password ?? '';
                              });
                            },
                            child: const Text("Cancel"),
                          ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () async {
                            if (_isEditing) {
                              if (_usernameController.text.isEmpty ||
                                  _emailController.text.isEmpty ||
                                  _passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('All fields are required')),
                                );
                                return;
                              }

                              try {
                                if (_usernameController.text != userName) {
                                  final existing = await storage.read(
                                      key: _usernameController.text);
                                  if (existing != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Username already exists')),
                                    );
                                    return;
                                  }
                                }

                                final newData = {
                                  'userName': _usernameController.text,
                                  'email': _emailController.text,
                                  'password': _passwordController.text,
                                  'category': widget.title,
                                };

                                if (_usernameController.text != userName) {
                                  await storage.delete(key: userName);
                                }

                                await storage.write(
                                  key: _usernameController.text,
                                  value: jsonEncode(newData),
                                );

                                getUserNameList(widget.title);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Credential updated')),
                                );
                                // Close the dialog after update.
                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            } else {
                              setState(() => _isEditing = true);
                            }
                          },
                          child: Text(_isEditing ? "Save Changes" : "Edit"),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(BuildContext context,
      {required String label,
      required TextEditingController controller,
      required IconData icon,
      required bool isEditing}) {
    return TextFormField(
      controller: controller,
      enabled: isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }

  void getUserNameList(String categoryName) async {
    try {
      Map<String, String> allData = await storage.readAll();
      List<String> usernames = [];
      Map<String, String> emailsMap = {};

      for (String key in allData.keys) {
        String? jsonString = allData[key];
        if (jsonString != null) {
          Map<String, dynamic> credentials = jsonDecode(jsonString);
          if (credentials.containsKey('userName') &&
              credentials['category'] == categoryName) {
            String userName = credentials['userName'];
            usernames.add(userName);
            emailsMap[userName] = credentials['email'] ?? '';
          }
        }
      }

      final prefs = await SharedPreferences.getInstance();
      List<String>? savedOrder = prefs.getStringList(_orderKey);

      if (savedOrder != null) {
        List<String> orderedUsernames = [];
        for (String username in savedOrder) {
          if (usernames.contains(username)) {
            orderedUsernames.add(username);
          }
        }
        for (String username in usernames) {
          if (!orderedUsernames.contains(username)) {
            orderedUsernames.add(username);
          }
        }
        usernames = orderedUsernames;
      }

      setState(() {
        _usernames = usernames;
        _emails = emailsMap;
      });
    } catch (e) {
      print('Error loading usernames: $e');
    }
  }

  void _deleteCredential(String username) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              Text('Are you sure you want to delete credential "$username"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      try {
        await storage.delete(key: username);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credential "$username" deleted')),
        );
        getUserNameList(widget.title);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting credential: $e')),
        );
      }
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search credentials...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
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
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setStringList(_orderKey, _usernames);
                    },
                    children: [
                      for (int index = 0; index < _usernames.length; index++)
                        CredentialCard(
                          key: ValueKey(_usernames[index]),
                          username: _usernames[index],
                          email: _emails[_usernames[index]] ?? '',
                          onTap: () {
                            setState(() => _isAuthenticating = true);
                            onTap(context, _usernames[index]);
                            setState(() => _isAuthenticating = false);
                          },
                          onIconTap: () => _deleteCredential(_usernames[index]),
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
                        email: _emails[username] ?? '',
                        onTap: () => onTap(context, username),
                        onIconTap: () => _deleteCredential(username),
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
