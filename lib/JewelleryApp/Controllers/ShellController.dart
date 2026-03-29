import 'package:flutter/material.dart';

class ShellController extends ChangeNotifier {
  static final ShellController _instance = ShellController._();
  ShellController._();
  factory ShellController() => _instance;

  int selectedIndex = 0;

  void setIndex(int index) {
    if (selectedIndex == index) return;
    selectedIndex = index;
    notifyListeners();
  }
}
