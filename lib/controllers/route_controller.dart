import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_model.dart';
import '../services/appwrite_service.dart';

class RouteController extends GetxController {
  final AppwriteService _appwriteService = Get.find();
  
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
    loadUserRoutes();
  }

  // ============== MÉTODOS DE GESTIÓN DE ESTADO ==============

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

  // ============== MÉTODOS DE APPWRITE ==============

  Future<void> loadUserRoutes() async {
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
  }) async {
    if (!bothPointsSelected) {
      Get.snackbar('Error', 'Debes seleccionar punto de inicio y destino');
      return;
    }

    if (name.trim().isEmpty) {
      Get.snackbar('Error', 'El nombre de la ruta es obligatorio');
      return;
    }

    try {
      isSaving.value = true;

      final newRoute = RouteModel(
        id: '',
        name: name.trim(),
        startPoint: startPoint.value!,
        endPoint: endPoint.value!,
        distance: estimatedDistance,
        createdAt: DateTime.now(),
        description: description?.trim(),
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

      final updated = await _appwriteService.updateUserRoute(
        updatedRoute.id,
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
      };
    }

    final routesWithDistance = routes.where((r) => r.distance != null).toList();

    if (routesWithDistance.isEmpty) {
      return {
        'totalRoutes': routes.length,
        'totalDistance': 0.0,
        'averageDistance': 0.0,
        'longestRoute': null,
        'shortestRoute': null,
      };
    }

    final totalDistance = routesWithDistance
        .map((r) => r.distance!)
        .reduce((a, b) => a + b);
    final averageDistance = totalDistance / routesWithDistance.length;
    final longestRoute = routesWithDistance.reduce((a, b) => a.distance! > b.distance! ? a : b);
    final shortestRoute = routesWithDistance.reduce((a, b) => a.distance! < b.distance! ? a : b);

    return {
      'totalRoutes': routes.length,
      'totalDistance': totalDistance,
      'averageDistance': averageDistance,
      'longestRoute': longestRoute,
      'shortestRoute': shortestRoute,
    };
  }

  // ============== MÉTODOS DE UTILIDAD ==============

  String formatDistance(double? distanceInMeters) {
    if (distanceInMeters == null) return 'N/A';
    return distanceInMeters < 1000
        ? '${distanceInMeters.toStringAsFixed(0)} m'
        : '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
  }

  String estimateWalkingTime(double? distanceInMeters) {
    if (distanceInMeters == null) return 'N/A';
    const walkingSpeedMPS = 1.39;
    final timeInSeconds = distanceInMeters / walkingSpeedMPS;

    if (timeInSeconds < 60) {
      return '${timeInSeconds.toStringAsFixed(0)} seg';
    } else if (timeInSeconds < 3600) {
      return '${(timeInSeconds / 60).toStringAsFixed(0)} min';
    } else {
      final hours = (timeInSeconds / 3600).floor();
      final minutes = ((timeInSeconds % 3600) / 60).floor();
      return '${hours}h ${minutes}min';
    }
  }

  Future<void> refreshRoutes() async {
    await loadUserRoutes();
  }
}
