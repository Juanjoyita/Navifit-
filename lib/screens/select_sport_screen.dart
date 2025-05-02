import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sport_controller.dart';
import '../controllers/location_controller.dart';
import '../widgets/sport_card.dart';

class SelectSportScreen extends StatelessWidget {
  final SportController sportController = Get.put(SportController());

  SelectSportScreen({super.key});

  final List<String> difficulties = ['Fácil', 'Media', 'Difícil'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecciona tu Deporte")),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text("Elige un deporte", style: TextStyle(fontSize: 20)),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: sportController.sports.map((sport) {
                  final isSelected = sportController.selectedSport.value == sport;
                  return SportCard(
                    sport: sport,
                    isSelected: isSelected,
                    onTap: () => sportController.selectSport(sport),
                    color: isSelected ? Colors.red : Colors.black, // Color según selección
                  );
                }).toList(),
              )),
          const SizedBox(height: 30),
          const Text("Elige una dificultad", style: TextStyle(fontSize: 20)),
          Obx(() => Column(
                children: difficulties.map((difficulty) {
                  final isSelected = sportController.selectedDifficulty.value == difficulty;
                  return RadioListTile<String>(
                    title: Text(
                      difficulty,
                      style: TextStyle(
                        color: isSelected ? Colors.red : Colors.black, // Color según selección
                      ),
                    ),
                    value: difficulty,
                    groupValue: sportController.selectedDifficulty.value,
                    activeColor: Colors.red, // Color del radio seleccionado
                    onChanged: (value) => sportController.selectDifficulty(value!),
                  );
                }).toList(),
              )),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              if (sportController.isValidSelection()) {
                try {
                  final locationController = Get.find<LocationController>();
                  await locationController.getCurrentLocation(); // Espera a que se cargue la ubicación
                  Get.toNamed('/map'); // Navega al mapa solo si todo va bien
                } catch (e) {
                  Get.snackbar("Error", "No se pudo obtener la ubicación: $e");
                }
              } else {
                Get.snackbar("Falta información", "Debes elegir un deporte y una dificultad");
              }
            },
            child: const Text("Continuar"),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
