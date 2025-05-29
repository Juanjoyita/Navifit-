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
  var selectedRoute = Rxn<RouteModel>();
  var isLoading = false.obs; 
  var isSaving = false.obs; 

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

    double speedMPS; 

    switch (sport.toLowerCase()) {
      case 'running':
        speedMPS = 3.5; 
        break;
      case 'ciclismo':
        speedMPS = 6.0; 
        break;
      case 'senderismo':
        speedMPS = 1.0; 
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
      isSaving.value = true; 

      final newRoute = RouteModel(
        id: null,
        userId: currentUserId,
        name: name.trim(),
        startLatitude: startPoint.value!.latitude,
        startLongitude: startPoint.value!.longitude,
        endLatitude: endPoint.value!.latitude,
        endLongitude: endPoint.value!.longitude,
        distance: actualDistance,
        duration: actualDuration,
        createdAt: DateTime.now(), 
        description: description?.trim(),
        sport: sport,
        difficulty: difficulty?.isEmpty == true ? null : difficulty,
      );

      final savedRoute = await _appwriteService.createUserRoute(newRoute);

      userRoutes.insert(0, savedRoute); 

      Get.snackbar(
        'Éxito',
        'Ruta "$name" guardada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      resetRouteCreation(); 
      Get.back(); 
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
      isSaving.value = false; 
    }
  }

  // Elimina una ruta de Appwrite
  Future<void> deleteRoute(String routeId) async {
    try {
      isLoading.value = true; 

      await _appwriteService.deleteUserRoute(routeId);
      userRoutes.removeWhere((route) => route.id == routeId); 

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


  // Busca rutas por término de búsqueda 
  Future<void> searchRoutes(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      await loadUserRoutes(); 
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

      };
    }

    final totalDistance = userRoutes.map((r) => r.distance).reduce((a, b) => a + b);
    final averageDistance = totalDistance / userRoutes.length;
    final longestRoute = userRoutes.reduce((a, b) => a.distance > b.distance ? a : b);
    final shortestRoute = userRoutes.reduce((a, b) => a.distance < b.distance ? a : b);
    


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

    };
  }

  // Método para refrescar la lista de rutas
  Future<void> refreshRoutes() async {
    await loadUserRoutes();
  }
}