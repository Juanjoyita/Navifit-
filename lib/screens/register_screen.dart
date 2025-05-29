import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  static const Color primaryDark = Color(0xFF202221);
  static const Color secondaryDark = Color(0xFF303531);
  static const Color accentDarkGreen = Color(0xFF4D574E);
  static const Color accentGoldLight = Color(0xFFB68B4B);
  static const Color accentGoldMedium = Color(0xFF956E2F);
  static const Color accentGoldDark = Color(0xFF654922);

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        title: Text(
          'Únete a NaviFit',
          style: TextStyle(
            color: accentGoldLight,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: secondaryDark,
        elevation: 0,
        iconTheme: IconThemeData(color: accentGoldLight),
      ),
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
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Icon(Icons.sports_score, size: 80, color: accentGoldLight),
                        const SizedBox(height: 20),
                        Text(
                          'Comienza tu viaje fitness',
                          style: TextStyle(
                            color: accentGoldLight,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Una experiencia extraordinaria te espera',
                          style: TextStyle(
                            color: accentGoldLight.withOpacity(0.7),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildTextField(
                          controller: nameController,
                          label: 'Nombre',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: passwordController,
                          label: 'Contraseña',
                          icon: Icons.lock,
                          isPassword: true,
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
                              authController.register(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                                nameController.text.trim(),
                              );
                            },
                            child: Text(
                              'CREAR CUENTA',
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
                        TextButton(
                          onPressed: () => Get.offNamed('/'),
                          child: Text(
                            '¿Ya tienes cuenta? Inicia Sesión',
                            style: TextStyle(
                              color: accentGoldLight,
                              fontSize: 17,
                              decoration: TextDecoration.underline,
                              decorationColor: accentGoldLight,
                            ),
                          ),
                        ),
                      ],
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