import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logements_app/core/constants/app_colors.dart';
import 'package:logements_app/core/constants/app_strings.dart';
import 'package:logements_app/core/utils/validators.dart';
import 'package:logements_app/presentation/providers/auth_provider.dart';
import 'package:logements_app/presentation/widgets/custom_buttons.dart';
import 'package:logements_app/presentation/widgets/custom_text_field.dart';

/// Page de connexion
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    final authState = ref.read(authControllerProvider);
    authState.when(
      data: (_) {
        if (mounted) {
          context.go('/home');
        }
      },
      error: (error, _) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $error')),
          );
        }
      },
      loading: () {},
    );
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();

    final authState = ref.read(authControllerProvider);
    authState.when(
      data: (_) {
        if (mounted) {
          context.go('/home');
        }
      },
      error: (error, _) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $error')),
          );
        }
      },
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo et titre
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.brand,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  AppStrings.appTagline,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                Text(
                  AppStrings.login,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 24),

                // Email
                CustomTextField(
                  label: AppStrings.email,
                  hint: 'exemple@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.validateEmail,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 16),

                // Mot de passe
                CustomTextField(
                  label: AppStrings.password,
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: Validators.validatePassword,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 8),

                // Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButtonCustom(
                    text: AppStrings.forgotPassword,
                    onPressed: isLoading
                        ? null
                        : () => context.push('/forgot-password'),
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton connexion
                PrimaryButton(
                  text: AppStrings.login,
                  onPressed: _handleLogin,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppStrings.orContinueWith,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // Connexion Google
                SecondaryButton(
                  text: AppStrings.googleSignIn,
                  icon: Icons.g_mobiledata,
                  onPressed: isLoading ? null : _handleGoogleSignIn,
                ),

                const SizedBox(height: 24),

                // Lien inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(AppStrings.dontHaveAccount),
                    TextButtonCustom(
                      text: AppStrings.register,
                      onPressed:
                          isLoading ? null : () => context.push('/register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
