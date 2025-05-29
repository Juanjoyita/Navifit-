import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/mission_model.dart';
import '../controllers/location_controller.dart';

class MissionDetailScreen extends StatelessWidget {
  const MissionDetailScreen({super.key});

  static const Color primaryDark = Color(0xFF202221);
  static const Color secondaryDark = Color(0xFF303531);
  static const Color accentDarkGreen = Color(0xFF4D574E);
  static const Color accentGoldLight = Color(0xFFB68B4B);
  static const Color accentGoldMedium = Color(0xFF956E2F);
  static const Color accentGoldDark = Color(0xFF654922);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final Mission mission = Get.arguments as Mission;
    final locationController = Get.find<LocationController>();

    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        title: Text(
          mission.title,
          style: TextStyle(
            color: accentGoldLight,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: secondaryDark,
        elevation: 0,
        iconTheme: IconThemeData(color: accentGoldLight),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: accentGoldLight),
            onPressed: () => _showMissionInfo(context, mission),
            tooltip: 'Información de la misión',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [secondaryDark, primaryDark],
              ),
              border: Border(bottom: BorderSide(color: accentGoldMedium.withOpacity(0.3), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: accentGoldMedium,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentGoldLight, width: 1.5),
                      ),
                      child: Text(
                        mission.sport.toUpperCase(),
                        style: TextStyle(
                          color: primaryDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentGoldLight, width: 1.5),
                      ),
                      child: Text(
                        mission.difficulty.toUpperCase(),
                        style: TextStyle(
                          color: accentGoldLight,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  mission.description,
                  style: TextStyle(
                    color: accentGoldLight.withOpacity(0.8),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.timer, color: accentGoldMedium, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Duración objetivo: ${mission.durationTarget} min',
                      style: TextStyle(color: accentGoldLight, fontSize: 13),
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.route, color: accentGoldMedium, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${mission.points.length} puntos',
                      style: TextStyle(color: accentGoldLight, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final position = locationController.currentPosition.value;

              if (mission.points.isEmpty) {
                return Container(
                  color: primaryDark,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, color: accentGoldLight, size: 60),
                        const SizedBox(height: 20),
                        Text(
                          'No hay puntos de ruta disponibles',
                          style: TextStyle(color: accentGoldLight.withOpacity(0.8), fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final routePoints = mission.points;

              final startPoint = routePoints.first;
              final endPoint = routePoints.last;

              final center = startPoint;

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: accentGoldMedium.withOpacity(0.3), width: 1.5),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    center: center,
                    zoom: 14.0,
                    minZoom: 10.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.navifit.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 5.0,
                          color: accentGoldMedium,
                          borderStrokeWidth: 2.0,
                          borderColor: accentGoldLight,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: startPoint,
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: successColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        Marker(
                          point: endPoint,
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: errorColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.flag,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        if (position != null)
                          Marker(
                            point: LatLng(position.latitude, position.longitude),
                            width: 45,
                            height: 45,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_pin,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ...routePoints.length > 2
                            ? routePoints.skip(1).take(routePoints.length - 2).map(
                                (point) => Marker(
                                  point: point,
                                  width: 25,
                                  height: 25,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: accentGoldDark,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : [],
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: secondaryDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              border: Border.all(color: accentGoldMedium.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGoldMedium,
                      foregroundColor: primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: accentGoldLight, width: 2),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      _startMission(mission);
                    },
                    icon: Icon(Icons.play_arrow, size: 24, color: primaryDark),
                    label: const Text(
                      'INICIAR MISIÓN',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accentGoldLight,
                          side: BorderSide(color: accentGoldMedium, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          _shareMission(mission);
                        },
                        icon: Icon(Icons.share, size: 22),
                        label: const Text('COMPARTIR', style: TextStyle(fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accentGoldLight,
                          side: BorderSide(color: accentGoldMedium, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          _saveMission(mission);
                        },
                        icon: Icon(Icons.bookmark_border, size: 22),
                        label: const Text('GUARDAR', style: TextStyle(fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMissionInfo(BuildContext context, Mission mission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: accentGoldMedium, width: 1.5),
        ),
        title: Text(
          'Información de la Misión',
          style: TextStyle(color: accentGoldLight, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Deporte:', mission.sport),
            _buildInfoRow('Dificultad:', mission.difficulty),
            _buildInfoRow('Duración objetivo:', '${mission.durationTarget} minutos'),
            _buildInfoRow('Puntos de ruta:', '${mission.points.length}'),
            const SizedBox(height: 12),
            Text(
              'Descripción:',
              style: TextStyle(color: accentGoldLight, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              mission.description,
              style: TextStyle(color: accentGoldLight.withOpacity(0.8), fontSize: 15),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar', style: TextStyle(color: accentGoldMedium, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: accentGoldLight, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: accentGoldLight.withOpacity(0.8), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _startMission(Mission mission) {
    Get.snackbar(
      'Misión Iniciada',
      '¡Comenzando ${mission.title}!',
      backgroundColor: successColor.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.play_arrow, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }

  void _shareMission(Mission mission) {
    Get.snackbar(
      'Compartir',
      'Funcionalidad de compartir misión próximamente',
      backgroundColor: accentGoldMedium.withOpacity(0.9),
      colorText: primaryDark,
      icon: Icon(Icons.share, color: primaryDark),
      snackPosition: SnackPosition.TOP,
    );
  }

  void _saveMission(Mission mission) {
    Get.snackbar(
      'Guardado',
      'Misión guardada en favoritos',
      backgroundColor: accentGoldMedium.withOpacity(0.9),
      colorText: primaryDark,
      icon: Icon(Icons.bookmark, color: primaryDark),
      snackPosition: SnackPosition.TOP,
    );
  }
}