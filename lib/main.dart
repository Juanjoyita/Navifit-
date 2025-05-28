// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';

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
import 'screens/map_screen.dart' as map_screen;
import 'screens/mission_route_screen.dart';
import 'package:versus_match/screens/mission_details.dart';

// Servicios
import 'services/appwrite_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura el cliente de Appwrite
  final Client client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('67f4970e00257170a0c8')
      .setSelfSigned(status: true);

  // Inyección de dependencias de AppwriteService (PRIMERO Y ÚNICO)
  Get.put(AppwriteService(client: client)); // Instancia única de AppwriteService

  // Obtén la instancia de AppwriteService que acabas de inyectar
  final AppwriteService appwriteService = Get.find<AppwriteService>();

  // Inyecta los controladores, pasándoles la instancia compartida de AppwriteService
  Get.put(AuthController()); // AuthController ahora usará Get.find() para AppwriteService
  Get.put(MissionController(appwriteService: appwriteService));
  Get.put(RouteController()); // RouteController ahora usará Get.find() para AppwriteService

  // Otros controladores independientes
  Get.put(SportController());
  Get.put(LocationController());

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
        GetPage(name: '/map', page: () => const map_screen.MapScreen()),
        GetPage(name: '/missionRoute', page: () => const MissionRouteScreen()),
        GetPage(name: '/missionDetail', page: () => const MissionDetailScreen()),
      ],
    );
  }
}