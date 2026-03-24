import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/services/session_manager.dart';
class BaseScreen extends StatelessWidget {
  const BaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            // Trigger the BLoC event instead of the Manager
            context.read<AuthBloc>().add(LogoutEvent());
          },
          child: const Text(
            "Base",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}