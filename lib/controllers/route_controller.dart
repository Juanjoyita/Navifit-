// lib/controllers/route_controller.dart
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geodesy/geodesy.dart';
import '../models/route_model.dart';
import '../services/appwrite_service.dart';
import 'auth_controller.dart';
import 'sport_controller.dart'; // ¡Importación correcta!
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter/material.dart';

class RouteController extends GetxController {
  final AppwriteService _appwriteService = Get.find<AppwriteService>();
  final AuthController _authController = Get.find<AuthController>();
  final SportController sportController = Get.find<SportController>(); // Instancia correcta

  // Renombrado para mayor claridad
  var userRoutes = <RouteModel>[].obs;
  var isSelectingStartPoint = true.obs;
  var startPoint = Rxn<LatLng>();
  var endPoint = Rxn<LatLng>();
  var isCreatingRoute = false.obs;
  var selectedRoute = Rxn<RouteModel>(); // Para manejar la ruta seleccionada en detalle
  var isLoading = false.obs; // Estado general de carga (ej. al cargar rutas)
  var isSaving = false.obs; // Estado específico para operaciones de guardado/actualización

  @override
  void onInit() {
    super.onInit();
    // Reacciona a los cambios en el usuario logueado
    ever(_authController.user, (appwrite_models.User? user) {
      if (user != null) {
        print('RouteController: Usuario logueado (${user.$id}), cargando rutas...');
        loadUserRoutes();
      } else {
        print('RouteController: Usuario deslogueado, limpiando rutas.');
        userRoutes.clear(); // Limpiar la lista de rutas si el usuario se desloguea
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
      Get.snackbar('Punto de Inicio', 'Punto de inicio seleccionado. Ahora selecciona el punto final.');
    } else {
      endPoint.value = point;
      Get.snackbar('Punto Final', 'Punto final seleccionado. ¡Ruta lista para guardar!');
    }
  }

  bool get bothPointsSelected => startPoint.value != null && endPoint.value != null;

  double? get estimatedDistance {
    if (!bothPointsSelected) return null;
    const Distance distance = Distance();
    // La clase LatLng de latlong2 ya es compatible
    return distance.as(LengthUnit.Meter, startPoint.value!, endPoint.value!);
  }

  int? calculateEstimatedDurationInSeconds(double? distanceInMeters, String sport) {
    if (distanceInMeters == null || distanceInMeters <= 0 || sport.isEmpty) return null;

    double speedMPS; // Metros por segundo

    // Es bueno tener estas velocidades centralizadas, por ejemplo, en SportController
    // Pero por ahora, el switch aquí es funcional.
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
      case 'caminata':
        speedMPS = 1.4; // ~5 km/h
        break;
      case 'natacion': // Asegúrate que el string de deporte coincida (ej: 'natacion' vs 'natación')
        speedMPS = 0.8; // ~2.88 km/h
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

  String formatDistance(double? distanceInMeters) {
    if (distanceInMeters == null) return 'N/A';
    // Muestra en metros si es menos de 1km, de lo contrario en km
    return distanceInMeters < 1000
        ? '${distanceInMeters.toStringAsFixed(0)} m'
        : '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
  }

  // Carga las rutas del usuario actualmente logueado
  Future<void> loadUserRoutes() async {
    if (_authController.user.value == null) {
      print('RouteController: No hay usuario logueado. No se pueden cargar rutas.');
      userRoutes.clear();
      return;
    }
    try {
      isLoading.value = true;
      final fetchedRoutes = await _appwriteService.getUserRoutes();
      userRoutes.value = fetchedRoutes; // Actualiza la lista reactiva
      print('RouteController: ${fetchedRoutes.length} rutas cargadas.');
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

  // Guarda una nueva ruta en Appwrite
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

    final double actualDistance = estimatedDistance ?? 0.0;
    final int actualDuration = calculateEstimatedDurationInSeconds(actualDistance, sport) ?? 0;

    try {
      isSaving.value = true; // Inicia el estado de guardado

      final newRoute = RouteModel(
        id: null, // El ID lo asignará Appwrite
        userId: currentUserId,
        name: name.trim(),
        startLatitude: startPoint.value!.latitude,
        startLongitude: startPoint.value!.longitude,
        endLatitude: endPoint.value!.latitude,
        endLongitude: endPoint.value!.longitude,
        distance: actualDistance,
        duration: actualDuration,
        createdAt: DateTime.now(), // La fecha de creación se genera aquí
        description: description?.trim(),
        sport: sport,
        // Si la dificultad es vacía, guárdala como null
        difficulty: difficulty?.isEmpty == true ? null : difficulty,
        isCompleted: false, // Por defecto, una ruta nueva no está completada
        completedAt: null,
      );

      final savedRoute = await _appwriteService.createUserRoute(newRoute);

      userRoutes.insert(0, savedRoute); // Añade la nueva ruta al principio de la lista

      Get.snackbar(
        'Éxito',
        'Ruta "$name" guardada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      resetRouteCreation(); // Limpia los puntos de selección
      Get.back(); // Regresa a la pantalla anterior (ej. mapa o lista)
    } catch (e) {
      print('RouteController: Error al guardar ruta: $e');
      Get.snackbar(
        'Error',
        'No se pudo guardar la ruta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false; // Finaliza el estado de guardado
    }
  }

  // Elimina una ruta de Appwrite
  Future<void> deleteRoute(String routeId) async {
    try {
      isLoading.value = true; // Podrías usar isDeleting para granularidad

      await _appwriteService.deleteUserRoute(routeId);
      userRoutes.removeWhere((route) => route.id == routeId); // Elimina de la lista local

      Get.snackbar(
        'Éxito',
        'Ruta eliminada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      print('RouteController: Error al eliminar ruta: $e');
      Get.snackbar(
        'Error',
        'No se pudo eliminar la ruta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Actualiza una ruta existente en Appwrite
  Future<void> updateRoute(RouteModel updatedRoute) async {
    try {
      isSaving.value = true; // Usamos isSaving para actualización también

      if (updatedRoute.id == null) {
        throw Exception("No se puede actualizar la ruta: El ID de la ruta es nulo.");
      }

      final updated = await _appwriteService.updateUserRoute(
        updatedRoute.id!,
        updatedRoute,
      );

      // Actualiza la ruta en la lista reactiva
      final index = userRoutes.indexWhere((route) => route.id == updatedRoute.id);
      if (index != -1) {
        userRoutes[index] = updated;
      }

      Get.snackbar(
        'Éxito',
        'Ruta actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      print('RouteController: Error al actualizar ruta: $e');
      Get.snackbar(
        'Error',
        'No se pudo actualizar la ruta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Marca una ruta como completada
  Future<void> markRouteAsCompleted(String routeId) async {
    try {
      isSaving.value = true; // Usar isSaving para esta operación

      final routeToUpdate = userRoutes.firstWhereOrNull((route) => route.id == routeId);

      if (routeToUpdate == null) {
        Get.snackbar('Error', 'Ruta no encontrada para marcar como completada.');
        return;
      }

      if (routeToUpdate.isCompleted) {
        Get.snackbar('Información', 'Esta ruta ya ha sido marcada como completada.');
        return;
      }

      // Crear una nueva instancia con los cambios
      final updatedRoute = routeToUpdate.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      await updateRoute(updatedRoute); // Usa el método updateRoute ya existente

      // La actualización de userRoutes ya se maneja dentro de updateRoute
      Get.snackbar(
        '¡Ruta Completada!',
        'Has finalizado la ruta "${updatedRoute.name}" con éxito.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blueAccent.withOpacity(0.9),
        colorText: Colors.white,
        icon: Icon(Icons.celebration, color: Colors.white),
      );
    } catch (e) {
      print('RouteController: Error al marcar ruta como completada: $e');
      Get.snackbar(
        'Error',
        'No se pudo marcar la ruta como completada: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // Busca rutas por término de búsqueda (ej. nombre o descripción)
  Future<void> searchRoutes(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      await loadUserRoutes(); // Si la búsqueda está vacía, cargar todas las rutas
      return;
    }

    try {
      isLoading.value = true;
      final searchResults = await _appwriteService.searchUserRoutes(searchTerm);
      userRoutes.value = searchResults;
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

  // Obtiene una ruta específica por su ID
  Future<RouteModel?> getRouteById(String id) async {
    try {
      // Primero busca en la lista local para evitar una llamada a la API si ya está
      final localRoute = userRoutes.firstWhereOrNull((route) => route.id == id);
      if (localRoute != null) {
        return localRoute;
      }
      // Si no está en la lista local, busca en Appwrite
      return await _appwriteService.getUserRouteById(id);
    } catch (e) {
      print('RouteController: Error al obtener ruta por ID: $e');
      return null;
    }
  }

  // Calcula estadísticas de las rutas del usuario
  Map<String, dynamic> getRouteStatistics() {
    if (userRoutes.isEmpty) {
      return {
        'totalRoutes': 0,
        'totalDistance': 0.0,
        'averageDistance': 0.0,
        'longestRoute': null,
        'shortestRoute': null,
        'sportBreakdown': <String, int>{},
        'completedRoutes': 0,
      };
    }

    final totalDistance = userRoutes.map((r) => r.distance).reduce((a, b) => a + b);
    final averageDistance = totalDistance / userRoutes.length;
    final longestRoute = userRoutes.reduce((a, b) => a.distance > b.distance ? a : b);
    final shortestRoute = userRoutes.reduce((a, b) => a.distance < b.distance ? a : b);
    final completedRoutesCount = userRoutes.where((route) => route.isCompleted).length;


    final sportBreakdown = <String, int>{};
    for (final route in userRoutes) {
      if (route.sport.isNotEmpty) {
        sportBreakdown[route.sport] = (sportBreakdown[route.sport] ?? 0) + 1;
      }
    }

    return {
      'totalRoutes': userRoutes.length,
      'totalDistance': totalDistance,
      'averageDistance': averageDistance,
      'longestRoute': longestRoute,
      'shortestRoute': shortestRoute,
      'sportBreakdown': sportBreakdown,
      'completedRoutes': completedRoutesCount,
    };
  }

  // Método para refrescar la lista de rutas
  Future<void> refreshRoutes() async {
    await loadUserRoutes();
  }
}