import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    InputDecoration field(String hint, {bool isPassword = false}) => InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.outlineVariant,
              width: 1
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 1
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        );

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            color: colorScheme.onSurface
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Google button
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 1
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: colorScheme.surface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://www.google.com/favicon.ico',
                      width: 20,
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: colorScheme.outlineVariant,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.g_mobiledata, 
                            size: 18,
                            color: colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Ingresa con Google',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Divider with "o"
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: colorScheme.outlineVariant,
                      thickness: 1
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'o',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: colorScheme.outlineVariant,
                      thickness: 1
                    )
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // E-mail field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'E-mail',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: field('Ingresa tu correo electrónico'),
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              // Contraseña field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Contraseña',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                obscureText: _obscurePassword,
                decoration: field('Ingresa tu contraseña', isPassword: true),
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 28),
              // Iniciar sesión button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}