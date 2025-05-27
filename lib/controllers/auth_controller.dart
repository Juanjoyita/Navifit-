// lib/controllers/auth_controller.dart

import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart'; // Añadir para colores de SnackBar
import '../services/appwrite_service.dart';
import 'package:appwrite/models.dart' as models;

class AuthController extends GetxController {
  final AppwriteService _appwriteService;

  // CORRECCIÓN 1: El constructor ahora espera un Client de Appwrite
  AuthController({required Client appwriteClient})
      : _appwriteService = AppwriteService(client: appwriteClient); // Pasa el Client al servicio

  // Variables reactivas
  var isLoading = false.obs;
  var user = Rxn<models.User>();

  // Método para registrar un usuario
  Future<void> register(String email, String password, String name) async {
    try {
      isLoading.value = true;
      // CORRECCIÓN 2: El método register en AppwriteService ya no requiere userId y secret
      // (userId es generado por ID.unique() internamente, y secret no es un parámetro de create).
      await _appwriteService.register(
        email: email,
        password: password,
        name: name,
      );
      Get.snackbar(
        'Registro exitoso',
        'Ahora puedes iniciar sesión',
        backgroundColor: Colors.green.withOpacity(0.8), // Mejora visual
        colorText: Colors.white,
      );
      Get.back(); // Después de registrar, vuelve a la pantalla de login
    } catch (e) {
      Get.snackbar(
        'Error de Registro',
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.8), // Mejora visual
        colorText: Colors.white,
      );
      print('Error de Registro (AuthController): $e'); // Para depuración
    } finally {
      isLoading.value = false;
    }
  }

  // Método para iniciar sesión
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      // Intenta cerrar sesión activa antes de iniciar una nueva.
      // Esto es robusto, ya que ignora el error si no hay sesión activa.
      try {
        await _appwriteService.logout();
        await Future.delayed(const Duration(milliseconds: 500)); // Espera breve
      } catch (e) {
        // Ignorar si no hay sesión para cerrar
        print('No hay sesión activa para cerrar (Login): $e');
      }

      await _appwriteService.login(email: email, password: password);
      await fetchUser(); // Obtener los datos del usuario recién logueado
      Get.offAllNamed('/selectSport'); // Redirigir a la pantalla principal
    } catch (e) {
      Get.snackbar(
        'Error de Login',
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.8), // Mejora visual
        colorText: Colors.white,
      );
      print('Error de Login (AuthController): $e'); // Para depuración
    } finally {
      isLoading.value = false;
    }
  }

  // Método para obtener el usuario actual
  Future<void> fetchUser() async {
    try {
      user.value = await _appwriteService.getCurrentUser();
      print('Usuario cargado (AuthController): ${user.value?.email}');
    } catch (e) {
      user.value = null; // Si falla, asegura que el usuario es nulo
      print('Error al obtener el usuario (AuthController): $e');
      // No mostrar snackbar aquí, ya que podría ocurrir si el usuario no está logueado
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _appwriteService.logout();
      user.value = null; // Limpia el usuario reactivo
      Get.offAllNamed('/login'); // Redirigir al login
      Get.snackbar(
        'Sesión cerrada',
        'Has cerrado sesión exitosamente',
        backgroundColor: Colors.amber.withOpacity(0.8), // Mejora visual
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cerrar sesión: $e',
        backgroundColor: Colors.red.withOpacity(0.8), // Mejora visual
        colorText: Colors.white,
      );
      print('Error al cerrar sesión (AuthController): $e'); // Para depuración
    } finally {
      isLoading.value = false;
    }
  }

  // Se llama cuando el controlador está listo
  @override
  void onReady() {
    super.onReady();
    fetchUser(); // Intenta obtener el usuario al iniciar el controlador
  }
}