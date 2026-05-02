import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:prime_invoice/Essentials/Label.dart';
import 'package:prime_invoice/Essentials/kButton.dart';
import 'package:prime_invoice/Resources/colors.dart';
import 'package:prime_invoice/Helper/responsive.dart';
import 'package:prime_invoice/Resources/commons.dart';

import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Helper/security_helper.dart';

class LoginUI extends StatefulWidget {
  const LoginUI({super.key});

  @override
  State<LoginUI> createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _error = "";
  late AnimationController _shakeController;
  final ValueNotifier<bool> _isVerifying = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    _isVerifying.dispose();
    super.dispose();
  }

  void _handleInput(String value) {
    if (_isVerifying.value) return;
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
    if (_isVerifying.value) return;
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

  Future<void> _verifyPin() async {
    _isVerifying.value = true;
    try {
      final profile = await DatabaseService.instance.getCompanyProfile();
      final enteredPin = _pinController.text;

      if (SecurityHelper.verifyPin(enteredPin, profile.securityPin)) {
        if (mounted) context.go('/');
      } else {
        if (mounted) {
          setState(() {
            _error = "Invalid Security PIN";
            _pinController.clear();
          });
          _shakeController.forward(from: 0.0);
          HapticFeedback.heavyImpact();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = "System Error: $e");
      }
    } finally {
      _isVerifying.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

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
        child: Stack(
          children: [
            // Background Decoration
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: Responsive.isMobile(context)
                    ? MediaQuery.sizeOf(context).width
                    : 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: kColor(context).primary.withAlpha(20),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: Responsive.isMobile(context)
                    ? MediaQuery.sizeOf(context).width
                    : 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: kColor(context).secondary.withAlpha(15),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final sineValue = sin(3 * pi * _shakeController.value);
                      return Transform.translate(
                        offset: Offset(sineValue * 10, 0),
                        child: child,
                      );
                    },
                    child: Card(
                      elevation: 0,
                      color: kColor(context).surfaceContainerLow.withAlpha(200),
                      shape: RoundedRectangleBorder(
                        borderRadius: kRadius(32),
                        side: BorderSide(
                          color: kColor(context).outlineVariant.withAlpha(100),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 24 : 60,
                          vertical: 60,
                        ),
                        child: isMobile
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildBranding(context),
                                  const SizedBox(height: 48),
                                  _buildLoginForm(context),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: _buildBranding(context),
                                  ),
                                  const SizedBox(width: 80),
                                  Container(
                                    width: 1,
                                    height: 300,
                                    color: kColor(
                                      context,
                                    ).outlineVariant.withAlpha(50),
                                  ),
                                  const SizedBox(width: 80),
                                  Expanded(
                                    flex: 1,
                                    child: _buildLoginForm(context),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranding(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kColor(context).primary,
                kColor(context).primary.withAlpha(150),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: kRadius(28),
            boxShadow: [
              BoxShadow(
                color: kColor(context).primary.withAlpha(80),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(LucideIcons.gem, color: Colors.white, size: 60),
        ),
        const SizedBox(height: 32),
        Label(
          "Prime Invoicing",
          fontSize: 32,
          weight: 900,
          textAlign: TextAlign.center,
        ).title,
        const SizedBox(height: 12),
        Label(
          "Secure Jewellery Management",
          fontSize: 16,
          color: kColor(context).onSurfaceVariant,
          textAlign: TextAlign.center,
        ).regular,
        const SizedBox(height: 40),
        _buildInfoChip(
          context,
          LucideIcons.shieldCheck,
          "Military-grade security",
          StatusText.success,
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: kRadius(50),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Label(label, fontSize: 12, weight: 600, color: color).regular,
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
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
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _error.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: kColor(context).errorContainer.withAlpha(100),
                    borderRadius: kRadius(8),
                  ),
                  child: Label(
                    _error,
                    color: kColor(context).error,
                    fontSize: 13,
                    weight: 600,
                  ).regular,
                )
              : const SizedBox(height: 32),
        ),
        const SizedBox(height: 24),
        _buildNumPad(),
        const SizedBox(height: 48),
        KButton(
          onPressed: () {},
          label: "Forgot PIN?",
          style: KButtonStyle.outlined,
          foregroundColor: kColor(context).onSurfaceVariant,
          fontSize: 13,
          radius: 30,
        ),
      ],
    );
  }

  Widget _buildPinDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        bool isFilled = _pinController.text.length > index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: isFilled ? 24 : 18,
          height: isFilled ? 24 : 18,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: isFilled
                ? kColor(context).primary
                : kColor(context).outlineVariant.withAlpha(80),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: kColor(context).primary.withAlpha(100),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }

  Widget _buildNumPad() {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_numButton("1"), _numButton("2"), _numButton("3")],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_numButton("4"), _numButton("5"), _numButton("6")],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_numButton("7"), _numButton("8"), _numButton("9")],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 80),
              _numButton("0"),
              _actionButton(LucideIcons.delete, _handleBackspace),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numButton(String text) {
    return InkWell(
      onTap: () => _handleInput(text),
      borderRadius: kRadius(24),
      child: Container(
        width: 80,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: kRadius(24),
          color: kColor(context).surfaceContainerHighest.withAlpha(30),
          border: Border.all(
            color: kColor(context).outlineVariant.withAlpha(50),
          ),
        ),
        alignment: Alignment.center,
        child: Label(text, fontSize: 24, weight: 800).title,
      ),
    );
  }

  Widget _actionButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: kRadius(24),
      child: SizedBox(
        width: 80,
        height: 70,
        child: Icon(icon, color: kColor(context).onSurface, size: 28),
      ),
    );
  }
}
