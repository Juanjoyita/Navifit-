// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart'; // Mantienes esta importación para configurar el cliente aquí

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
import 'screens/route_detail_screen.dart';


// Servicios
import 'services/appwrite_service.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura el cliente de Appwrite (mantengo tu estructura actual)
  final Client client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('67f4970e00257170a0c8')
      .setSelfSigned(status: true); // Solo en desarrollo/prueba

  // Inyectar el servicio compartido
  Get.put(AppwriteService(client: client));
  final AppwriteService appwriteService = Get.find<AppwriteService>();

  // ***** ORDEN DE INYECCIÓN DE DEPENDENCIAS CORREGIDO *****
  // ⚠️ Importante: primero los controladores que se usan dentro de otros o que no tienen dependencias circulares.
  Get.put(SportController());
  Get.put(LocationController());

  // Luego los que dependen de AppwriteService o de otros controladores ya inyectados
  // Asegúrate de que AuthController y RouteController se inyecten después de AppwriteService
  Get.put(AuthController());
  Get.put(MissionController(appwriteService: appwriteService));
  Get.put(RouteController()); // Este ahora encontrará SportController, si lo usa internamente.

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
        GetPage(name: '/routeDetail', page: () => const RouteDetailScreen()),
      ],
      // No se ha añadido ningún tema global aquí, según tu código actual.
    );
  }
}