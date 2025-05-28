// lib/screens/select_sport_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mission_controller.dart';
import '../controllers/sport_controller.dart';
import '../controllers/location_controller.dart';
import '../widgets/sport_card.dart'; // Asegúrate de que esta importación es correcta y SportCard existe

class SelectSportScreen extends StatelessWidget {
  final SportController sportController = Get.put(SportController());

  SelectSportScreen({super.key});

  final List<String> difficulties = ['Fácil', 'Media', 'Difícil'];

  // Definición de tu nueva paleta de colores para esta pantalla
  static const Color primaryDark = Color(0xFF202221); // Casi Negro / Gris Muy Oscuro (Fondo)
  static const Color secondaryDark = Color(0xFF303531); // Gris Verdoso Muy Oscuro (Fondo para elementos)
  static const Color accentDarkGreen = Color(0xFF4D574E); // Verde Grisáceo Oscuro
  static const Color accentGoldLight = Color(0xFFB68B4B); // Marrón Claro / Dorado Arena (Texto principal, acentos)
  static const Color accentGoldMedium = Color(0xFF956E2F); // Marrón Medio / Dorado Oscuro (Botones, elementos interactivos)
  static const Color accentGoldDark = Color(0xFF654922); // Marrón Oscuro / Bronce Oscuro (Acentos fuertes, borde de botones)


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark, // Fondo con el color más oscuro de la paleta
      appBar: AppBar(
        title: Text(
          "Selecciona tu Deporte",
          style: TextStyle(color: accentGoldLight), // Título de la appbar en dorado claro
        ),
        backgroundColor: secondaryDark, // AppBar en un gris verdoso un poco más claro que el fondo principal
        elevation: 0,
        iconTheme: IconThemeData(color: accentGoldLight), // Ícono de back/hamburguesa en dorado claro
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: accentGoldLight), // Icono de persona en dorado claro
            onPressed: () {
              Get.toNamed('/profile'); // Navega a la pantalla de perfil
            },
            tooltip: 'Ver Perfil',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Elige un deporte",
            style: TextStyle(
              fontSize: 24, // Tamaño de fuente aumentado
              color: accentGoldLight, // Texto en dorado claro
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: sportController.sports.map((sport) {
                  final isSelected = sportController.selectedSport.value == sport;
                  return SportCard(
                    sport: sport,
                    isSelected: isSelected,
                    onTap: () => sportController.selectSport(sport),
                    // Colores del SportCard adaptados a la nueva paleta
                    // Usamos accentGoldMedium para el seleccionado y secondaryDark para los no seleccionados
                    color: isSelected ? accentGoldMedium : secondaryDark.withOpacity(0.7),
                  );
                }).toList(),
              )),
          const SizedBox(height: 30),
          Text(
            "Elige una dificultad",
            style: TextStyle(
              fontSize: 24, // Tamaño de fuente aumentado
              color: accentGoldLight, // Texto en dorado claro
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Column(
                children: difficulties.map((difficulty) {
                  final isSelected = sportController.selectedDifficulty.value == difficulty;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Margen vertical aumentado
                    decoration: BoxDecoration(
                      color: secondaryDark, // Fondo del contenedor de la dificultad en gris verdoso oscuro
                      border: Border.all(
                        color: isSelected ? accentGoldLight : Colors.transparent, // Borde dorado claro si seleccionado
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: RadioListTile<String>(
                      title: Text(
                        difficulty,
                        style: TextStyle(
                          color: isSelected ? accentGoldLight : Colors.white70, // Texto en dorado claro si seleccionado, blanco tenue si no
                          fontSize: 18, // Tamaño de fuente aumentado
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Negrita si seleccionado
                        ),
                      ),
                      value: difficulty,
                      groupValue: sportController.selectedDifficulty.value,
                      activeColor: accentGoldLight, // Radio button en dorado claro
                      onChanged: (value) => sportController.selectDifficulty(value!),
                    ),
                  );
                }).toList(),
              )),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), // Padding aumentado
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGoldMedium, // Fondo del botón en dorado oscuro
                foregroundColor: primaryDark, // Texto del botón en el color de fondo para contraste
                padding: const EdgeInsets.symmetric(vertical: 18), // Padding aumentado
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Bordes más suaves
                  side: BorderSide(color: accentGoldLight, width: 2), // Borde dorado claro y más grueso
                ),
                elevation: 8, // Mayor elevación
              ),
              onPressed: () async {
                if (sportController.isValidSelection()) {
                  print('Deporte seleccionado: ${sportController.selectedSport.value}');
                  print('Dificultad seleccionada: ${sportController.selectedDifficulty.value}');
                  try {
                    final locationController = Get.find<LocationController>();
                    await locationController.getCurrentLocation();
                    final missionController = Get.find<MissionController>();
                    await missionController.fetchMissions(
                      sportController.selectedSport.value,
                      sportController.selectedDifficulty.value,
                    );
                    Get.toNamed('/map');
                  } catch (e) {
                    Get.snackbar(
                      "Error",
                      "No se pudo obtener la ubicación o las rutas: $e",
                      backgroundColor: accentDarkGreen.withOpacity(0.9), // Snackar en verde grisáceo oscuro
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM, // Posición del snackbar
                    );
                  }
                } else {
                  Get.snackbar(
                    "Falta información",
                    "Debes elegir un deporte y una dificultad",
                    backgroundColor: accentGoldDark.withOpacity(0.9), // Snackbar en marrón oscuro
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text(
                "Aplicar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Texto más grande y negrita
              ),
            ),
          ),
          const SizedBox(height: 10), // Espacio final
        ],
      ),
    );
  }
}