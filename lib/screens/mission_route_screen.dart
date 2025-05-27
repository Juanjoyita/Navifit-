// lib/screens/mission_route_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mission_controller.dart';
import '../services/appwrite_service.dart'; // Necesario para inicializar AppwriteService
import 'package:appwrite/appwrite.dart'; // Necesario para Client

class MissionRouteScreen extends StatelessWidget {
  const MissionRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializa el MissionController la primera vez que se carga esta pantalla.
    // Get.put() lo inyecta en el árbol de dependencias de GetX.
    final MissionController missionController = Get.put(
      MissionController(
        // Pasa el AppwriteService configurado al controlador
        appwriteService: AppwriteService(
          client: Client()
              .setEndpoint('https://fra.cloud.appwrite.io/v1') // ¡VERIFICA TU ENDPOINT!
              .setProject('67f4970e00257170a0c8'), // ¡VERIFICA TU PROJECT ID!
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Misiones disponibles'),
      ),
      body: Obx(() {
        if (missionController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Muestra el mensaje de error si hay uno
        if (missionController.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${missionController.errorMessage.value}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }

        final missions = missionController.missions;

        if (missions.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron misiones.',
              style: TextStyle(color: Colors.grey), // Un color para que se vea mejor
            ),
          );
        }

        return ListView.builder(
          itemCount: missions.length,
          itemBuilder: (context, index) {
            final mission = missions[index];
            return Card(
              margin: const EdgeInsets.all(12.0),
              child: ListTile(
                title: Text(mission.title),
                subtitle: Text('${mission.description} (Deporte: ${mission.sport}, Dificultad: ${mission.difficulty})'), // Información adicional para depurar
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Get.toNamed('/missionDetail', arguments: mission);
                },
              ),
            );
          },
        );
      }),
    );
  }
}