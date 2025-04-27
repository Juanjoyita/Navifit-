import 'package:get/get.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationController extends GetxController {
  final LocationService _locationService = LocationService();
  var currentPosition = Rxn<Position>();

  Future<void> updateLocation() async {
    currentPosition.value = await _locationService.getCurrentLocation();
  }
}
