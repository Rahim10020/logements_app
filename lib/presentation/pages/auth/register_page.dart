import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logements_app/core/constants/app_strings.dart';
import 'package:logements_app/core/utils/validators.dart';
import 'package:logements_app/presentation/providers/auth_provider.dart';
import 'package:logements_app/presentation/widgets/custom_buttons.dart';
import 'package:logements_app/presentation/widgets/custom_text_field.dart';

/// Page d'inscription
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Rediriger vers la sélection de rôle avec les données
    context.push(
      '/role-selection',
      extra: {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.register,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 24),

                // Nom
                CustomTextField(
                  label: 'Nom complet',
                  hint: 'Jean Dupont',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (value) =>
                      Validators.validateRequired(value, 'Le nom'),
                  enabled: !isLoading,
                ),

                const SizedBox(height: 16),

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

                const SizedBox(height: 16),

                // Confirmation mot de passe
                CustomTextField(
                  label: AppStrings.confirmPassword,
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  enabled: !isLoading,
                ),

                const SizedBox(height: 32),

                // Bouton inscription
                PrimaryButton(
                  text: AppStrings.register,
                  onPressed: _handleRegister,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),

                // Lien connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.alreadyHaveAccount),
                    TextButtonCustom(
                      text: AppStrings.login,
                      onPressed: isLoading ? null : () => context.pop(),
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
