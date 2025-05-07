import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart'; // Asegúrate de tenerlo en pubspec.yaml
import 'dart:convert';

// Controladores
import 'controllers/auth_controller.dart';
import 'controllers/sport_controller.dart';
import 'controllers/route_controller.dart';
import 'controllers/location_controller.dart';
import 'controllers/mission_controller.dart';

// Pantallas
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/select_sport_screen.dart';
import 'screens/create_route_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/map_screen.dart' as map_screen; // Pantalla 4
import 'screens/mission_route_screen.dart';     // Pantalla 5

// Servicios
import 'services/appwrite_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura el cliente de Appwrite
  final client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1') // Reemplaza si usas otro endpoint
      .setProject('67f4970e00257170a0c8')                 // <-- Reemplaza con tu Project ID
      .setSelfSigned(status: true); // Solo si usas localhost o entorno sin SSL

  // Inyecciones de dependencias
  final databases = Databases(client);
  final appwriteService = AppwriteService(databases); // Use databases variable here

  Get.put(AuthController(databases));
  Get.put(SportController());
  Get.put(RouteController());
  Get.put(LocationController());
  Get.put(appwriteService);
  Get.put(MissionController(appwriteService: appwriteService));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        GetPage(name: '/map', page: () => const map_screen.MapScreen()), // Pantalla 4
        GetPage(name: '/missionRoute', page: () => const MissionRouteScreen()), // Pantalla 5
      ],
    );
  }
}
