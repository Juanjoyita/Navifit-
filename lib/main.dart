import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Importar los controladores
import 'controllers/auth_controller.dart';
import 'controllers/sport_controller.dart';
import 'controllers/route_controller.dart';
import 'controllers/location_controller.dart';

// Importar las pantallas
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/select_sport_screen.dart';
import 'screens/route_list_screen.dart';
import 'screens/create_route_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Inicializamos los controladores aquí para que estén disponibles en toda la app
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
        GetPage(name: '/', page: () => LoginScreen()), // Login inicial
        GetPage(name: '/register', page: () => RegisterScreen()), // Registro
        GetPage(name: '/selectSport', page: () => SelectSportScreen()), // Selección de deporte
        GetPage(name: '/routes', page: () => RouteListScreen()), // Lista de rutas
        GetPage(name: '/createRoute', page: () => CreateRouteScreen()), // Crear nueva ruta
        GetPage(name: '/profile', page: () => ProfileScreen()), // Perfil de usuario
      ],
    );
  }
}
