// lib/screens/route_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong2; // IMPORTACION CORRECTA DE LATLONG2 CON PREFIJO// <--- ¡LA UNICA Y CORRECTA IMPORTACION DE GOOGLE MAPS!
import '../models/route_model.dart';
import '../controllers/route_controller.dart';
import '../controllers/sport_controller.dart';
import '../controllers/auth_controller.dart';
// ¡¡ASEGÚRATE DE QUE NO HAYA NINGUNA OTRA IMPORTACIÓN DE MAPAS O DE LATLONG2 AQUÍ!!

class RouteDetailScreen extends StatelessWidget {
  const RouteDetailScreen({super.key});

  // Definición de tu paleta de colores (la mantengo aquí para consistencia)
  static const Color primaryDark = Color(0xFF202221); // Casi Negro / Gris Muy Oscuro (Fondo)
  static const Color secondaryDark = Color(0xFF303531); // Gris Verdoso Muy Oscuro (Fondo para elementos, AppBar)
  static const Color accentGoldLight = Color(0xFFB68B4B); // Marrón Claro / Dorado Arena (Texto principal, acentos)
  static const Color accentGoldMedium = Color(0xFF956E2F); // Marrón Medio / Dorado Oscuro (Botones, elementos interactivos)
  static const Color primaryText = Color(0xFFFFFFFF); // Blanco para texto principal
  static const Color secondaryText = Color(0xFFBBBBBB); // Gris claro para texto secundario


