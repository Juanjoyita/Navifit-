// lib/screens/mission_details.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/mission_model.dart';
import '../controllers/location_controller.dart';

class MissionDetailScreen extends StatelessWidget {
  const MissionDetailScreen({super.key});

  // Definición de tu nueva paleta de colores para esta pantalla
  static const Color primaryDark = Color(0xFF202221); // Casi Negro / Gris Muy Oscuro (Fondo)
  static const Color secondaryDark = Color(0xFF303531); // Gris Verdoso Muy Oscuro (Fondo para elementos, AppBar)
  static const Color accentDarkGreen = Color(0xFF4D574E); // Verde Grisáceo Oscuro
  static const Color accentGoldLight = Color(0xFFB68B4B); // Marrón Claro / Dorado Arena (Texto principal, acentos)
  static const Color accentGoldMedium = Color(0xFF956E2F); // Marrón Medio / Dorado Oscuro (Botones, elementos interactivos)
  static const Color accentGoldDark = Color(0xFF654922); // Marrón Oscuro / Bronce Oscuro (Acentos fuertes, borde de botones)
  static const Color successColor = Color(0xFF4CAF50); // Verde para éxito/inicio
  static const Color errorColor = Color(0xFFE53935); // Rojo para errores

  @override
  Widget build(BuildContext context) {
    final Mission mission = Get.arguments as Mission;
    final locationController = Get.find<LocationController>();

    return Scaffold(
      backgroundColor: primaryDark, // Fondo general de la pantalla
      appBar: AppBar(
        title: Text(
          mission.title,
          style: TextStyle(
            color: accentGoldLight, // Título de la appbar en dorado claro
            fontSize: 22, // Tamaño de fuente ajustado
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: secondaryDark, // AppBar en un gris verdoso más claro
        elevation: 0,
        iconTheme: IconThemeData(color: accentGoldLight), // Íconos en dorado claro
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: accentGoldLight), // Icono de información en dorado claro
            onPressed: () => _showMissionInfo(context, mission),
            tooltip: 'Información de la misión',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información de la misión
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18), // Padding un poco aumentado
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [secondaryDark, primaryDark], // Gradiente sutil
              ),
              border: Border(bottom: BorderSide(color: accentGoldMedium.withOpacity(0.3), width: 1)), // Borde inferior
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // Padding ajustado
                      decoration: BoxDecoration(
                        color: accentGoldMedium, // Fondo en dorado oscuro
                        borderRadius: BorderRadius.circular(20), // Bordes más redondeados
                        border: Border.all(color: accentGoldLight, width: 1.5), // Borde dorado claro
                      ),
                      child: Text(
                        mission.sport.toUpperCase(),
                        style: TextStyle(
                          color: primaryDark, // Texto en color de fondo para contraste
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // Padding ajustado
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentGoldLight, width: 1.5), // Borde dorado claro
                      ),
                      child: Text(
                        mission.difficulty.toUpperCase(),
                        style: TextStyle(
                          color: accentGoldLight, // Texto en dorado claro
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Espacio un poco mayor
                Text(
                  mission.description,
                  style: TextStyle(
                    color: accentGoldLight.withOpacity(0.8), // Descripción en dorado claro con opacidad
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.timer, color: accentGoldMedium, size: 18), // Ícono en dorado oscuro
                    const SizedBox(width: 6),
                    Text(
                      'Duración objetivo: ${mission.durationTarget} min',
                      style: TextStyle(color: accentGoldLight, fontSize: 13), // Texto en dorado claro
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.route, color: accentGoldMedium, size: 18), // Ícono en dorado oscuro
                    const SizedBox(width: 6),
                    Text(
                      '${mission.points.length} puntos',
                      style: TextStyle(color: accentGoldLight, fontSize: 13), // Texto en dorado claro
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
                  color: primaryDark, // Fondo en primaryDark
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, color: accentGoldLight, size: 60), // Icono más grande y dorado
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

              // Centro del mapa (primer punto de la ruta)
              final center = startPoint;

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: accentGoldMedium.withOpacity(0.3), width: 1.5), // Borde dorado oscuro
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
                          strokeWidth: 5.0, // Ancho de línea un poco mayor
                          color: accentGoldMedium, // Color de la línea de la ruta en dorado oscuro
                          borderStrokeWidth: 2.0,
                          borderColor: accentGoldLight, // Borde de la línea en dorado claro
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
                              color: successColor, // Color de inicio en verde
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4), // Sombra más oscura
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 26, // Tamaño de icono un poco mayor
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
                              color: errorColor, // Color de fin en rojo
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
                              size: 26, // Tamaño de icono un poco mayor
                            ),
                          ),
                        ),

