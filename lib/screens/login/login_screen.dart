import 'dart:io';

import 'package:flutter/material.dart';

// Widgets
import 'package:appfast/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              Column(
                children: [
                  GoogleSignInButton(onPressed: () {}),
                  if (Platform.isIOS) ... [
                    const SizedBox(height: 16,),
                  AppleSignInButton(onPressed: () {})
                  ]
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}