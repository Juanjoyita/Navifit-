// lib/controllers/auth_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart'; // Necesario para Colors y Get.snackbar
import '../services/appwrite_service.dart';
import 'package:appwrite/models.dart' as models; // Para el modelo de User
import 'package:appwrite/appwrite.dart'; // Para AppwriteException y Client, Account
import 'package:intl/intl.dart'; // ¡Asegúrate de que esta importación esté presente!

class AuthController extends GetxController {
  // Obtiene la instancia de AppwriteService que ya fue inyectada
  final AppwriteService _appwriteService = Get.find<AppwriteService>();

  // Variables reactivas
  var isLoading = false.obs; // Para controlar el estado de carga general de las operaciones de auth
  var user = Rxn<models.User>(); // Observable para el usuario actual (puede ser nulo)
  var errorMessage = ''.obs; // Para mensajes de error detallados

  // Método para formatear la fecha de creación del usuario
  String formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return 'N/A';
    }
    try {
      final dateTime = DateTime.parse(isoString).toLocal(); // Convertir a hora local
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime); // Formato deseado
    } catch (e) {
      print('Error parsing date string: $e');
      return 'Fecha inválida';
    }
  }

  // REEMPLAZO DEL MÉTODO register CON LA VERSIÓN OPTIMIZADA QUE PROPORCIONASTE
  Future<void> register(String email, String password, String name) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Limpiar cualquier sesión residual antes de registrarse
      try {
        await _appwriteService.logout();
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        print('No hay sesión activa para cerrar antes de registro: $e');
      }

      // 1. Registrar al nuevo usuario
      await _appwriteService.register(
        email: email,
        password: password,
        name: name,
      );

      // 2. Iniciar sesión automáticamente después del registro
      await _appwriteService.login(email: email, password: password);

      // 3. Obtener los detalles del usuario recién logueado
      await fetchUser();

      // 4. Mostrar mensaje de bienvenida
      Get.snackbar(
        'Registro exitoso',
        '¡Bienvenido a NaviFit!',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // 5. Navegar directamente a la pantalla principal de la aplicación
      // Cambia '/profile' por la ruta que consideres como pantalla principal
      // Por ejemplo: '/selectSport', '/dashboard', '/home', etc.
      Get.offAllNamed('/selectSport'); // ⚠️ Cambia esta ruta según tu flujo de navegación

    } on AppwriteException catch (e) {
      errorMessage.value = e.message ?? 'Error de registro desconocido.';
      Get.snackbar(
        'Error de Registro',
        errorMessage.value,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      print('Error de Registro (AuthController): $e');
    } catch (e) {
      errorMessage.value = 'Error inesperado durante el registro: $e';
      Get.snackbar(
        'Error de Registro',
        errorMessage.value,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      print('Error inesperado de Registro (AuthController): $e');
    } finally {
      isLoading.value = false;
    }
  }


  // Método para iniciar sesión
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Limpiar errores anteriores
      // Intenta cerrar sesión activa antes de iniciar una nueva.
      try {
        await _appwriteService.logout();
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('No hay sesión activa para cerrar (Login): $e');
      }

      await _appwriteService.login(email: email, password: password);
      await fetchUser();
      Get.offAllNamed('/selectSport'); // Redirigir a la pantalla de perfil (o selectSport si es tu flujo)
      Get.snackbar(
        'Éxito',
        'Inicio de sesión exitoso.',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } on AppwriteException catch (e) {
      errorMessage.value = e.message ?? 'Credenciales incorrectas.';
      Get.snackbar(
        'Error de Login',
        errorMessage.value,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      print('Error de Login (AuthController): $e');
    } catch (e) {
      errorMessage.value = 'Error inesperado durante el login: $e';
      Get.snackbar(
        'Error de Login',
        errorMessage.value,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      print('Error inesperado de Login (AuthController): $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Método para obtener los detalles del usuario actual
  Future<void> fetchUser() async {
    try {
      user.value = await _appwriteService.getCurrentUser();
      print('Usuario cargado (AuthController): ${user.value?.email}');
    } on AppwriteException catch (e) {
      // Si el usuario no está autenticado, Appwrite lanza una excepción (401)
      if (e.code == 401) {
        user.value = null; // No hay usuario logeado
      } else {
        // Otros errores al cargar el usuario
        print('Error al obtener el usuario (AuthController): $e');
        // Puedes mostrar un snackbar si este fetchUser es crítico y no se maneja en la UI
      }
    } catch (e) {
      print('Error inesperado al obtener el usuario (AuthController): $e');
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    try {
      isLoading.value = true;
      errorMessage.value = ''; // Limpiar errores anteriores
      await _appwriteService.logout();
      user.value = null; // Limpiar el usuario en el controlador
      Get.offAllNamed('/login'); // Redirigir a la pantalla de login
      Get.snackbar(
        'Sesión cerrada',
        'Has cerrado sesión exitosamente',
        backgroundColor: Colors.amber.withOpacity(0.8),
        colorText: Colors.black,
      );
    } on AppwriteException catch (e) {
      errorMessage.value = e.message ?? 'Error al cerrar sesión.';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      print('Error al cerrar sesión (AuthController): $e');
    } catch (e) {
      errorMessage.value = 'Error inesperado al cerrar sesión: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      print('Error inesperado al cerrar sesión (AuthController): $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Se llama automáticamente cuando el controlador está listo
  @override
  void onReady() {
    super.onReady();
    fetchUser(); // Intenta cargar el usuario al iniciar la app
  }

  // --- MÉTODO updateUserName (es crucial que permanezca para la funcionalidad de actualización de perfil) ---
  Future<void> updateUserName(String newName) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Llama al método updateName de Appwrite a través de AppwriteService
      await _appwriteService.updateUserName(newName); // Llama al servicio

      // Si la actualización es exitosa, refresca los datos del usuario en el controlador
      // para que los cambios se reflejen automáticamente en la UI.
      await fetchUser();

      Get.snackbar(
        'Éxito',
        'Nombre de usuario actualizado correctamente.',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AppwriteException catch (e) {
      errorMessage.value = e.message ?? 'Error desconocido al actualizar el nombre.';
      Get.snackbar(
        'Error al actualizar',
        errorMessage.value,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error de Appwrite al actualizar nombre: $e');
    } catch (e) {
      errorMessage.value = 'Error inesperado: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      print('Error inesperado al actualizar nombre: $e');
    } finally {
      isLoading.value = false;
    }
  }
}