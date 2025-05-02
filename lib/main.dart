import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controladores
import 'controllers/auth_controller.dart';
import 'controllers/sport_controller.dart';
import 'controllers/route_controller.dart';
import 'controllers/location_controller.dart';

// Pantallas
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/select_sport_screen.dart';
import 'screens/route_list_screen.dart';
import 'screens/create_route_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/map_screen.dart' as map_screen;               // Pantalla 4

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final SportController sportController = Get.put(SportController());
  final RouteController routeController = Get.put(RouteController());
  final LocationController locationController = Get.put(LocationController());

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deportes App',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/selectSport', page: () => SelectSportScreen()),
        GetPage(name: '/createRoute', page: () => CreateRouteScreen()),
        GetPage(name: '/profile', page: () => ProfileScreen()),
        GetPage(name: '/map', page: () => const map_screen.MapScreen()),          // Pantalla 4

      ],
    );
  }
}