  @override
  Widget build(BuildContext context) {
    // Recupera la ruta pasada como argumento
    final RouteModel? route = Get.arguments as RouteModel?;

    if (route == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Ruta'),
          backgroundColor: secondaryDark,
          foregroundColor: accentGoldLight,
        ),
        backgroundColor: primaryDark,
        body: Center(
          child: Text(
            'Error: No se encontró la información de la ruta.',
            style: TextStyle(color: accentGoldLight, fontSize: 16),
          ),
        ),
      );
    }

    // Instancias de los controladores
    final RouteController routeController = Get.find<RouteController>();
    final SportController sportController = Get.find<SportController>();
    final AuthController authController = Get.find<AuthController>();

    // Obtener LatLngs del RouteModel (que son latlong2.LatLng debido a la importación con 'as latlong2')
    // Y CONVERTIRLAS AL LatLng QUE GoogleMaps necesita
    final LatLng googleMapsStartLatLng = LatLng(route.startPoint.latitude, route.startPoint.longitude);
    final LatLng googleMapsEndLatLng = LatLng(route.endPoint.latitude, route.endPoint.longitude);

    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        title: Text(
          'Detalle de Ruta',
          style: TextStyle(
            color: accentGoldLight,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: secondaryDark,
        elevation: 0,
        iconTheme: IconThemeData(color: accentGoldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la Ruta
            Text(
              route.name,
              style: TextStyle(
                color: accentGoldLight,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Descripción (opcional)
            if (route.description != null && route.description!.isNotEmpty)
              Text(
                route.description!,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 20),

            Divider(color: accentGoldMedium.withOpacity(0.3), height: 1),
            const SizedBox(height: 20),

            // Detalles de la ruta (similar a _buildRouteDetailRow de ProfileScreen)
            _buildDetailRow(
              icon: Icons.straighten,
              label: 'Distancia:',
              value: routeController.formatDistance(route.distance),
              iconColor: accentGoldMedium,
              textColor: primaryText,
            ),
            _buildDetailRow(
              icon: Icons.timer,
              label: 'Duración Est.:',
              value: routeController.formatDuration(route.duration),
              iconColor: accentGoldMedium,
              textColor: primaryText,
            ),
            _buildDetailRow(
              icon: sportController.getSportIconData(route.sport),
              label: 'Deporte:',
              value: route.sport,
              iconColor: accentGoldMedium,
              textColor: primaryText,
            ),
            if (route.difficulty != null && route.difficulty!.isNotEmpty)
              _buildDetailRow(
                icon: sportController.getDifficultyIcon(route.difficulty!),
                label: 'Dificultad:',
                value: route.difficulty!,
                iconColor: sportController.getDifficultyColor(route.difficulty!),
                textColor: primaryText,
              ),
            _buildDetailRow(
              icon: Icons.calendar_month,
              label: 'Creada:',
              value: authController.formatDateTime(route.createdAt.toIso8601String()),
              iconColor: accentGoldMedium,
              textColor: primaryText,
            ),
            // Mostrar si está completada y cuándo
            if (route.isCompleted) ...[
              _buildDetailRow(
                icon: Icons.task_alt,
                label: 'Finalizada:',
                value: route.completedAt != null
                    ? authController.formatDateTime(route.completedAt!.toIso8601String())
                    : 'Fecha no disponible',
                iconColor: Colors.green[400]!,
                textColor: Colors.green[300]!,
              ),
            ],
            const SizedBox(height: 20),

            // Puntos de inicio y fin (coordenadas)
            Text(
              'Coordenadas:',
              style: TextStyle(
                color: accentGoldLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inicio: Lat ${route.startPoint.latitude.toStringAsFixed(4)}, Lng ${route.startPoint.longitude.toStringAsFixed(4)}',
              style: TextStyle(color: secondaryText, fontSize: 15),
            ),
            Text(
              'Fin: Lat ${route.endPoint.latitude.toStringAsFixed(4)}, Lng ${route.endPoint.longitude.toStringAsFixed(4)}',
              style: TextStyle(color: secondaryText, fontSize: 15),
            ),
            const SizedBox(height: 25),

            // Mapa para visualizar la ruta
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: accentGoldMedium, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: googleMapsStartLatLng,
                    zoom: 13,
                  ),
                  polylines: {
                    Polyline(
                      polylineId: PolylineId(route.id ?? 'route_id'),
                      points: [googleMapsStartLatLng, googleMapsEndLatLng],
                      color: accentGoldMedium,
                      width: 5,
                    ),
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('start_point'),
                      position: googleMapsStartLatLng,
                      infoWindow: const InfoWindow(title: 'Inicio'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                    ),
                    Marker(
                      markerId: const MarkerId('end_point'),
                      position: googleMapsEndLatLng,
                      infoWindow: const InfoWindow(title: 'Fin'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    // Puedes guardar el controlador del mapa si necesitas controlarlo después
                    // _mapController = controller;
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Botón "Marcar como Finalizada" (solo si la ruta no está completada)
            if (!route.isCompleted)
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: routeController.isLoading.value || routeController.isSaving.value
                          ? null
                          : () {
                              Get.defaultDialog(
                                title: 'Finalizar Ruta',
                                middleText: '¿Estás seguro de que quieres marcar esta ruta como finalizada?',
                                backgroundColor: secondaryDark,
                                titleStyle: TextStyle(color: accentGoldLight, fontWeight: FontWeight.bold),
                                middleTextStyle: TextStyle(color: secondaryText),
                                confirm: ElevatedButton(
                                  onPressed: () async {
                                    Get.back(); // Cierra el diálogo
                                    await routeController.markRouteAsCompleted(route.id!);
                                    // Una vez marcada como completada, podrías considerar actualizar la vista
                                    // o navegar de regreso a la pantalla de perfil para ver el cambio reflejado.
                                    // Por ejemplo: Get.offAndToNamed('/profile');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    foregroundColor: primaryText,
                                  ),
                                  child: const Text('Sí, Finalizar'),
                                ),
                                cancel: OutlinedButton(
                                  onPressed: () {
                                    Get.back(); // Cierra el diálogo
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: accentGoldMedium,
                                    side: BorderSide(color: accentGoldMedium, width: 1),
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: primaryDark,
                        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.green.shade800, width: 2),
                        ),
                        elevation: 10,
                      ),
                      child: routeController.isLoading.value || routeController.isSaving.value
                          ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryDark))
                          : const Text(
                              'Marcar como Finalizada',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    )),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.8),
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}