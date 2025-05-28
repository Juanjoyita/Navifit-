// lib/controllers/route_controller.dart
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:geodesy/geodesy.dart'; // Necesario para la clase Distance
import '../models/route_model.dart';
import '../services/appwrite_service.dart';
import 'auth_controller.dart'; // Importar AuthController
import 'package:appwrite/models.dart' as appwrite_models; // Importar el modelo User de Appwrite

class RouteController extends GetxController {
  final AppwriteService _appwriteService = Get.find();
  final AuthController _authController = Get.find(); // Obtener AuthController

  // Observables para la gestión de rutas y UI
  var routes = <RouteModel>[].obs;
  var isSelectingStartPoint = true.obs;
  var startPoint = Rxn<LatLng>();
  var endPoint = Rxn<LatLng>();
  var isCreatingRoute = false.obs; // Para controlar el flujo de creación de ruta
  var selectedRoute = Rxn<RouteModel>(); // Para ver/editar una ruta existente
  var isLoading = false.obs; // Para operaciones de carga de datos
  var isSaving = false.obs; // Para operaciones de guardado de datos

  @override
  void onInit() {
    super.onInit();
    // Reaccionar a cambios en el usuario logueado
    // AHORA USAMOS _authController.user.value
    ever(_authController.user, (appwrite_models.User? user) { // <-- CAMBIO AQUÍ: _authController.user
      if (user != null) {
        print('RouteController: Usuario logueado (${user.$id}), cargando rutas...');
        loadUserRoutes();
      } else {
        print('RouteController: Usuario deslogueado, limpiando rutas.');
        routes.clear();
      }
    });
  }

