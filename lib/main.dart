import 'package:flutter/material.dart';
import 'theme/appTheme.dart';


void main() => runApp(const MomoApp());

class MomoApp extends StatelessWidget {
  const MomoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoMo Wallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      
    );
  }
}