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

  // Paleta de colores premium
  final Color darkGray = const Color(0xFF2C2C2C);
  final Color premiumRed = const Color(0xFFE31937); // Rojo más sofisticado que #FF0000
  final Color gold = const Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGray, // Fondo gris oscuro
      appBar: AppBar(
        title: const Text("Selecciona tu Deporte", style: TextStyle(color: Colors.white)),
        backgroundColor: darkGray,
        elevation: 0,
        iconTheme: IconThemeData(color: gold), // Ícono dorado
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Elige un deporte", 
            style: TextStyle(
              fontSize: 20,
              color: gold, // Texto dorado
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
                    color: isSelected ? premiumRed : Colors.white.withOpacity(0.7), // Rojo para selección, gris claro para no seleccionado
                  );
                }).toList(),
              )),
          const SizedBox(height: 30),
          Text(
            "Elige una dificultad", 
            style: TextStyle(
              fontSize: 20,
              color: gold, // Texto dorado
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Column(
                children: difficulties.map((difficulty) {
                  final isSelected = sportController.selectedDifficulty.value == difficulty;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: darkGray,
                      border: Border.all(
                        color: isSelected ? gold : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: RadioListTile<String>(
                      title: Text(
                        difficulty,
                        style: TextStyle(
                          color: isSelected ? gold : Colors.white70, // Dorado si está seleccionado
                          fontSize: 16,
                        ),
                      ),
                      value: difficulty,
                      groupValue: sportController.selectedDifficulty.value,
                      activeColor: gold, // Radio button dorado
                      onChanged: (value) => sportController.selectDifficulty(value!),
                    ),
                  );
                }).toList(),
              )),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: premiumRed, // Fondo rojo
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: gold, width: 1.5), // Borde dorado
                ),
                elevation: 5,
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
                      backgroundColor: darkGray,
                      colorText: gold,
                    );
                  }
                } else {
                  Get.snackbar(
                    "Falta información", 
                    "Debes elegir un deporte y una dificultad",
                    backgroundColor: premiumRed.withOpacity(0.9),
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text(
                "Aplicar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}