                        // Marcador de ubicación actual del usuario (si está disponible)
                        if (position != null)
                          Marker(
                            point: LatLng(position.latitude, position.longitude),
                            width: 45, // Tamaño un poco mayor
                            height: 45,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blueAccent, // Mantener azul para la ubicación actual
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
                                size: 22, // Tamaño de icono un poco mayor
                              ),
                            ),
                          ),

                        // Puntos intermedios
                        ...routePoints.length > 2
                            ? routePoints.skip(1).take(routePoints.length - 2).map(
                                (point) => Marker(
                                  point: point,
                                  width: 25, // Tamaño un poco mayor
                                  height: 25,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: accentGoldDark, // Puntos intermedios en marrón oscuro
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

          // Botones de acción
          Container(
            padding: const EdgeInsets.all(20), // Padding aumentado
            decoration: BoxDecoration(
              color: secondaryDark, // Fondo en gris verdoso más claro
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25), // Bordes superiores más redondeados
                topRight: Radius.circular(25),
              ),
              border: Border.all(color: accentGoldMedium.withOpacity(0.3), width: 1), // Borde sutil
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, -5), // Sombra hacia arriba
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGoldMedium, // Botón en dorado oscuro
                      foregroundColor: primaryDark, // Texto en color de fondo
                      padding: const EdgeInsets.symmetric(vertical: 16), // Padding aumentado
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Bordes más redondeados
                        side: BorderSide(color: accentGoldLight, width: 2), // Borde dorado claro
                      ),
                      elevation: 5, // Sombra propia
                    ),
                    onPressed: () {
                      _startMission(mission);
                    },
                    icon: Icon(Icons.play_arrow, size: 24, color: primaryDark), // Icono más grande
                    label: const Text(
                      'INICIAR MISIÓN',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 15), // Espacio un poco mayor
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accentGoldLight, // Texto en dorado claro
                          side: BorderSide(color: accentGoldMedium, width: 1.5), // Borde dorado oscuro
                          padding: const EdgeInsets.symmetric(vertical: 14), // Padding ajustado
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Bordes redondeados
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
                    const SizedBox(width: 10), // Espacio entre botones pequeños
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

  // Diálogo de información de la misión
  void _showMissionInfo(BuildContext context, Mission mission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryDark, // Fondo del diálogo en gris verdoso más claro
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: accentGoldMedium, width: 1.5), // Borde dorado oscuro
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
            child: Text('Cerrar', style: TextStyle(color: accentGoldMedium, fontSize: 16)), // Botón en dorado oscuro
          ),
        ],
      ),
    );
  }

  // Widget de fila de información para el diálogo
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4), // Padding ajustado
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: accentGoldLight, fontWeight: FontWeight.bold, fontSize: 16), // Label en dorado claro
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: accentGoldLight.withOpacity(0.8), fontSize: 16), // Valor en dorado claro con opacidad
            ),
          ),
        ],
      ),
    );
  }

  // Snackbars para acciones
  void _startMission(Mission mission) {
    Get.snackbar(
      'Misión Iniciada',
      '¡Comenzando ${mission.title}!',
      backgroundColor: successColor.withOpacity(0.9), // Color verde para éxito
      colorText: Colors.white,
      icon: const Icon(Icons.play_arrow, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
    // Aquí puedes navegar a una pantalla de seguimiento en tiempo real
    // Get.toNamed('/missionTracking', arguments: mission);
  }

  void _shareMission(Mission mission) {
    Get.snackbar(
      'Compartir',
      'Funcionalidad de compartir misión próximamente',
      backgroundColor: accentGoldMedium.withOpacity(0.9), // Dorado oscuro para compartir
      colorText: primaryDark,
      icon: Icon(Icons.share, color: primaryDark),
      snackPosition: SnackPosition.TOP,
    );
  }

  void _saveMission(Mission mission) {
    Get.snackbar(
      'Guardado',
      'Misión guardada en favoritos',
      backgroundColor: accentGoldMedium.withOpacity(0.9), // Dorado oscuro para guardar
      colorText: primaryDark,
      icon: Icon(Icons.bookmark, color: primaryDark),
      snackPosition: SnackPosition.TOP,
    );
  }
}