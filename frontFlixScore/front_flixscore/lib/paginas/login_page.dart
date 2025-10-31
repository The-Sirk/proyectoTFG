
import 'package:flutter/material.dart';

import '../componentes/login/card_login.dart';
import '../componentes/login/header_component.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.5;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 24.0),
          HeaderWidget(),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth < 400 ? 400 : maxWidth),
              child: LoginCard(),
              ),
          ),
        ],
      ),
    );
  }
}