import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const Color primaryDark = Color(0xFF202221);
  static const Color secondaryDark = Color(0xFF303531);
  static const Color accentDarkGreen = Color(0xFF4D574E);
  static const Color accentGoldLight = Color(0xFFB68B4B);
  static const Color accentGoldMedium = Color(0xFF956E2F);
  static const Color accentGoldDark = Color(0xFF654922);

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();

    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        title: Text(
          'Mapa y Rutas',
          style: TextStyle(color: accentGoldLight),
        ),
        backgroundColor: secondaryDark,
        elevation: 0,
        iconTheme: IconThemeData(color: accentGoldLight),
      ),
      body: Obx(() {
        final position = locationController.currentPosition.value;
        if (position == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentGoldLight),
                ),
                const SizedBox(height: 10),
                Text(
                  'Cargando ubicación...',
                  style: TextStyle(color: accentGoldLight, fontSize: 16),
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
            minZoom: 2.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 60.0,
                  height: 60.0,
                  point: userLocation,
                  child: Icon(Icons.person_pin_circle, color: accentGoldLight, size: 40),
                ),
              ],
            ),
          ],
        );
      }),
      bottomNavigationBar: Container(
        color: secondaryDark,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Get.toNamed('/createRoute');
              },
              icon: Icon(Icons.edit_location_alt, color: primaryDark),
              label: Text(
                'Crear mi propia ruta',
                style: TextStyle(fontSize: 16, color: primaryDark),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGoldMedium,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: accentGoldLight, width: 1.5),
                ),
                elevation: 5,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Get.toNamed('/missionRoute');
              },
              icon: Icon(Icons.flag, color: primaryDark),
              label: Text(
                'Seguir Misión 1',
                style: TextStyle(fontSize: 16, color: primaryDark),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGoldMedium,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: accentGoldLight, width: 1.5),
                ),
                elevation: 5,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
