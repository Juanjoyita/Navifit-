// lib/controllers/route_controller.dart
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geodesy/geodesy.dart'; // Necesario para la clase Distance
import '../models/route_model.dart';
import '../services/appwrite_service.dart';
import 'auth_controller.dart';
import 'package:appwrite/models.dart' as appwrite_models;

class RouteController extends GetxController {
  final AppwriteService _appwriteService = Get.find<AppwriteService>();
  final AuthController _authController = Get.find<AuthController>();

  var routes = <RouteModel>[].obs;
  var isSelectingStartPoint = true.obs;
  var startPoint = Rxn<LatLng>();
  var endPoint = Rxn<LatLng>();
  var isCreatingRoute = false.obs;
  var selectedRoute = Rxn<RouteModel>();
  var isLoading = false.obs;
  var isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_authController.user, (appwrite_models.User? user) {
      if (user != null) {
        print('RouteController: Usuario logueado (${user.$id}), cargando rutas...');
        loadUserRoutes();
      } else {
        print('RouteController: Usuario deslogueado, limpiando rutas.');
        routes.clear();
      }
    });
  }

  void resetRouteCreation() {
    isSelectingStartPoint.value = true;
    startPoint.value = null;
    endPoint.value = null;
    isCreatingRoute.value = false;
  }

  void selectPoint(LatLng point) {
    if (isSelectingStartPoint.value) {
      startPoint.value = point;
      isSelectingStartPoint.value = false;
    } else {
      endPoint.value = point;
    }
  }

  bool get bothPointsSelected => startPoint.value != null && endPoint.value != null;

  double? get estimatedDistance {
    if (!bothPointsSelected) return null;
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, startPoint.value!, endPoint.value!);
  }

  int? calculateEstimatedDurationInSeconds(double? distanceInMeters, String sport) {
    if (distanceInMeters == null || distanceInMeters <= 0 || sport.isEmpty) return null;

    double speedMPS; // Metros por segundo

    switch (sport.toLowerCase()) {
      case 'running':
        speedMPS = 3.5; // Ej: 12.6 km/h
        break;
      case 'ciclismo':
        speedMPS = 6.0; // Ej: 21.6 km/h
        break;
      case 'senderismo':
        speedMPS = 1.0; // Ej: 3.6 km/h
        break;
      default:
        speedMPS = 1.39; // Velocidad de caminata por defecto si el deporte no está mapeado
    }
    return (distanceInMeters / speedMPS).round();
  }

  String formatDuration(int? durationInSeconds) {
    if (durationInSeconds == null) return 'N/A';

    if (durationInSeconds < 60) {
      return '$durationInSeconds seg';
    } else if (durationInSeconds < 3600) {
      final minutes = (durationInSeconds / 60).round();
      return '$minutes min';
    } else {
      final hours = (durationInSeconds / 3600).floor();
      final remainingSeconds = durationInSeconds % 3600;
      final minutes = (remainingSeconds / 60).round();
      return '${hours}h ${minutes}min';
    }
  }

  Future<void> loadUserRoutes() async {
    if (_authController.user.value == null) {
      print('RouteController: No hay usuario logueado. No se pueden cargar rutas.');
      routes.clear();
      return;
    }
    try {
      isLoading.value = true;
      final userRoutes = await _appwriteService.getUserRoutes();
      routes.value = userRoutes;
      print('RouteController: ${userRoutes.length} rutas cargadas');
    } catch (e) {
      print('RouteController: Error al cargar rutas: $e');
      Get.snackbar(
        'Error',
        'No se pudieron cargar las rutas: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveRoute({
    required String name,
    String? description,
    required String sport,
    String? difficulty,
  }) async {
    if (_authController.user.value == null) {
      Get.snackbar('Error', 'Debes iniciar sesión para guardar una ruta.');
      return;
    }
    if (!bothPointsSelected) {
      Get.snackbar('Error', 'Debes seleccionar punto de inicio y destino.');
      return;
    }
    if (name.trim().isEmpty) {
      Get.snackbar('Error', 'El nombre de la ruta es obligatorio.');
      return;
    }
    if (sport.trim().isEmpty) {
      Get.snackbar('Error', 'Por favor, selecciona un deporte.');
      return;
    }

    final String? currentUserId = _authController.user.value?.$id;
    if (currentUserId == null) {
      Get.snackbar('Error', 'No se pudo obtener el ID de usuario. Vuelve a iniciar sesión.');
      return;
    }

    // Asegurarse de que `distance` y `duration` no sean nulos para Appwrite
    final double actualDistance = estimatedDistance ?? 0.0; // Provee un valor por defecto si es null
    final int actualDuration = calculateEstimatedDurationInSeconds(actualDistance, sport) ?? 0; // Provee un valor por defecto si es null

    try {
      isSaving.value = true;

      final newRoute = RouteModel(
        id: null,
        userId: currentUserId,
        name: name.trim(),
        startLatitude: startPoint.value!.latitude,
        startLongitude: startPoint.value!.longitude,
        endLatitude: endPoint.value!.latitude,
        endLongitude: endPoint.value!.longitude,
        distance: actualDistance, // Usar el valor no nulo
        duration: actualDuration, // Usar el valor no nulo
        createdAt: DateTime.now(),
        description: description?.trim(),
        sport: sport,
        difficulty: difficulty?.isEmpty == true ? null : difficulty,
      );

      final savedRoute = await _appwriteService.createUserRoute(newRoute);

      routes.insert(0, savedRoute);

      Get.snackbar(
        'Éxito',
        'Ruta "$name" guardada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      resetRouteCreation();
    } catch (e) {
      print('RouteController: Error al guardar ruta: $e');
      Get.snackbar(
        'Error',
        'No se pudo guardar la ruta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteRoute(String routeId) async {
    try {
      isLoading.value = true;

      await _appwriteService.deleteUserRoute(routeId);
      routes.removeWhere((route) => route.id == routeId);

      Get.snackbar(
        'Éxito',
        'Ruta eliminada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('RouteController: Error al eliminar ruta: $e');
      Get.snackbar(
        'Error',
        'No se pudo eliminar la ruta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateRoute(RouteModel updatedRoute) async {
    try {
      isLoading.value = true;

      if (updatedRoute.id == null) {
        throw Exception("No se puede actualizar la ruta: El ID de la ruta es nulo.");
      }

      final updated = await _appwriteService.updateUserRoute(
        updatedRoute.id!,
        updatedRoute,
      );

      final index = routes.indexWhere((route) => route.id == updatedRoute.id);
      if (index != -1) {
        routes[index] = updated;
      }

      Get.snackbar(
        'Éxito',
        'Ruta actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('RouteController: Error al actualizar ruta: $e');
      Get.snackbar(
        'Error',
        'No se pudo actualizar la ruta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchRoutes(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      await loadUserRoutes();
      return;
    }

    try {
      isLoading.value = true;
      final searchResults = await _appwriteService.searchUserRoutes(searchTerm);
      routes.value = searchResults;
    } catch (e) {
      print('RouteController: Error al buscar rutas: $e');
      Get.snackbar(
        'Error',
        'Error en la búsqueda: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<RouteModel?> getRouteById(String id) async {
    try {
      final localRoute = routes.firstWhereOrNull((route) => route.id == id);
      if (localRoute != null) {
        return localRoute;
      }
      return await _appwriteService.getUserRouteById(id);
    } catch (e) {
      print('RouteController: Error al obtener ruta por ID: $e');
      return null;
    }
  }

  Map<String, dynamic> getRouteStatistics() {
    if (routes.isEmpty) {
      return {
        'totalRoutes': 0,
        'totalDistance': 0.0,
        'averageDistance': 0.0,
        'longestRoute': null,
        'shortestRoute': null,
        'sportBreakdown': <String, int>{},
      };
    }

    // Aquí, distance y duration son siempre no nulos según el modelo
    final totalDistance = routes.map((r) => r.distance).reduce((a, b) => a + b);
    final averageDistance = totalDistance / routes.length;
    final longestRoute = routes.reduce((a, b) => a.distance > b.distance ? a : b);
    final shortestRoute = routes.reduce((a, b) => a.distance < b.distance ? a : b);

    final sportBreakdown = <String, int>{};
    for (final route in routes) {
      if (route.sport.isNotEmpty) {
        sportBreakdown[route.sport] = (sportBreakdown[route.sport] ?? 0) + 1;
      }
    }

    return {
      'totalRoutes': routes.length,
      'totalDistance': totalDistance,
      'averageDistance': averageDistance,
      'longestRoute': longestRoute,
      'shortestRoute': shortestRoute,
      'sportBreakdown': sportBreakdown,
    };
  }

  String formatDistance(double? distanceInMeters) {
    if (distanceInMeters == null) return 'N/A'; // Aunque ahora siempre debería ser no nulo
    return distanceInMeters < 1000
        ? '${distanceInMeters.toStringAsFixed(0)} m'
        : '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
  }

  String getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'running':
        return '🏃';
      case 'ciclismo':
        return '🚴';
      case 'senderismo':
        return '🥾';
      default:
        return '❓';
    }
  }

  Future<void> refreshRoutes() async {
    await loadUserRoutes();
  }
}