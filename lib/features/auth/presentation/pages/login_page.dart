import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/config/constants.dart';
import 'package:kalyanboss/config/theme/theme.dart';
import 'package:kalyanboss/utils/enums/enums.dart';
import 'package:kalyanboss/utils/widgets/custom_button_widget.dart';
import 'package:kalyanboss/utils/widgets/text_field_component.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kalyanboss/config/routes/route_names.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _iconController;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _iconScale = CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _iconController.forward();
      });
    });
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   // Optional: Add back button if coming from specific flow
      //   leading: BackButton(color: colorScheme.onSurface),
      // ),
      body: SafeArea(
        child: Center(
          child: MaxWidthBox(
            maxWidth: 600,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  // Navigation handled by GoRouter redirect logic
                },
                builder: (context, state) {
                  // Using verifyOtpState as per your current AuthBloc login logic
                  final isLoading = state.verifyOtpState.maybeWhen(
                    loading: () => true,
                    orElse: () => false,
                  );

                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // --- Animated App Icon (Matching Register) ---
                        ScaleTransition(
                          scale: _iconScale,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.2),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                AppLogos.appIcon,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          "Welcome Back!",
                          style: AppTextStyles.h1(color: colorScheme.onSurface),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Please login to access your account.",
                          style: AppTextStyles.bodyMedium(color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // --- Input Fields ---
                        CustomTextField(
                          controller: _mobileController,
                          leading: Icon(Icons.phone_android_outlined, color: colorScheme.primary),
                          hint: "Mobile Number",
                          label: "Phone",
                          keyboardType: TextInputType.phone,
                          validationType: ValidationType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _passwordController,
                          obscureText: true,
                          leading: Icon(Icons.lock_outline, color: colorScheme.primary),
                          hint: "Enter Password",
                          label: "Password",
                          validationType: ValidationType.required,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(),
                        ),

                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Handle forgot password
                            },
                            child: Text(
                              "Forgot Password?",
                              style: AppTextStyles.bodyMedium(color: colorScheme.primary),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- Action Button ---
                        CustomButton(
                          isLoading: isLoading,
                          onPressed: _handleLogin,
                          child: const Text('Login'),
                        ),

                        const SizedBox(height: 24),

                        // Footer (Link to Register)
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTextStyles.bodyMedium(color: colorScheme.onSurfaceVariant),
                            ),
                            TextButton(
                              onPressed: () => context.go(RouteNames.register),
                              child: Text(
                                "Sign Up here",
                                style: AppTextStyles.bodyMediumBold(color: colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(LoginEvent(
        mobile: _mobileController.text.trim(),
        password: _passwordController.text.trim(),
      ));
    }
  }
}