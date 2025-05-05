import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mission_controller.dart';

class MissionRouteScreen extends StatelessWidget {
  const MissionRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final missionController = Get.find<MissionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Misiones disponibles'),
      ),
      body: Obx(() {
        if (missionController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final missions = missionController.missions;

        if (missions.isEmpty) {
          return const Center(child: Text('No se encontraron misiones.'));
        }

        return ListView.builder(
          itemCount: missions.length,
          itemBuilder: (context, index) {
            final mission = missions[index];
            return Card(
              margin: const EdgeInsets.all(12.0),
              child: ListTile(
                title: Text(mission.title),
                subtitle: Text(mission.description),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Aquí puedes navegar a una pantalla con el mapa de la misión
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
