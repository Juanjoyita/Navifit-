import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mission_controller.dart'; // Asegúrate de importar tu Mission model aquí

class MissionRouteScreen extends StatelessWidget {
  const MissionRouteScreen({super.key});

  // Definición de tu nueva paleta de colores para esta pantalla
  static const Color primaryDark = Color(0xFF202221); // Casi Negro / Gris Muy Oscuro (Fondo)
  static const Color secondaryDark = Color(0xFF303531); // Gris Verdoso Muy Oscuro (Fondo para elementos, AppBar)
  static const Color accentDarkGreen = Color(0xFF4D574E); // Verde Grisáceo Oscuro
  static const Color accentGoldLight = Color(0xFFB68B4B); // Marrón Claro / Dorado Arena (Texto principal, acentos)
  static const Color accentGoldMedium = Color(0xFF956E2F); // Marrón Medio / Dorado Oscuro (Botones, elementos interactivos)
  static const Color accentGoldDark = Color(0xFF654922); // Marrón Oscuro / Bronce Oscuro (Acentos fuertes, borde de botones)

  @override
  Widget build(BuildContext context) {
    final missionController = Get.find<MissionController>();

    return Scaffold(
      backgroundColor: primaryDark, // Fondo general de la pantalla
      appBar: AppBar(
        title: Text(
          'Misiones disponibles',
          style: TextStyle(color: accentGoldLight), // Título de la appbar en dorado claro
        ),
        backgroundColor: secondaryDark, // AppBar en un gris verdoso más claro
        elevation: 0,
        iconTheme: IconThemeData(color: accentGoldLight), // Íconos en dorado claro
      ),
      body: Obx(() {
        if (missionController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentGoldLight), // Indicador de carga en dorado claro
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
                    color: accentGoldLight.withOpacity(0.8), // Texto en dorado claro con opacidad
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Puedes volver a la pantalla de selección de deporte si no hay misiones
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
          padding: const EdgeInsets.all(12.0), // Padding alrededor de la lista
          itemCount: missions.length,
          itemBuilder: (context, index) {
            final mission = missions[index];
            return Card(
              color: secondaryDark, // Fondo de la tarjeta en gris verdoso más claro
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Margen vertical y horizontal
              elevation: 4, // Sombra sutil
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Bordes redondeados
                side: BorderSide(color: accentGoldMedium.withOpacity(0.5), width: 1), // Borde sutil dorado oscuro
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Padding interno del ListTile
                title: Text(
                  mission.title,
                  style: TextStyle(
                    color: accentGoldLight, // Título de la misión en dorado claro
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0), // Espacio entre título y subtítulo
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.description,
                        style: TextStyle(
                          color: accentGoldLight.withOpacity(0.8), // Descripción en dorado claro con opacidad
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Puedes añadir más detalles de la misión aquí, por ejemplo, dificultad, distancia
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
                trailing: Icon(Icons.arrow_forward_ios, color: accentGoldLight), // Icono de flecha en dorado claro
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