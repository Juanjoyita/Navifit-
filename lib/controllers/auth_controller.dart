// lib/controllers/auth_controller.dart

import 'package:get/get.dart';
import '../services/appwrite_service.dart';
import 'package:appwrite/models.dart' as models;

class AuthController extends GetxController {
  final AppwriteService _appwriteService = AppwriteService();

  // Variables reactivas
  var isLoading = false.obs;
  var user = Rxn<models.User>();

  // Método para registrar un usuario
  Future<void> register(String email, String password, String name) async {
    try {
      isLoading.value = true;
      await _appwriteService.register(email: email, password: password, name: name);
      Get.snackbar('Registro exitoso', 'Ahora puedes iniciar sesión');
      Get.back(); // Después de registrar, vuelve a la pantalla de login
    } catch (e) {
      Get.snackbar('Error de Registro', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Método para iniciar sesión
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _appwriteService.login(email: email, password: password);
      await fetchUser();
      Get.offAllNamed('/selectSport'); // Redireccionar a seleccionar deporte
    } catch (e) {
      Get.snackbar('Error de Login', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Método para obtener el usuario actual
  Future<void> fetchUser() async {
    try {
      user.value = await _appwriteService.getCurrentUser();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo obtener el usuario');
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    try {
      await _appwriteService.logout();
      user.value = null;
      Get.offAllNamed('/login'); // Redireccionar al login
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cerrar sesión');
    }
  }
}
