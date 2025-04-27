import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  final box = GetStorage();

  void saveSport(String sportId) {
    box.write('selected_sport', sportId);
  }

  String? getSelectedSport() {
    return box.read('selected_sport');
  }
}
