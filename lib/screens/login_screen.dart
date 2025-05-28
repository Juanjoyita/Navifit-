import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Definición de tu nueva paleta de colores para esta pantalla
  static const Color primaryDark = Color(0xFF202221); // Casi Negro / Gris Muy Oscuro (Fondo)
  static const Color secondaryDark = Color(0xFF303531); // Gris Verdoso Muy Oscuro (Fondo para elementos)
  static const Color accentDarkGreen = Color(0xFF4D574E); // Verde Grisáceo Oscuro
  static const Color accentGoldLight = Color(0xFFB68B4B); // Marrón Claro / Dorado Arena (Texto principal, acentos)
  static const Color accentGoldMedium = Color(0xFF956E2F); // Marrón Medio / Dorado Oscuro (Botones, elementos interactivos)
  static const Color accentGoldDark = Color(0xFF654922); // Marrón Oscuro / Bronce Oscuro (Acentos fuertes, borde de botones)

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark, // Fondo general de la pantalla
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryDark, secondaryDark], // Gradiente entre los dos tonos más oscuros
          ),
        ),
        child: Obx(() {
          return authController.isLoading.value
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(accentGoldLight), // Indicador de carga en dorado claro
                  ),
                )
              : SingleChildScrollView(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 70), // Espacio un poco mayor
                          Center(
                            child: Icon(
                              Icons.sports_score,
                              size: 100, // Icono más grande
                              color: accentGoldLight, // Icono principal en dorado claro
                            ),
                          ),
                          const SizedBox(height: 50), // Espacio un poco mayor
                          Text(
                            'Bienvenido a NaviFit',
                            style: TextStyle(
                              color: accentGoldLight, // Título en dorado claro
                              fontSize: 36, // Tamaño de fuente más grande
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5), // Espacio reducido
                          Text(
                            'Una experiencia extraordinaria',
                            style: TextStyle(
                              color: accentGoldLight.withOpacity(0.7), // Slogan en dorado claro con opacidad
                              fontSize: 18, // Tamaño de fuente aumentado
                            ),
                          ),
                          const SizedBox(height: 50), // Espacio un poco mayor
                          _buildTextField(
                            controller: emailController,
                            label: 'Email',
                            icon: Icons.email,
                          ),
                          const SizedBox(height: 25), // Espacio un poco mayor
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
                                // Lógica para recuperar contraseña
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
                                  color: accentGoldLight, // Texto en dorado claro
                                  fontSize: 15,
                                  decoration: TextDecoration.underline, // Subrayado
                                  decorationColor: accentGoldLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40), // Espacio un poco mayor
                          Container(
                            width: double.infinity,
                            height: 60, // Altura un poco mayor para el botón
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5), // Sombra más pronunciada
                                  blurRadius: 10,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentGoldMedium, // Fondo del botón en dorado oscuro
                                foregroundColor: primaryDark, // Color del texto/icono en el color de fondo
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(color: accentGoldLight, width: 2), // Borde dorado claro y más grueso
                                ),
                                elevation: 0, // La sombra la maneja el Container padre
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
                                  fontSize: 20, // Texto más grande
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2, // Mayor espaciado
                                  color: primaryDark, // Color de texto en el fondo
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25), // Espacio un poco mayor
                          Center(
                            child: TextButton(
                              onPressed: () => Get.offNamed('/register'),
                              child: RichText(
                                text: TextSpan(
                                  text: '¿No tienes cuenta? ',
                                  style: TextStyle(
                                    color: accentGoldLight.withOpacity(0.7), // Texto en dorado claro con opacidad
                                    fontSize: 17, // Tamaño de fuente aumentado
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Regístrate',
                                      style: TextStyle(
                                        color: accentGoldLight, // Texto en dorado claro
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

  // Widget para los campos de texto (reutilizado de RegisterScreen)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryDark.withOpacity(0.6), // Fondo del TextField en gris verdoso semi-transparente
        borderRadius: BorderRadius.circular(15), // Bordes más redondeados
        border: Border.all(color: accentGoldMedium.withOpacity(0.5), width: 1.5), // Borde sutil dorado oscuro
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
        style: TextStyle(color: accentGoldLight, fontSize: 17), // Texto de entrada en dorado claro
        cursorColor: accentGoldLight, // Color del cursor
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: accentGoldLight.withOpacity(0.8)), // Label en dorado claro con opacidad
          prefixIcon: Icon(icon, color: accentGoldLight), // Ícono en dorado claro
          border: InputBorder.none, // Eliminamos el borde predeterminado
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18), // Padding interno aumentado
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: accentGoldLight, width: 2), // Borde enfocado en dorado claro y más grueso
          ),
          enabledBorder: InputBorder.none, // Aseguramos que no haya borde cuando no está enfocado
        ),
      ),
    );
  }
}