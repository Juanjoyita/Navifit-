// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Maps_flutter/Maps_flutter.dart'; // Necesario para LatLng
import '../controllers/auth_controller.dart';
import '../controllers/route_controller.dart';
import '../controllers/sport_controller.dart'; // Para los iconos de deporte y dificultad
import '../models/route_model.dart'; // Para el modelo de ruta
import '../screens/route_detail_screen.dart'; // <-- IMPORTA LA NUEVA PANTALLA

class ProfileScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final RouteController routeController = Get.find<RouteController>();
  final SportController sportController = Get.find<SportController>();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de información del usuario (puedes expandirla)
            Obx(() {
              if (authController.currentUser.value == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, ${authController.currentUser.value?.name ?? 'Usuario'}!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    authController.currentUser.value?.email ?? 'email@example.com',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),

            // Título de la sección de Rutas
            Text(
              'Mis Rutas Creadas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),

            // Lista de Rutas del Usuario
            Expanded(
              child: Obx(() {
                if (routeController.isLoadingRoutes.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (routeController.userRoutes.isEmpty) {
                  return Center(
                    child: Text(
                      'Aún no has creado ninguna ruta. ¡Anímate a crear una!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: routeController.userRoutes.length,
                    itemBuilder: (context, index) {
                      final route = routeController.userRoutes[index];
                      return GestureDetector( // <-- Wrap con GestureDetector para hacerla clicable
                        onTap: () {
                          Get.to(() => const RouteDetailScreen(), arguments: route);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        route.title,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton( // Opcional: botón de eliminar en la lista
                                      icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                                      onPressed: () {
                                        Get.defaultDialog(
                                          title: 'Eliminar Ruta',
                                          middleText: '¿Estás seguro de que quieres eliminar esta ruta?',
                                          backgroundColor: Theme.of(context).cardTheme.color,
                                          titleStyle: Theme.of(context).textTheme.titleLarge,
                                          middleTextStyle: Theme.of(context).textTheme.bodyLarge,
                                          confirm: ElevatedButton(
                                            onPressed: () async {
                                              Get.back(); // Cierra el diálogo
                                              await routeController.deleteUserRoute(route.id!);
                                            },
                                            child: const Text('Sí, Eliminar'),
                                          ),
                                          cancel: OutlinedButton(
                                            onPressed: () {
                                              Get.back(); // Cierra el diálogo
                                            },
                                            child: const Text('Cancelar'),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      sportController.getSportIconData(route.sport),
                                      color: Theme.of(context).hintColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${route.sport} - ${route.difficulty}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).textTheme.bodyMedium?.color,
                                          ),
                                    ),
                                    const SizedBox(width: 15),
                                    Icon(
                                      sportController.getDifficultyIcon(route.difficulty),
                                      color: sportController.getDifficultyColor(route.difficulty),
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Distancia: ${route.distance.toStringAsFixed(2)} km',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                ),
                                Text(
                                  'Duración: ${route.duration.inMinutes} minutos',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}