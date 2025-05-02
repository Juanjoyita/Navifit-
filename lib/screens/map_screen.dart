import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../controllers/location_controller.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de rutas'),
      ),
      body: Obx(() {
        final position = locationController.currentPosition.value;
        if (position == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final userLocation = LatLng(position.latitude, position.longitude);

        return Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  center: userLocation,
                  zoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: userLocation,
                        width: 60,
                        height: 60,
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed('/createRoute'); // Pantalla 6
                    },
                    icon: const Icon(Icons.alt_route),
                    label: const Text('Crear mi propia ruta'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed('/missionRoute'); // Pantalla 5
                    },
                    icon: const Icon(Icons.flag),
                    label: const Text('Seguir Misión 1'),
                  ),
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}
