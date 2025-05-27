import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart'; // Asegúrate de tenerlo en pubspec.yaml

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
import 'package:versus_match/screens/mission_details.dart'; // Asegúrate de que esta importación sea correcta

// Servicios
import 'services/appwrite_service.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura el cliente de Appwrite UNA SOLA VEZ y correctamente
  final Client client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1') // ¡VERIFICA TU ENDPOINT!
      .setProject('67f4970e00257170a0c8')                 // <-- ¡VERIFICA TU PROJECT ID!
      .setSelfSigned(status: true); // Solo si usas localhost o entorno sin SSL.
                                    // Para producción, esto suele ser false o se omite.

  // Inyección de dependencias de AppwriteService (que requiere el Client)
  final AppwriteService appwriteService = AppwriteService(client: client);
  Get.put(appwriteService); // Ahora el servicio está disponible en GetX

  // Inyección de dependencias de AuthController (que ahora requiere el Client)
  Get.put(AuthController(appwriteClient: client));

  // Inyección de dependencias de MissionController (que requiere AppwriteService)
  Get.put(MissionController(appwriteService: appwriteService));

  // Otros controladores que no dependen directamente del Client de Appwrite o AppwriteService
  Get.put(SportController());
  Get.put(RouteController());
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