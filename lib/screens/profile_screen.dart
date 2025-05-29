// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/route_controller.dart';
import '../controllers/sport_controller.dart';
import '../models/route_model.dart';
// Asegúrate de que todas tus importaciones existentes estén aquí
// ... (Tus otras importaciones) ...


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ... (Tu paleta de colores y controladores existentes) ...

  static const Color primaryDark = Color(0xFF202221);
  static const Color secondaryDark = Color(0xFF303531);
  static const Color accentDarkGreen = Color(0xFF4D574E);
  static const Color accentGoldLight = Color(0xFFB68B4B);
  static const Color accentGoldMedium = Color(0xFF956E2F);
  static const Color accentGoldDark = Color(0xFF654922);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFBBBBBB);

  final AuthController authController = Get.find<AuthController>();
  final RouteController routeController = Get.find<RouteController>();
  final SportController sportController = Get.find<SportController>();


  @override
  void initState() {
    super.initState();
    // ... (Tu initState existente) ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        title: Text(
          'Perfil de Usuario',
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
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.logout();
            },
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Obx(() {
        if (authController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentGoldLight),
            ),
          );
        }

        if (authController.user.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No se pudo cargar la información del usuario o no hay sesión activa.',
                  style: TextStyle(color: accentGoldLight.withOpacity(0.7), fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => authController.fetchUser(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGoldMedium,
                    foregroundColor: primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: accentGoldLight, width: 1.5),
                    ),
                  ),
                  child: const Text('Reintentar', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        }

        final user = authController.user.value!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ... (Avatar, nombre, email, ID de usuario existentes) ...
              CircleAvatar(
                radius: 70,
                backgroundColor: accentGoldLight,
                child: Icon(
                  Icons.person,
                  size: 90,
                  color: primaryDark,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                user.name ?? 'Usuario sin nombre',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: accentGoldLight,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 18,
                  color: accentGoldLight.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'ID de Usuario: ${user.$id}',
                style: TextStyle(
                  fontSize: 14,
                  color: accentGoldLight.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                color: secondaryDark,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: accentGoldMedium.withOpacity(0.4), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfoRow(
                        icon: Icons.calendar_today,
                        label: 'Miembro desde:',
                        value: authController.formatDateTime(user.$createdAt),
                        color: accentGoldMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Botón "Editar Perfil" - ¡AQUÍ ES DONDE CAMBIAS EL onPressed!
              ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed('/editProfile'); // <--- ¡CAMBIO CLAVE AQUÍ!
                },
                icon: Icon(Icons.edit, color: primaryDark),
                label: Text(
                  'Editar Perfil',
                  style: TextStyle(fontSize: 18, color: primaryDark, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGoldMedium,
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: accentGoldLight, width: 2),
                  ),
                  elevation: 10,
                ),
              ),
              const SizedBox(height: 40),

              // ... (Sección de Rutas Guardadas existente) ...
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mis Rutas Guardadas',
                  style: TextStyle(
                    color: accentGoldLight,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (routeController.isLoading.value && routeController.userRoutes.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(accentGoldLight),
                    ),
                  );
                }

                if (routeController.userRoutes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 60, color: accentGoldLight.withOpacity(0.6)),
                          const SizedBox(height: 15),
                          Text(
                            'Aún no tienes rutas guardadas.',
                            style: TextStyle(
                              color: accentGoldLight.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '¡Crea tu primera aventura ahora!',
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              Get.toNamed('/create-route');
                            },
                            icon: Icon(Icons.add_location_alt, color: primaryDark, size: 20),
                            label: Text(
                              'Crear Nueva Ruta',
                              style: TextStyle(color: primaryDark, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentGoldMedium,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: accentGoldLight, width: 1),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: routeController.userRoutes.map((route) => _buildRouteCard(route)).toList(),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  // ... (Tus métodos _buildUserInfoRow, _buildRouteCard, _buildRouteDetailRow, _confirmDeleteRoute existentes) ...

  Widget _buildUserInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accentGoldLight.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    color: accentGoldLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(RouteModel route) {
    return Card(
      color: secondaryDark,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: accentGoldMedium.withOpacity(0.5), width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed('/routeDetail', arguments: route);
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      route.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: accentGoldLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (route.isCompleted)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[400],
                      size: 28,
                    ),
                ],
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
                icon: sportController.getSportIconData(route.sport),
                label: 'Deporte:',
                value: route.sport,
                iconColor: accentGoldMedium,
                textColor: accentGoldLight,
              ),
              if (route.difficulty != null && route.difficulty!.isNotEmpty)
                _buildRouteDetailRow(
                  icon: sportController.getDifficultyIcon(route.difficulty!),
                  label: 'Dificultad:',
                  value: route.difficulty!,
                  iconColor: sportController.getDifficultyColor(route.difficulty!),
                  textColor: accentGoldLight,
                ),
              _buildRouteDetailRow(
                icon: Icons.calendar_month,
                label: 'Creada:',
                value: authController.formatDateTime(route.createdAt.toIso8601String()),
                iconColor: accentGoldMedium,
                textColor: accentGoldLight,
              ),
              if (route.isCompleted && route.completedAt != null)
                _buildRouteDetailRow(
                  icon: Icons.task_alt,
                  label: 'Finalizada:',
                  value: authController.formatDateTime(route.completedAt!.toIso8601String()),
                  iconColor: Colors.green[400]!,
                  textColor: Colors.green[300]!,
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
          const SizedBox(height: 8),
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