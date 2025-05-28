// lib/controllers/auth_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';
import 'package:appwrite/models.dart' as models;
import 'package:intl/intl.dart'; // ¡Asegúrate de que esta importación esté presente!

class AuthController extends GetxController {
  // Obtiene la instancia de AppwriteService que ya fue inyectada
  final AppwriteService _appwriteService = Get.find<AppwriteService>();

  // Variables reactivas
  var isLoading = false.obs;
  var user = Rxn<models.User>();

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

  Future<void> register(String email, String password, String name) async {
    try {
      isLoading.value = true;
      await _appwriteService.register(
        email: email,
        password: password,
        name: name,
      );
      Get.snackbar(
        'Registro exitoso',
        'Ahora puedes iniciar sesión',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error de Registro',
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      print('Error de Registro (AuthController): $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      // Intenta cerrar sesión activa antes de iniciar una nueva.
      try {
        await _appwriteService.logout();
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('No hay sesión activa para cerrar (Login): $e');
      }

      await _appwriteService.login(email: email, password: password);
      await fetchUser();
      Get.offAllNamed('/selectSport');
    } catch (e) {
      Get.snackbar(
        'Error de Login',
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      print('Error de Login (AuthController): $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUser() async {
    try {
      user.value = await _appwriteService.getCurrentUser();
      print('Usuario cargado (AuthController): ${user.value?.email}');
    } catch (e) {
      user.value = null;
      print('Error al obtener el usuario (AuthController): $e');
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _appwriteService.logout();
      user.value = null;
      Get.offAllNamed('/login');
      Get.snackbar(
        'Sesión cerrada',
        'Has cerrado sesión exitosamente',
        backgroundColor: Colors.amber.withOpacity(0.8),
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cerrar sesión: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      print('Error al cerrar sesión (AuthController): $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    fetchUser();
  }
}