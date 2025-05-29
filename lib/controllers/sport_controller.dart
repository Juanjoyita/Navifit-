// lib/controllers/sport_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart'; 

class SportController extends GetxController {

  var sports = ['Running', 'Ciclismo', 'Senderismo'].obs;


  var difficulties = ['Fácil', 'Moderado', 'Difícil', 'Extremo'].obs;


  var selectedSport = ''.obs;
  var selectedDifficulty = ''.obs;

  // Métodos para actualizar las selecciones
  void selectSport(String sport) {
    selectedSport.value = sport;
  }

  void selectDifficulty(String difficulty) {
    selectedDifficulty.value = difficulty;
  }


  // Método para obtener el icono de un deporte 
  IconData getSportIconData(String sport) {
    switch (sport.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'ciclismo':
        return Icons.pedal_bike;
      case 'senderismo':
        return Icons.hiking;
      default:
        return Icons.sports; 
    }
  }

  
  IconData getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
        return Icons.sentiment_very_satisfied;
      case 'moderado':
        return Icons.sentiment_satisfied;
      case 'difícil':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  // Método para obtener el color de la dificultad (mantenido para la UI)
  Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
        return Colors.green;
      case 'moderado':
        return Colors.amber;
      case 'difícil':
        return Colors.red;
      case 'extremo':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Puedes mantener este método si lo necesitas para otras validaciones
  bool isValidSelection() {
    return selectedSport.isNotEmpty && selectedDifficulty.isNotEmpty;
  }
}