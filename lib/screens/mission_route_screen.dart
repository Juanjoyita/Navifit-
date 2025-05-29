// lib/screens/mission_route_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mission_controller.dart';

class MissionRouteScreen extends StatelessWidget {
  const MissionRouteScreen({super.key});

  static const Color primaryDark = Color(0xFF202221);
  static const Color secondaryDark = Color(0xFF303531);
  static const Color accentDarkGreen = Color(0xFF4D574E);
  static const Color accentGoldLight = Color(0xFFB68B4B);
  static const Color accentGoldMedium = Color(0xFF956E2F);
  static const Color accentGoldDark = Color(0xFF654922);

  @override
  Widget build(BuildContext context) {
    final missionController = Get.find<MissionController>();

    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        title: Text(
          'Misiones disponibles',
          style: TextStyle(color: accentGoldLight),
        ),
        backgroundColor: secondaryDark,
        elevation: 0,
        iconTheme: IconThemeData(color: accentGoldLight),
      ),
      body: Obx(() {
        if (missionController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentGoldLight),
            ),
          );
        }

        final missions = missionController.missions;

        if (missions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flag_outlined, size: 80, color: accentGoldLight.withOpacity(0.7)),
                const SizedBox(height: 20),
                Text(
                  'No se encontraron misiones para este deporte y dificultad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: accentGoldLight.withOpacity(0.8),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(Icons.arrow_back, color: primaryDark),
                  label: Text('Volver a selección', style: TextStyle(color: primaryDark)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGoldMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: accentGoldLight),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: missions.length,
          itemBuilder: (context, index) {
            final mission = missions[index];
            return Card(
              color: secondaryDark,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: accentGoldMedium.withOpacity(0.5), width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                title: Text(
                  mission.title,
                  style: TextStyle(
                    color: accentGoldLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.description,
                        style: TextStyle(
                          color: accentGoldLight.withOpacity(0.8),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.directions_run, size: 18, color: accentGoldMedium),
                          const SizedBox(width: 5),
                          Text(
                            'Deporte: ${mission.sport}',
                            style: TextStyle(color: accentGoldLight.withOpacity(0.8), fontSize: 14),
                          ),
                          const SizedBox(width: 15),
                          Icon(Icons.bar_chart, size: 18, color: accentGoldMedium),
                          const SizedBox(width: 5),
                          Text(
                            'Dificultad: ${mission.difficulty}',
                            style: TextStyle(color: accentGoldLight.withOpacity(0.8), fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: accentGoldLight),
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