import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prime_invoice/Helper/database_service.dart';
import 'package:prime_invoice/Essentials/Label.dart';

class ConnectionGuard extends StatefulWidget {
  final Widget child;

  const ConnectionGuard({super.key, required this.child});

  @override
  State<ConnectionGuard> createState() => _ConnectionGuardState();
}

class _ConnectionGuardState extends State<ConnectionGuard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // ⏰ Periodically check if the drive is still connected
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      DatabaseService.instance.checkDriveAvailability();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: DatabaseService.storageType,
      builder: (context, type, _) {
        final isPortable = type == "Portable Drive";

        return ValueListenableBuilder<bool>(
          valueListenable: DatabaseService.isDriveConnected,
          builder: (context, connected, child) {
            // If we are in portable mode but the drive is GONE, show a prominent warning but don't block
            final showWarning = isPortable && !connected;

            return Stack(
              children: [
                widget.child,
                if (showWarning) _buildStickyWarning(context),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStickyWarning(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.red,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 15),
                Expanded(
                  child: Label(
                    "PORTABLE DRIVE DISCONNECTED! Please reconnect your hard drive immediately to avoid data loss.",
                    color: Colors.white,
                    fontSize: 12,
                    weight: 600,
                  ).regular,
                ),
                TextButton(
                  onPressed: () =>
                      DatabaseService.instance.checkDriveAvailability(),
                  child: Label("RETRY", color: Colors.white).title,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
