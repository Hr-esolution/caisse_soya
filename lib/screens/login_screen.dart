import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/desktop_user_controller.dart';
import '../widgets/glass_morphism_container.dart';
import '../widgets/custom_button.dart';
import '../constants/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final DesktopUserController userController = Get.find();
  final TextEditingController _pinController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f3460),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0f3460),
                Color(0xFF1a1a2e),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  
                  // Logo/App Title
                  const Text(
                    'POS DESKTOP',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Secure Point of Sale System',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Login Card
                  GlassMorphismContainer(
                    width: 400,
                    height: 450,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Enter Your PIN',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        Text(
                          'Access your POS account',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[300],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Pin Input Field
                        Container(
                          width: 250,
                          child: TextField(
                            controller: _pinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: '• • • •',
                              hintStyle: const TextStyle(
                                fontSize: 24,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 40),
                        
                        // Login Button
                        CustomButton(
                          text: 'Sign In',
                          onPressed: _handleLogin,
                          width: 250,
                          height: 50,
                          icon: Icons.lock_open,
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Offline Mode Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Offline Mode Available',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Footer
                  const Text(
                    'POS Desktop v${AppConstants.version}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    setState(() {
      _errorMessage = '';
    });

    final pin = _pinController.text.trim();

    if (pin.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your PIN';
      });
      return;
    }

    if (pin.length < AppConstants.minPinLength || pin.length > AppConstants.maxPinLength) {
      setState(() {
        _errorMessage = 'PIN must be between ${AppConstants.minPinLength}-${AppConstants.maxPinLength} digits';
      });
      return;
    }

    // Attempt authentication
    final isAuthenticated = await userController.authenticateWithPin(pin);
    
    if (isAuthenticated) {
      // Navigate to home screen
      Get.offAllNamed('/home');
    } else {
      setState(() {
        _errorMessage = 'Invalid PIN. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}