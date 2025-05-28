// lib/screens/saved_routes_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Para LatLng
import '../controllers/route_controller.dart';
import '../controllers/auth_controller.dart'; // Para AuthController y formato de fecha
import '../controllers/sport_controller.dart'; // Para SportController y obtener iconos/colores
import '../models/route_model.dart'; // Para la clase RouteModel// Asegúrate de que tus IDs de colección estén aquí

class SavedRoutesScreen extends StatefulWidget {
  const SavedRoutesScreen({super.key});

  @override
  State<SavedRoutesScreen> createState() => _SavedRoutesScreenState();
}

class _SavedRoutesScreenState extends State<SavedRoutesScreen> {
  final RouteController routeController = Get.find<RouteController>();
  final AuthController authController = Get.find<AuthController>();
  final SportController sportController = Get.find<SportController>();

  // Tu paleta de colores
  static const Color primaryDark = Color(0xFF202221);
  static const Color secondaryDark = Color(0xFF303531);
  static const Color accentGoldLight = Color(0xFFB68B4B);
  static const Color accentGoldMedium = Color(0xFF956E2F);
  static const Color primaryText = Color(0xFFFFFFFF); // Blanco para texto principal
  static const Color secondaryText = Color(0xFFBBBBBB); // Gris claro para texto secundario

  @override
  void initState() {
    super.initState();
    // Cargar las rutas del usuario cuando la pantalla se inicializa
    // Solo si hay un usuario logueado
    if (authController.user.value != null) {
      routeController.loadUserRoutes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        title: Text(
          'Mis Rutas Guardadas',
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
          // Botón de refrescar para recargar rutas
          IconButton(
            icon: Obx(() => routeController.isLoading.value
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(accentGoldLight),
                    ),
                  )
                : Icon(Icons.refresh, color: accentGoldLight)),
            onPressed: routeController.isLoading.value ? null : () => routeController.loadUserRoutes(),
            tooltip: 'Recargar rutas',
          ),
        ],
      ),
      body: Obx(() {
        if (routeController.isLoading.value && routeController.routes.isEmpty) {
          // Mostrar indicador de carga solo si la lista está vacía y cargando
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentGoldLight),
            ),
          );
        }

        if (routeController.routes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 80, color: accentGoldLight.withOpacity(0.6)),
                  const SizedBox(height: 20),
                  Text(
                    'Aún no tienes rutas guardadas.',
                    style: TextStyle(
                      color: accentGoldLight.withOpacity(0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '¡Crea tu primera aventura ahora!',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed('/create-route'); // Navega a la pantalla de creación de ruta
                    },
                    icon: Icon(Icons.add_location_alt, color: primaryDark),
                    label: Text(
                      'Crear Nueva Ruta',
                      style: TextStyle(color: primaryDark, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGoldMedium,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: accentGoldLight, width: 1.5),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15.0),
          itemCount: routeController.routes.length,
          itemBuilder: (context, index) {
            final route = routeController.routes[index];
            return _buildRouteCard(route);
          },
        );
      }),
    );
  }

  Widget _buildRouteCard(RouteModel route) {
    return Card(
      color: secondaryDark, // Fondo de la tarjeta de ruta
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: accentGoldMedium.withOpacity(0.5), width: 1.5),
      ),
      child: InkWell( // Hace la tarjeta clickable
        onTap: () {
          // Aquí puedes navegar a una pantalla de detalles de la ruta
          // o iniciar el modo "seguir ruta" en el mapa
          Get.snackbar(
            'Ruta Seleccionada',
            'Has seleccionado la ruta: ${route.name}. Aquí podrías iniciar la navegación.',
            backgroundColor: accentGoldMedium.withOpacity(0.9),
            colorText: primaryDark,
            snackPosition: SnackPosition.BOTTOM,
          );
          // Ejemplo: Get.toNamed('/route-details', arguments: route.id);
          // O si quieres iniciar el seguimiento directamente:
          // Get.find<MapController>().startRouteFollowing(route);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                route.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: accentGoldLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (route.description != null && route.description!.isNotEmpty)
                Text(
                  route.description!,
                  style: TextStyle(
                    fontSize: 15,
                    color: secondaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 15),
              Divider(color: accentGoldMedium.withOpacity(0.3), height: 1),
              const SizedBox(height: 15),
              _buildRouteDetailRow(
                icon: Icons.straighten,
                label: 'Distancia:',
                value: routeController.formatDistance(route.distance),
                iconColor: accentGoldMedium,
                textColor: accentGoldLight,
              ),
              _buildRouteDetailRow(
                icon: Icons.timer,
                label: 'Duración Est.:',
                value: routeController.formatDuration(route.duration),
                iconColor: accentGoldMedium,
                textColor: accentGoldLight,
              ),
              _buildRouteDetailRow(
                icon: sportController.getSportIconData(route.sport), // Usa SportController para el icono
                label: 'Deporte:',
                value: route.sport,
                iconColor: accentGoldMedium,
                textColor: accentGoldLight,
              ),
              if (route.difficulty != null && route.difficulty!.isNotEmpty)
                _buildRouteDetailRow(
                  icon: sportController.getDifficultyIcon(route.difficulty!), // Usa SportController para el icono de dificultad
                  label: 'Dificultad:',
                  value: route.difficulty!,
                  iconColor: sportController.getDifficultyColor(route.difficulty!), // Usa SportController para el color de dificultad
                  textColor: accentGoldLight,
                ),
              _buildRouteDetailRow(
                icon: Icons.calendar_month,
                label: 'Creada:',
                value: authController.formatDateTime(route.createdAt.toIso8601String()),
                iconColor: accentGoldMedium,
                textColor: accentGoldLight,
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400], size: 28),
                  onPressed: () => _confirmDeleteRoute(route.id!, route.name),
                  tooltip: 'Eliminar ruta',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para construir las filas de detalles de la ruta
  Widget _buildRouteDetailRow({
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

  // Diálogo de confirmación para eliminar ruta
  void _confirmDeleteRoute(String routeId, String routeName) {
    Get.dialog(
      AlertDialog(
        backgroundColor: secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: accentGoldMedium, width: 1.5),
        ),
        title: Text(
          'Eliminar Ruta',
          style: TextStyle(color: accentGoldLight, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar la ruta "$routeName"? Esta acción es irreversible.',
          style: TextStyle(color: accentGoldLight.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar', style: TextStyle(color: accentGoldMedium)),
          ),
          ElevatedButton(
            onPressed: () {
              routeController.deleteRoute(routeId);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}