  // ============== MÉTODOS DE GESTIÓN DE ESTADO DE LA RUTA EN EL MAPA ==============

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
      // Una vez que se seleccionan ambos puntos, puedes decidir iniciar el proceso de guardado o no.
      // isCreatingRoute.value = true; // Esto lo puedes activar si quieres que la UI cambie a un estado de "creando"
    }
  }

  // Getter para saber si ambos puntos han sido seleccionados
  bool get bothPointsSelected => startPoint.value != null && endPoint.value != null;

  // Getter para la distancia estimada en metros
  double? get estimatedDistance {
    if (!bothPointsSelected) return null;
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, startPoint.value!, endPoint.value!);
  }

  // ============== MÉTODOS DE CÁLCULO DE DURACIÓN ==============

  // Método para estimar la duración en segundos basado en el deporte y la distancia
  int? calculateEstimatedDurationInSeconds(double? distanceInMeters, String sport) {
    if (distanceInMeters == null || distanceInMeters <= 0 || sport.isEmpty) return null;

    double speedMPS; // Metros por segundo

    // Velocidades estimadas (ajusta estos valores según tus necesidades reales)
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
      // Añade otros deportes aquí si los usas en el futuro.
      default:
        speedMPS = 1.39; // Velocidad de caminata por defecto si el deporte no está mapeado
    }
    return (distanceInMeters / speedMPS).round(); // Redondea a segundos enteros
  }

  // Método para formatear la duración de segundos a un formato legible (ej. 1h 30min)
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

  // ============== MÉTODOS DE INTERACCIÓN CON APPWRITE ==============

  // Carga las rutas del usuario actual desde Appwrite
  Future<void> loadUserRoutes() async {
    // AHORA USAMOS _authController.user.value
    if (_authController.user.value == null) { // <-- CAMBIO AQUÍ: _authController.user
      print('RouteController: No hay usuario logueado. No se pueden cargar rutas.');
      routes.clear();
      return;
    }
    try {
      isLoading.value = true;
      final userRoutes = await _appwriteService.getUserRoutes();
      routes.value = userRoutes; // Actualiza la lista observable de rutas
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

  // Guarda una nueva ruta en Appwrite
  Future<void> saveRoute({
    required String name,
    String? description,
    required String sport, // Asegúrate de que este valor proviene del UI
    String? difficulty,
  }) async {
    // AHORA USAMOS _authController.user.value
    if (_authController.user.value == null) { // <-- CAMBIO AQUÍ: _authController.user
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

    // AHORA USAMOS _authController.user.value
    final String? currentUserId = _authController.user.value?.$id; // <-- CAMBIO AQUÍ: _authController.user
    if (currentUserId == null) {
      Get.snackbar('Error', 'No se pudo obtener el ID de usuario. Vuelve a iniciar sesión.');
      return;
    }

    // Calcular la duración antes de crear el modelo
    final int? estimatedDuration = calculateEstimatedDurationInSeconds(estimatedDistance, sport);

    try {
      isSaving.value = true; // Indica que se está guardando

      final newRoute = RouteModel(
        id: null, // Appwrite asignará el ID automáticamente
        userId: currentUserId,
        name: name.trim(),
        startPoint: startPoint.value!,
        endPoint: endPoint.value!,
        distance: estimatedDistance,
        createdAt: DateTime.now(),
        description: description?.trim(),
        sport: sport,
        difficulty: difficulty?.isEmpty == true ? null : difficulty,
        duration: estimatedDuration,
      );

      final savedRoute = await _appwriteService.createUserRoute(newRoute);

      routes.insert(0, savedRoute); // Añade la nueva ruta a la lista observable

      Get.snackbar(
        'Éxito',
        'Ruta "$name" guardada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      resetRouteCreation(); // Limpia los puntos del mapa para una nueva creación
    } catch (e) {
      print('RouteController: Error al guardar ruta: $e');
      Get.snackbar(
        'Error',
        'No se pudo guardar la ruta: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false; // Finaliza la operación de guardado
    }
  }

  // Elimina una ruta por su ID
  Future<void> deleteRoute(String routeId) async {
    try {
      isLoading.value = true; // Indica que se está cargando/modificando

      await _appwriteService.deleteUserRoute(routeId);
      routes.removeWhere((route) => route.id == routeId); // Elimina de la lista observable

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

  // Actualiza una ruta existente en Appwrite
  Future<void> updateRoute(RouteModel updatedRoute) async {
    try {
      isLoading.value = true;

      // Asegúrate de que el ID de la ruta no sea nulo para la actualización
      if (updatedRoute.id == null) {
        throw Exception("No se puede actualizar la ruta: El ID de la ruta es nulo.");
      }

      // La llamada a updateUserRoute espera un String no nulo para el ID
      final updated = await _appwriteService.updateUserRoute(
        updatedRoute.id!, // Usamos '!' para asegurar que no es nulo aquí, ya que lo hemos comprobado.
        updatedRoute,
      );

      final index = routes.indexWhere((route) => route.id == updatedRoute.id);
      if (index != -1) {
        routes[index] = updated; // Actualiza la ruta en la lista observable
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

  // Busca rutas por un término de búsqueda
  Future<void> searchRoutes(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      await loadUserRoutes(); // Si la búsqueda está vacía, carga todas las rutas de nuevo
      return;
    }

    try {
      isLoading.value = true;
      final searchResults = await _appwriteService.searchUserRoutes(searchTerm);
      routes.value = searchResults; // Actualiza la lista con los resultados de la búsqueda
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

  // Obtiene una ruta por su ID (primero busca en la lista local, luego en Appwrite)
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

  // Genera estadísticas de las rutas cargadas
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

    final routesWithDistance = routes.where((r) => r.distance != null && r.distance! > 0).toList();

    // Estadísticas por deporte
    final sportBreakdown = <String, int>{};
    for (final route in routes) {
      if (route.sport.isNotEmpty) {
        sportBreakdown[route.sport] = (sportBreakdown[route.sport] ?? 0) + 1;
      }
    }

    if (routesWithDistance.isEmpty) {
      return {
        'totalRoutes': routes.length,
        'totalDistance': 0.0,
        'averageDistance': 0.0,
        'longestRoute': null,
        'shortestRoute': null,
        'sportBreakdown': sportBreakdown,
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
      'sportBreakdown': sportBreakdown,
    };
  }

  // ============== MÉTODOS DE UTILIDAD PARA LA UI ==============

  String formatDistance(double? distanceInMeters) {
    if (distanceInMeters == null) return 'N/A';
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
      // Añade otros iconos para deportes si los agregas a la lista en SportController
      default:
        return '❓';
    }
  }

  Future<void> refreshRoutes() async {
    await loadUserRoutes();
  }
}