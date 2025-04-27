import 'package:get/get.dart';
import '../models/route_model.dart';

class RouteController extends GetxController {
  var routes = <RouteModel>[].obs;

  void addRoute(RouteModel route) {
    routes.add(route);
  }
}
