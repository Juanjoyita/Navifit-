import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  static const Color primaryDark = Color(0xFF202221);
  static const Color secondaryDark = Color(0xFF303531);
  static const Color accentDarkGreen = Color(0xFF4D574E);
  static const Color accentGoldLight = Color(0xFFB68B4B);
  static const Color accentGoldMedium = Color(0xFF956E2F);
  static const Color accentGoldDark = Color(0xFF654922);

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryDark, secondaryDark],
          ),
        ),
        child: Obx(() {
          return authController.isLoading.value
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(accentGoldLight),
                  ),
                )
              : SingleChildScrollView(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 70),
                          Center(
                            child: Icon(
                              Icons.sports_score,
                              size: 100,
                              color: accentGoldLight,
                            ),
                          ),
                          const SizedBox(height: 50),
                          Text(
                            'Bienvenido a NaviFit',
                            style: TextStyle(
                              color: accentGoldLight,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Una experiencia extraordinaria',
                            style: TextStyle(
                              color: accentGoldLight.withOpacity(0.7),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 50),
                          _buildTextField(
                            controller: emailController,
                            label: 'Email',
                            icon: Icons.email,
                          ),
                          const SizedBox(height: 25),
                          _buildTextField(
                            controller: passwordController,
                            label: 'Contraseña',
                            icon: Icons.lock,
                            isPassword: true,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Get.snackbar(
                                  'Recuperar Contraseña',
                                  'Funcionalidad de recuperación de contraseña próximamente',
                                  backgroundColor: accentGoldMedium.withOpacity(0.9),
                                  colorText: primaryDark,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: accentGoldLight,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                  decorationColor: accentGoldLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentGoldMedium,
                                foregroundColor: primaryDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(color: accentGoldLight, width: 2),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                authController.login(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );
                              },
                              child: Text(
                                'INICIAR SESIÓN',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: primaryDark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Center(
                            child: TextButton(
                              onPressed: () => Get.offNamed('/register'),
                              child: RichText(
                                text: TextSpan(
                                  text: '¿No tienes cuenta? ',
                                  style: TextStyle(
                                    color: accentGoldLight.withOpacity(0.7),
                                    fontSize: 17,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Regístrate',
                                      style: TextStyle(
                                        color: accentGoldLight,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: accentGoldLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        }),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryDark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accentGoldMedium.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: accentGoldLight, fontSize: 17),
        cursorColor: accentGoldLight,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: accentGoldLight.withOpacity(0.8)),
          prefixIcon: Icon(icon, color: accentGoldLight),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: accentGoldLight, width: 2),
          ),
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}
