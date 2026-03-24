import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:kalyanboss/features/auth/domain/entities/signup_entity.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/utils/widgets/custom_button_widget.dart';
import 'package:pinput/pinput.dart';
class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  // Move Themes to a getter or variable so _buildOtpInput can see them
  late PinTheme defaultPinTheme;
  late PinTheme focusedPinTheme;

  @override
  void initState() {
    super.initState();
    // Initialize themes once
    defaultPinTheme = PinTheme(
      width: 50,
      height: 55,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Verify Device")),
      body: BlocConsumer<AuthBloc, AuthState>(
        // Listen for verification success to show a final toast or side effects
        listener: (context, state) {
          state.verifyOtpState.maybeWhen(
            error: (msg, _) => Fluttertoast.showToast(msg: msg),
            success: (data) {
              // GoRouter will automatically redirect because isAuthenticated is now true
              // But you can add a manual fallback if needed:

            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          // We check both signupEntity (to get the phone number)
          // and verifyOtpState (to show the loading spinner)
          final isVerifying = state.verifyOtpState.maybeWhen(
              loading: () => true,
              orElse: () => false
          );

          return Stack(
            children: [
              // Main Content
              state.signupEntity.maybeWhen(
                success: (data) => _buildOtpInput(context, data, isVerifying),
                orElse: () => _buildOtpInput(context, null,isVerifying),
              ),

              // Loading Overlay
              if (isVerifying)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOtpInput(BuildContext context, SignupEntity? data, bool isVerifying) {
    return SingleChildScrollView( // Added to prevent bottom overflow when keyboard opens
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          const SizedBox(height: 100), // Push content down a bit
          Text(
            data != null
                ? "Verification code sent to ${data.data?.mobile}"
                : "Please enter the verification code",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 30),

          Pinput(
            length: 6,
            controller: pinController,
            focusNode: focusNode,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            hapticFeedbackType: HapticFeedbackType.mediumImpact,
            onCompleted: (pin) => _onVerify(context, pin, data?.data?.mobile ?? ""),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: CustomButton(
              isLoading: isVerifying,

              onPressed: () => _onVerify(context, pinController.text,data?.data?.mobile ?? ""),
              child: const Text("VERIFY & REGISTER",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              // Add Resend OTP Event here
            },
            child: const Text("Resend Code"),
          ),
        ],
      ),
    );
  }

  void _onVerify(BuildContext context, String otp, String mobile) {
    if (otp.length == 6) {
      // Replace with your specific VerifyOtp event
      context.read<AuthBloc>().add(VerifyOtpEvent(otp: otp, mobile: mobile));
      debugPrint("Verifying OTP: $otp");
    } else {
      Fluttertoast.showToast(msg: "Enter 6 digit code");

    }
  }
}