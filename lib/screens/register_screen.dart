import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Definición de tu nueva paleta de colores para esta pantalla
  static const Color primaryDark = Color(0xFF202221); // Casi Negro / Gris Muy Oscuro (Fondo)
  static const Color secondaryDark = Color(0xFF303531); // Gris Verdoso Muy Oscuro (Fondo para elementos, AppBar)
  static const Color accentDarkGreen = Color(0xFF4D574E); // Verde Grisáceo Oscuro
  static const Color accentGoldLight = Color(0xFFB68B4B); // Marrón Claro / Dorado Arena (Texto principal, acentos)
  static const Color accentGoldMedium = Color(0xFF956E2F); // Marrón Medio / Dorado Oscuro (Botones, elementos interactivos)
  static const Color accentGoldDark = Color(0xFF654922); // Marrón Oscuro / Bronce Oscuro (Acentos fuertes, borde de botones)

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark, // Fondo general de la pantalla
      appBar: AppBar(
        title: Text(
          'Únete a NaviFit',
          style: TextStyle(
            color: accentGoldLight, // Título de la appbar en dorado claro
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: secondaryDark, // AppBar en un gris verdoso más claro
        elevation: 0,
        iconTheme: IconThemeData(color: accentGoldLight), // Ícono de back en dorado claro
      ),
      body: Container(
        // El gradiente lo cambiamos para que se ajuste a la paleta
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
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Icon(Icons.sports_score, size: 80, color: accentGoldLight), // Ícono principal en dorado claro
                        const SizedBox(height: 20),
                        Text(
                          'Comienza tu viaje fitness',
                          style: TextStyle(
                            color: accentGoldLight, // Título en dorado claro
                            fontSize: 28, // Tamaño de fuente un poco más grande
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Una experiencia extraordinaria te espera',
                          style: TextStyle(
                            color: accentGoldLight.withOpacity(0.7), // Slogan en dorado claro con opacidad
                            fontSize: 18, // Tamaño de fuente un poco más grande
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
                          height: 60, // Altura un poco mayor para el botón
                          decoration: BoxDecoration(
                            // Eliminamos el color de fondo aquí ya que el ElevatedButton lo manejará
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
                              authController.register(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                                nameController.text.trim(),
                              );
                            },
                            child: Text(
                              'CREAR CUENTA',
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
                        TextButton(
                          onPressed: () => Get.offNamed('/'), // Navegar a la ruta raíz que asumimos es Login
                          child: Text(
                            '¿Ya tienes cuenta? Inicia Sesión',
                            style: TextStyle(
                              color: accentGoldLight, // Texto del TextButton en dorado claro
                              fontSize: 17, // Tamaño de fuente un poco más grande
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

  // Widget para los campos de texto
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