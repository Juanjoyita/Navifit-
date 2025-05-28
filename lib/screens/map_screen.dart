import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  // Definición de tu nueva paleta de colores para esta pantalla
  static const Color primaryDark = Color(0xFF202221); // Casi Negro / Gris Muy Oscuro (Fondo)
  static const Color secondaryDark = Color(0xFF303531); // Gris Verdoso Muy Oscuro (Fondo para elementos)
  static const Color accentDarkGreen = Color(0xFF4D574E); // Verde Grisáceo Oscuro
  static const Color accentGoldLight = Color(0xFFB68B4B); // Marrón Claro / Dorado Arena (Texto principal, acentos)
  static const Color accentGoldMedium = Color(0xFF956E2F); // Marrón Medio / Dorado Oscuro (Botones, elementos interactivos)
  static const Color accentGoldDark = Color(0xFF654922); // Marrón Oscuro / Bronce Oscuro (Acentos fuertes, borde de botones)

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();

    return Scaffold(
      backgroundColor: primaryDark, // Fondo general de la pantalla
      appBar: AppBar(
        title: Text(
          'Mapa y Rutas',
          style: TextStyle(color: accentGoldLight), // Título de la appbar en dorado claro
        ),
        backgroundColor: secondaryDark, // AppBar en un gris verdoso un poco más claro
        elevation: 0,
        iconTheme: IconThemeData(color: accentGoldLight), // Íconos en dorado claro
      ),
      body: Obx(() {
        final position = locationController.currentPosition.value;
        if (position == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentGoldLight), // Indicador dorado
                ),
                const SizedBox(height: 10),
                Text(
                  'Cargando ubicación...',
                  style: TextStyle(color: accentGoldLight, fontSize: 16), // Texto dorado
                ),
              ],
            ),
          );
        }

        final userLocation = LatLng(position.latitude, position.longitude);

        return FlutterMap(
          options: MapOptions(
            center: userLocation,
            zoom: 15.0,
            // Puedes añadir un mínimo y máximo de zoom si lo deseas
            minZoom: 2.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              // Considera un estilo de mapa oscuro si quieres que se adapte mejor a la paleta
              // OpenStreetMap es claro por defecto, pero hay otras opciones si tu proveedor lo permite.
              // Por ahora, lo mantenemos como está, pero la capa de tiles en sí misma no se puede "colorear" fácilmente.
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
              // Puedes añadir una opacidad a la capa si deseas que el fondo primario se "filtre" un poco
              // opacity: 0.8,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 60.0,
                  height: 60.0,
                  point: userLocation,
                  // Color del marcador del usuario en un tono de la paleta
                  child: Icon(Icons.person_pin_circle, color: accentGoldLight, size: 40),
                ),
                // Aquí podrías añadir marcadores para las misiones, rutas guardadas, etc.
              ],
            ),
          ],
        );
      }),
      bottomNavigationBar: Container( // Envuelve el Padding en un Container para darle color
        color: secondaryDark, // Fondo de la barra inferior en un gris verdoso más claro
        padding: const EdgeInsets.all(16.0), // Aumenta el padding para un mejor espacio
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Get.toNamed('/createRoute'); // Navega a la pantalla de crear ruta
              },
              icon: Icon(Icons.edit_location_alt, color: primaryDark), // Icono en color de fondo
              label: Text(
                'Crear mi propia ruta',
                style: TextStyle(fontSize: 16, color: primaryDark), // Texto en color de fondo
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGoldMedium, // Botón en dorado oscuro
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: accentGoldLight, width: 1.5),
                ),
                elevation: 5,
                minimumSize: const Size(double.infinity, 50), // Ancho completo, altura mínima
              ),
            ),
            const SizedBox(height: 12), // Espacio entre botones
            ElevatedButton.icon(
              onPressed: () {
                Get.toNamed('/missionRoute'); // Navega a la pantalla de misión 1
              },
              icon: Icon(Icons.flag, color: primaryDark), // Icono en color de fondo
              label: Text(
                'Seguir Misión 1',
                style: TextStyle(fontSize: 16, color: primaryDark), // Texto en color de fondo
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGoldMedium, // Botón en dorado oscuro
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: accentGoldLight, width: 1.5),
                ),
                elevation: 5,
                minimumSize: const Size(double.infinity, 50), // Ancho completo, altura mínima
              ),
            ),
          ],
        ),
      ),
    );
  }
}