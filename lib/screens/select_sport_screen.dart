// lib/screens/select_sport_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mission_controller.dart';
import '../controllers/sport_controller.dart';
import '../controllers/location_controller.dart';
import '../widgets/sport_card.dart';

class SelectSportScreen extends StatelessWidget {
  final SportController sportController = Get.put(SportController());

  SelectSportScreen({super.key});

  final List<String> difficulties = ['Fácil', 'Media', 'Difícil'];

  static const Color primaryDark = Color(0xFF202221);
  static const Color secondaryDark = Color(0xFF303531);
  static const Color accentDarkGreen = Color(0xFF4D574E);
  static const Color accentGoldLight = Color(0xFFB68B4B);
  static const Color accentGoldMedium = Color(0xFF956E2F);
  static const Color accentGoldDark = Color(0xFF654922);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        title: Text(
          "Selecciona tu Deporte",
          style: TextStyle(color: accentGoldLight),
        ),
        backgroundColor: secondaryDark,
        elevation: 0,
        iconTheme: IconThemeData(color: accentGoldLight),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: accentGoldLight),
            onPressed: () {
              Get.toNamed('/profile');
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
              fontSize: 24,
              color: accentGoldLight,
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
                    color: isSelected ? accentGoldMedium : secondaryDark.withOpacity(0.7),
                  );
                }).toList(),
              )),
          const SizedBox(height: 30),
          Text(
            "Elige una dificultad",
            style: TextStyle(
              fontSize: 24,
              color: accentGoldLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Column(
                children: difficulties.map((difficulty) {
                  final isSelected = sportController.selectedDifficulty.value == difficulty;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: secondaryDark,
                      border: Border.all(
                        color: isSelected ? accentGoldLight : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: RadioListTile<String>(
                      title: Text(
                        difficulty,
                        style: TextStyle(
                          color: isSelected ? accentGoldLight : Colors.white70,
                          fontSize: 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      value: difficulty,
                      groupValue: sportController.selectedDifficulty.value,
                      activeColor: accentGoldLight,
                      onChanged: (value) => sportController.selectDifficulty(value!),
                    ),
                  );
                }).toList(),
              )),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGoldMedium,
                foregroundColor: primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: accentGoldLight, width: 2),
                ),
                elevation: 8,
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
                      backgroundColor: accentDarkGreen.withOpacity(0.9),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                } else {
                  Get.snackbar(
                    "Falta información",
                    "Debes elegir un deporte y una dificultad",
                    backgroundColor: accentGoldDark.withOpacity(0.9),
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text(
                "Aplicar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}