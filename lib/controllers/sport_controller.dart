import 'package:get/get.dart';

class SportController extends GetxController {
  var sports = ['Running', 'Ciclismo', 'Senderismo'].obs;
  var selectedSport = ''.obs;
  var selectedDifficulty = ''.obs;

  void selectSport(String sport) {
    selectedSport.value = sport;
  }

  void selectDifficulty(String difficulty) {
    selectedDifficulty.value = difficulty;
  }

  bool isValidSelection() {
    return selectedSport.isNotEmpty && selectedDifficulty.isNotEmpty;
  }
}
