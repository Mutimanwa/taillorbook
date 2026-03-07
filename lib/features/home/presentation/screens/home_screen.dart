import 'package:flutter/material.dart';
import 'package:taillorbook/features/home/presentation/screens/home_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget is now just a wrapper for HomeView to maintain compatibility
    // if referenced elsewhere, but the router now points to views directly.
    return const HomeView();
  }
}
