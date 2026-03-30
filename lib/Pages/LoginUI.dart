import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kButton.dart';
import 'package:prime_invoice/Resources/colors.dart';

class LoginUI extends StatefulWidget {
  const LoginUI({super.key});

  @override
  State<LoginUI> createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _error = "";

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleInput(String value) {
    setState(() {
      _error = "";
    });
    if (_pinController.text.length < 5) {
      _pinController.text += value;
    }
    if (_pinController.text.length == 5) {
      _verifyPin();
    }
  }

  void _handleBackspace() {
    if (_pinController.text.isNotEmpty) {
      setState(() {
        _pinController.text = _pinController.text.substring(
          0,
          _pinController.text.length - 1,
        );
        _error = "";
      });
    }
  }

  void _verifyPin() {
    // For demo purposes, the PIN is 12345
    if (_pinController.text == "12345") {
      context.go('/');
    } else {
      setState(() {
        _error = "Invalid PIN. Please try again.";
        _pinController.clear();
      });
      // Add a slight vibration or shake effect if possible,
      // but for now just clear and show error.
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColor(context).surface,
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.backspace) {
              _handleBackspace();
            } else if (event.logicalKey.keyLabel.length == 1 &&
                RegExp(r'[0-9]').hasMatch(event.logicalKey.keyLabel)) {
              _handleInput(event.logicalKey.keyLabel);
            }
          }
        },
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 850),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Side: Branding
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: kColor(context).primary.withAlpha(20),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: kColor(context).primary.withAlpha(50),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.gem,
                            color: kColor(context).primary,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Label(
                          "Jewellery Store",
                          fontSize: 28,
                          weight: 800,
                          textAlign: TextAlign.center,
                        ).title,
                        const SizedBox(height: 8),
                        Label(
                          "Management System",
                          fontSize: 16,
                          color: kColor(context).onSurfaceVariant,
                          textAlign: TextAlign.center,
                        ).regular,
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: kColor(context).surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.shieldCheck,
                                size: 16,
                                color: StatusText.success,
                              ),
                              const SizedBox(width: 8),
                              Label(
                                "Secure Access Points",
                                fontSize: 12,
                                color: kColor(context).onSurface,
                              ).regular,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vertical Divider/Space
                  const SizedBox(width: 60),

                  // Right Side: PIN & NumPad
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Label(
                          "Enter Security PIN",
                          fontSize: 18,
                          weight: 600,
                          color: kColor(context).onSurface,
                        ).regular,
                        const SizedBox(height: 32),
                        _buildPinDisplay(),
                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Label(
                            _error,
                            color: kColor(context).error,
                            fontSize: 14,
                          ).regular,
                        ],
                        const SizedBox(height: 40),
                        _buildNumPad(),
                        const SizedBox(height: 32),
                        KButton(
                          onPressed: () {
                            // Help or alternative login?
                          },
                          label: "Forgot PIN?",
                          style: KButtonStyle.outlined,
                          foregroundColor: kColor(context).onSurfaceVariant,
                          fontSize: 13,
                          radius: 30,
                        ),
                      ],
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

  Widget _buildPinDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        bool isFilled = _pinController.text.length > index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? kColor(context).primary
                : kColor(context).outlineVariant.withAlpha(100),
            border: Border.all(
              color: isFilled
                  ? kColor(context).primary
                  : kColor(context).outlineVariant,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumPad() {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_numButton("1"), _numButton("2"), _numButton("3")],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_numButton("4"), _numButton("5"), _numButton("6")],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_numButton("7"), _numButton("8"), _numButton("9")],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 80), // Placeholder for alignment
              _numButton("0"),
              _actionButton(LucideIcons.delete, _handleBackspace),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numButton(String text) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleInput(text),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kColor(context).outlineVariant, width: 1),
          ),
          alignment: Alignment.center,
          child: Label(text, fontSize: 24, weight: 700).title,
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: SizedBox(
          width: 80,
          height: 80,
          child: Icon(icon, color: kColor(context).onSurface, size: 28),
        ),
      ),
    );
  }
}
