import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../Theme.dart';
import '../Widgets/JewelleryCard.dart';

class LoginUI extends StatefulWidget {
  const LoginUI({super.key});

  @override
  State<LoginUI> createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JewelleryTheme.cream,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: JewelleryTheme.gold, width: 2),
                  ),
                  child: const Icon(
                    LucideIcons.gem,
                    size: 40,
                    color: JewelleryTheme.gold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "AURORA",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: JewelleryTheme.charcoal,
                  ),
                ),
                const Text(
                  "JEWELLERS",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                    color: JewelleryTheme.gold,
                  ),
                ),
                const SizedBox(height: 48),

                // Login Card
                JewelleryCard(
                  width: 400,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: JewelleryTheme.charcoal,
                        ),
                      ),
                      const Text(
                        "Enter your credentials to access the system",
                        style: TextStyle(
                          fontSize: 14,
                          color: JewelleryTheme.slate,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Username
                      const Text(
                        "Username",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: JewelleryTheme.charcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          hintText: "Enter your username",
                          prefixIcon: Icon(LucideIcons.user, size: 20),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password
                      const Text(
                        "Password",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: JewelleryTheme.charcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isObscured,
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          prefixIcon: const Icon(LucideIcons.lock, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured ? LucideIcons.eyeOff : LucideIcons.eye,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _isObscured = !_isObscured),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to Dashboard
                          },
                          child: const Text("LOGIN"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Forgot password? Contact Administrator",
                  style: TextStyle(
                    fontSize: 13,
                    color: JewelleryTheme.slate,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
