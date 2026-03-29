import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../Theme.dart';
import '../Widgets/JewelleryCard.dart';
import 'package:go_router/go_router.dart';

class PinLoginUI extends StatefulWidget {
  const PinLoginUI({super.key});

  @override
  State<PinLoginUI> createState() => _PinLoginUIState();
}

class _PinLoginUIState extends State<PinLoginUI> {
  final FocusNode _focusNode = FocusNode();
  String _pin = "";
  final String _correctPin =
      "12345"; // Default PIN as requested (no registration)
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    // Request focus so keyboard events are captured immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handlePress(String val) {
    if (_pin.length < 5) {
      setState(() {
        _pin += val;
        _isError = false;
      });
      if (_pin.length == 5) {
        _verifyPin();
      }
    }
  }

  void _backspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _isError = false;
      });
    }
  }

  void _verifyPin() {
    if (_pin == _correctPin) {
      context.go('/');
    } else {
      setState(() {
        _pin = "";
        _isError = true;
      });
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final String? char = event.character;
      if (char != null && RegExp(r'[0-9]').hasMatch(char)) {
        _handlePress(char);
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        _backspace();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const Icon(LucideIcons.gem, color: JewelleryTheme.gold, size: 48),
              const SizedBox(height: 16),
              Text(
                "AURORA JEWELLERS",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 64),

              // PIN Display
              Text(
                "Enter Security PIN",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  bool isFilled = index < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isError
                          ? Colors.red.withValues(alpha: 0.5)
                          : (isFilled
                                ? JewelleryTheme.gold
                                : theme.dividerTheme.color ??
                                      theme.colorScheme.outline),
                      border: Border.all(
                        color: _isError
                            ? Colors.red
                            : (theme.dividerTheme.color ??
                                  theme.colorScheme.outline),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              if (_isError) ...[
                const SizedBox(height: 16),
                const Text(
                  "Incorrect PIN. Try again.",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
              // const SizedBox(height: 48),

              // Keypad
              // SizedBox(
              //   width: 300,
              //   child: GridView.count(
              //     crossAxisCount: 3,
              //     shrinkWrap: true,
              //     mainAxisSpacing: 20,
              //     crossAxisSpacing: 20,
              //     childAspectRatio: 1.2,
              //     children: [
              //       ...[
              //         "1",
              //         "2",
              //         "3",
              //         "4",
              //         "5",
              //         "6",
              //         "7",
              //         "8",
              //         "9",
              //       ].map((e) => _keyBtn(e)),
              //       const SizedBox.shrink(),
              //       _keyBtn("0"),
              //       _backspaceBtn(),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keyBtn(String val) {
    final theme = Theme.of(context);
    return JewelleryCard(
      padding: EdgeInsets.zero,
      onTap: () => _handlePress(val),
      child: Center(
        child: Text(
          val,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _backspaceBtn() {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: _backspace,
      icon: Icon(
        LucideIcons.delete,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}
