import 'package:get/get.dart';
import '../models/sport_model.dart';

class SportController extends GetxController {
  var sports = <SportModel>[
    SportModel(id: '1', name: 'Running'),
    SportModel(id: '2', name: 'Senderismo'),
    SportModel(id: '3', name: 'Ciclismo'),
  ].obs;

  var selectedSport = Rxn<SportModel>();

  void selectSport(SportModel sport) {
    selectedSport.value = sport;
  }
}
