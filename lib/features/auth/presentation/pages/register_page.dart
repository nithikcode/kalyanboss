import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/config/constants.dart';
import 'package:kalyanboss/config/theme/theme.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/utils/widgets/custom_button_widget.dart';
import 'package:kalyanboss/utils/widgets/text_field_component.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../../utils/enums/enums.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Added a GlobalKey for the confirm field to trigger remote validation
  final _formKey = GlobalKey<FormState>();

  late AnimationController _iconController;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Slowed down for better bounce
    );

    _iconScale = CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    );

    // Using addPostFrameCallback is cleaner than Future.delayed for init animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _iconController.forward();
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // Ensures the screen pushes up when keyboard appears
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
      ),
      body: SafeArea(
        child: Center(
          child: MaxWidthBox(
            maxWidth: 600,
            child: SingleChildScrollView(
              // Physics added for better "Gaming App" feel on bounce
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state.isAuthenticated) {
                    Navigator.pushReplacementNamed(context, '/base');
                  }
                },
                builder: (context, state) {
                  final isLoading = state.userEntity?.maybeWhen(
                    loading: () => true,
                    orElse: () => false,
                  ) ?? false;

                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        // --- Animated App Icon Section ---
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
                                height: 80, // Slightly smaller for better fit
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          "Let's Register Your Account!",
                          style: AppTextStyles.h1(color: colorScheme.onSurface),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create an account to start your journey.",
                          style: AppTextStyles.bodyMedium(color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // --- Input Fields ---
                        CustomTextField(
                          controller: _nameController,
                          leading: Icon(Icons.person_outline, color: colorScheme.primary),
                          hint: "Your Gamer Name",
                          label: "Name",
                          validationType: ValidationType.required,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

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
                          hint: "Choose a Password",
                          label: "Password",
                          validationType: ValidationType.minLength,
                          minLength: 6,
                          textInputAction: TextInputAction.next,
                          // Important: re-validate confirm password when this changes
                          onChanged: (_) {
                            if (_confirmPasswordController.text.isNotEmpty) {
                              _formKey.currentState?.validate();
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          leading: Icon(Icons.lock_reset_outlined, color: colorScheme.primary),
                          hint: "Confirm Password",
                          label: "Confirm Password",
                          validationType: ValidationType.custom, // Fixed: Added missing type
                          customValidator: (val) {
                            if (val == null || val.isEmpty) return "Please confirm password";
                            if (val != _passwordController.text) return "Passwords don't match";
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleRegister(context: context, mobile : _mobileController, password : _passwordController, name : _nameController),
                        ),

                        const SizedBox(height: 32),

                        // --- Action Button ---
                        CustomButton(
                          isLoading: isLoading,
                          onPressed: () {
                            _handleRegister(context: context, mobile : _mobileController, password : _passwordController, name : _nameController);
                          },
                          child: const Text('Sign Up'),
                        ),

                        const SizedBox(height: 24),

                        // Footer
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Existing Account? ",
                              style: AppTextStyles.bodyMedium(color: colorScheme.onSurfaceVariant),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Login here",
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

  void _handleRegister({required BuildContext context, required TextEditingController mobile, required TextEditingController password, required TextEditingController name}) {
    if (_formKey.currentState!.validate()) {
        context.read<AuthBloc>().add(RegisterEvent(
          mobile: mobile.text.trim(),
          password: password.text.trim(),
          name : name.text.trim()
        ));
    }
  }
}