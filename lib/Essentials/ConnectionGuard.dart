import 'package:flutter/material.dart';

/// ConnectionGuard is kept for structural compatibility.
/// With Supabase, connection is managed by the SDK; this widget simply
/// renders its child without any drive-disconnect overlay.
class ConnectionGuard extends StatelessWidget {
  final Widget child;

  const ConnectionGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
