// lib/screens/mission_details.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/mission_model.dart';
import '../controllers/location_controller.dart';

class MissionDetailScreen extends StatelessWidget {
  const MissionDetailScreen({super.key});

  // Paleta de colores premium
  final Color darkGray = const Color(0xFF2C2C2C);
  final Color premiumRed = const Color(0xFFE31937);
  final Color gold = const Color(0xFFFFD700);

  @override
  Widget build(BuildContext context) {
    final Mission mission = Get.arguments as Mission;
    final locationController = Get.find<LocationController>();

    return Scaffold(
      backgroundColor: darkGray,
      appBar: AppBar(
        title: Text(
          mission.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: darkGray,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: gold),
            onPressed: () => _showMissionInfo(context, mission),
          ),
        ],
      ),
      body: Column(
        children: [
          // Información de la misión
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [darkGray, const Color(0xFF1A1A1A)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: premiumRed,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: gold, width: 1),
                      ),
                      child: Text(
                        mission.sport.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: gold, width: 1),
                      ),
                      child: Text(
                        mission.difficulty.toUpperCase(),
                        style: TextStyle(
                          color: gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  mission.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, color: gold, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Duración objetivo: ${mission.durationTarget} min',
                      style: TextStyle(color: gold, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.route, color: gold, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${mission.points.length} puntos',
                      style: TextStyle(color: gold, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Mapa
          Expanded(
            child: Obx(() {
              final position = locationController.currentPosition.value;

              if (mission.points.isEmpty) {
                return Container(
                  color: const Color(0xFF1A1A1A),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, color: gold, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'No hay puntos de ruta disponibles',
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final routePoints = mission.points;

              final startPoint = routePoints.first;
              final endPoint = routePoints.last;

              // Centro del mapa (primer punto de la ruta)
              final center = startPoint;

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: gold.withOpacity(0.3), width: 1),
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

                    // Línea de la ruta
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 4.0,
                          color: premiumRed,
                          borderStrokeWidth: 2.0,
                          borderColor: Colors.white,
                        ),
                      ],
                    ),

                    // Marcadores
                    MarkerLayer(
                      markers: [
                        // Marcador de inicio
                        Marker(
                          point: startPoint,
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),

                        // Marcador de fin
                        Marker(
                          point: endPoint,
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: premiumRed,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                // Corrected typo here
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.flag,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),

                        // Marcador de ubicación actual del usuario (si está disponible)
                        if (position != null)
                          Marker(
                            point: LatLng(position.latitude, position.longitude),
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.person_pin,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),

                        // Puntos intermedios
                        // Solo si hay más de 2 puntos para evitar IndexOutOfBounds
                        ...routePoints.length > 2
                            ? routePoints.skip(1).take(routePoints.length - 2).map(
                                (point) => Marker(
                                  point: point,
                                  width: 20,
                                  height: 20,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: gold,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                  ),
                                ),
                              )
                            : [], // If not enough points, don't render intermediates
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),

          // Botones de acción
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: darkGray,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border.all(color: gold.withOpacity(0.3), width: 1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: premiumRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: gold, width: 1),
                          ),
                        ),
                        onPressed: () {
                          _startMission(mission);
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text(
                          'INICIAR MISIÓN',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: gold,
                          side: BorderSide(color: gold, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _shareMission(mission);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('COMPARTIR'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: gold,
                          side: BorderSide(color: gold, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _saveMission(mission);
                        },
                        icon: const Icon(Icons.bookmark_border),
                        label: const Text('GUARDAR'),
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
        backgroundColor: darkGray,
        title: Text(
          'Información de la Misión',
          style: TextStyle(color: gold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Deporte:', mission.sport),
            _buildInfoRow('Dificultad:', mission.difficulty),
            _buildInfoRow('Duración objetivo:', '${mission.durationTarget} minutos'),
            _buildInfoRow('Puntos de ruta:', '${mission.points.length}'),
            const SizedBox(height: 8),
            Text(
              'Descripción:',
              style: TextStyle(color: gold, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              mission.description,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar', style: TextStyle(color: gold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: gold, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70),
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
      backgroundColor: const Color(0xFFE31937).withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.play_arrow, color: Colors.white),
    );

    // Aquí puedes navegar a una pantalla de seguimiento en tiempo real
    // Get.toNamed('/missionTracking', arguments: mission);
  }

  void _shareMission(Mission mission) {
    Get.snackbar(
      'Compartir',
      'Funcionalidad de compartir misión próximamente',
      backgroundColor: const Color(0xFFFFD700).withOpacity(0.9),
      colorText: const Color(0xFF2C2C2C),
      icon: const Icon(Icons.share, color: Color(0xFF2C2C2C)),
    );
  }

  void _saveMission(Mission mission) {
    Get.snackbar(
      'Guardado',
      'Misión guardada en favoritos',
      backgroundColor: const Color(0xFFFFD700).withOpacity(0.9),
      colorText: const Color(0xFF2C2C2C),
      icon: const Icon(Icons.bookmark, color: Color(0xFF2C2C2C)),
    );
  }
}