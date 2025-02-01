import 'package:flutter/material.dart';
import 'package:key_master/Pages/home_page.dart';
import 'package:local_auth/local_auth.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        _navigateToHome();
        return;
      }

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        _navigateToHome();
        return;
      }

      await _authenticate();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error checking biometrics: $e';
      });
    }
  }

  Future<void> _authenticate() async {
    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _navigateToHome();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication failed';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error authenticating: $e';
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _authenticate,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
      ),
    );
  }
}
