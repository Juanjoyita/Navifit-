// lib/controllers/mission_controller.dart
import 'package:get/get.dart';
import '../models/mission_model.dart';
import '../services/appwrite_service.dart';

class MissionController extends GetxController {
  final AppwriteService appwriteService;

  MissionController({required this.appwriteService});

  var missions = <Mission>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('MissionController onInit: Iniciando carga de misiones.');
    loadAllMissions();
  }

  // Método para cargar todas las misiones sin filtros iniciales
  Future<void> loadAllMissions() async {
    isLoading.value = true;
    errorMessage.value = ''; // Limpiar mensaje de error anterior
    try {
      print('loadAllMissions: Intentando obtener todas las misiones sin filtros...');
      final List<Mission> result = await appwriteService.getMissions();

      // <--- AÑADIR ESTOS PRINTS PARA DEPURACIÓN --->
      print('loadAllMissions: Misiones obtenidas del servicio (${result.length} documentos):');
      if (result.isEmpty) {
        print('  ¡La lista de resultados del servicio está VACÍA!');
      } else {
        for (var m in result) {
          print('  - ID: ${m.id}, Título: "${m.title}", Deporte: "${m.sport}", Dificultad: "${m.difficulty}"');
        }
      }
      // <--- FIN DE PRINTS DEPURACIÓN --->

      missions.assignAll(result); // Actualiza la lista observable
      print('loadAllMissions: Misiones cargadas exitosamente en observable: ${missions.length}');

      if (missions.isEmpty) {
        errorMessage.value = 'No se encontraron misiones disponibles.';
        print('loadAllMissions: Lista de misiones observable vacía.');
      }

    } catch (e) {
      errorMessage.value = 'Error al cargar misiones: $e';
      print('loadAllMissions: Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Tu método para buscar con filtros (no es el que se usa en onInit)
  Future<void> fetchMissions(String sport, String difficulty) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      print('fetchMissions: Buscando misiones por deporte: $sport, dificultad: $difficulty');
      final List<Mission> result = await appwriteService.getMissions(sport: sport, difficulty: difficulty);

      // <--- AÑADIR ESTOS PRINTS PARA DEPURACIÓN (si usas esta función) --->
      print('fetchMissions: Misiones filtradas obtenidas del servicio (${result.length}):');
      if (result.isEmpty) {
        print('  ¡La lista de resultados filtrados del servicio está VACÍA!');
      } else {
        for (var m in result) {
          print('  - ID: ${m.id}, Título: "${m.title}", Deporte: "${m.sport}", Dificultad: "${m.difficulty}"');
        }
      }
      // <--- FIN DE PRINTS DEPURACIÓN --->

      missions.assignAll(result);
      print('fetchMissions: Misiones filtradas cargadas en observable: ${missions.length}');

      if (missions.isEmpty) {
        errorMessage.value = 'No se encontraron misiones para los filtros seleccionados.';
        print('fetchMissions: Lista de misiones observable filtrada vacía.');
      }

    } catch (e) {
      errorMessage.value = 'Error al filtrar misiones: $e';
      print('fetchMissions: Error al filtrar: $e');
    } finally {
      isLoading.value = false;
    }
  }
}