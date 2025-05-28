import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Importa Get para la navegación

// Ya no necesitas importar login_screen.dart y register_screen.dart directamente aquí
// porque GetX maneja las rutas.
// import 'login_screen.dart';
// import 'register_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  // Definición de tu nueva paleta de colores en el contexto de la pantalla
  static const Color primaryDark = Color(0xFF202221); // Casi Negro / Gris Muy Oscuro (Fondo)
  static const Color secondaryDark = Color(0xFF303531); // Gris Verdoso Muy Oscuro (Podría ser para Cards o elementos un poco más claros que el fondo)
  static const Color accentDarkGreen = Color(0xFF4D574E); // Verde Grisáceo Oscuro
  static const Color accentGoldLight = Color(0xFFB68B4B); // Marrón Claro / Dorado Arena (Texto principal, acentos)
  static const Color accentGoldMedium = Color(0xFF956E2F); // Marrón Medio / Dorado Oscuro (Botones, elementos interactivos)
  static const Color accentGoldDark = Color(0xFF654922); // Marrón Oscuro / Bronce Oscuro (Acentos fuertes, borde de botones)


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark, // Fondo con el color más oscuro de la paleta
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Título de la app
            Text(
              'NaviFit', // Nombre de la app
              style: TextStyle(
                fontSize: 60, // Aumentado para mayor impacto
                fontWeight: FontWeight.bold,
                color: accentGoldLight, // Texto en color dorado arena para contraste
                letterSpacing: 3, // Aumentado el espaciado para un look premium
                shadows: [ // Sombra sutil para darle profundidad
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Explora. Corre. Conquista.', // Slogan
              style: TextStyle(
                fontSize: 18,
                color: accentGoldMedium, // Slogan en dorado oscuro
                fontStyle: FontStyle.italic,
              ),
            ),
            const Spacer(),
            // Botones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGoldMedium, // Botón con dorado oscuro
                        foregroundColor: primaryDark, // Texto del botón en el color de fondo para contraste
                        padding: const EdgeInsets.symmetric(vertical: 16), // Padding aumentado
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes más suaves
                          side: BorderSide(color: accentGoldLight, width: 1.5), // Borde dorado claro
                        ),
                        elevation: 8, // Mayor elevación
                      ),
                      onPressed: () {
                        // Usar Get.toNamed para navegar a la ruta de registro
                        Get.toNamed('/register');
                      },
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Texto más grande y negrita
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Espacio un poco mayor entre botones
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accentGoldMedium, width: 2), // Borde más grueso y dorado oscuro
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: accentGoldLight, // Texto del botón delineado en dorado claro
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0, // No elevación para un botón delineado
                      ),
                      onPressed: () {
                        // Usar Get.toNamed para navegar a la ruta de login
                        Get.toNamed('/'); // O '/login' si tienes una ruta específica para login
                      },
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}