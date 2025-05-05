import 'package:get/get.dart';
import '../models/mission_model.dart';
import '../services/appwrite_service.dart';

class MissionController extends GetxController {
  final AppwriteService appwriteService;

  MissionController({required this.appwriteService});

  var missions = <Mission>[].obs;
  var isLoading = false.obs;

  Future<void> fetchMissions(String sport, String difficulty) async {
    isLoading.value = true;
    final result = await appwriteService.getMissions(sport: sport, difficulty: difficulty);
    missions.value = result;
    isLoading.value = false;
  }
}
