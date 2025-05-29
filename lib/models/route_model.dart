// lib/models/route_model.dart
import 'package:latlong2/latlong.dart';
// No necesitamos 'dart:convert' si Appwrite maneja el campo 'points' como JSON nativo.
// Si aún lo usas como String JSON, entonces sí se necesitaría.
// import 'dart:convert'; // Para jsonEncode/jsonDecode si el campo 'points' es String en Appwrite

class RouteModel {
  final String? id; // El ID de Appwrite (puede ser nulo al crear)
  final String userId; // El ID del usuario creador
  final String name;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;

  final double distance; // En metros (requerido por Appwrite)
  final int duration;   // En segundos (requerido por Appwrite)

  final String? description;
  final String sport;
  final String? difficulty;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Nuevos campos para la finalización de ruta
  final bool isCompleted; // Indica si la ruta ha sido marcada como finalizada
  final DateTime? completedAt; // Fecha y hora de finalización

  RouteModel({
    this.id,
    required this.userId,
    required this.name,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.distance,
    required this.duration,
    this.description,
    required this.sport,
    this.difficulty,
    required this.createdAt,
    this.updatedAt,
    this.isCompleted = false, // Valor por defecto
    this.completedAt,
  });

  // Constructor factory para crear RouteModel desde un mapa (ej. desde Appwrite)
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final String? docId = json['\$id'] as String?;
    final String? created = json['\$createdAt'] as String?;
    final String? updated = json['\$updatedAt'] as String?;

    return RouteModel(
      id: docId,
      userId: json['userId'] as String,
      name: json['name'] as String,
      startLatitude: (json['startLatitude'] as num).toDouble(),
      startLongitude: (json['startLongitude'] as num).toDouble(),
      endLatitude: (json['endLatitude'] as num).toDouble(),
      endLongitude: (json['endLongitude'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
      description: json['description'] as String?,
      sport: json['sport'] as String,
      difficulty: json['difficulty'] as String?,
      createdAt: created != null ? DateTime.parse(created) : DateTime.now(),
      updatedAt: updated != null ? DateTime.parse(updated) : null,
      isCompleted: json['isCompleted'] as bool? ?? false, // Mapea el nuevo campo
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null, // Mapea el nuevo campo
    );
  }

  // Método para convertir RouteModel a un mapa para Appwrite
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
      'distance': distance,
      'duration': duration,
      'description': description,
      'sport': sport,
      'difficulty': difficulty,
      'isCompleted': isCompleted, // Incluye el nuevo campo
      'completedAt': completedAt?.toIso8601String(), // Incluye el nuevo campo (puede ser nulo)
      // NO INCLUIR 'createdAt' ni 'updatedAt' aquí. Appwrite los maneja automáticamente.
      // Tampoco el 'id' porque Appwrite lo genera
    };
  }

  // Método copyWith para facilitar la creación de nuevas instancias con propiedades modificadas
  RouteModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? startLatitude,
    double? startLongitude,
    double? endLatitude,
    double? endLongitude,
    double? distance,
    int? duration,
    String? description,
    String? sport,
    String? difficulty,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted, // Nuevo campo en copyWith
    DateTime? completedAt, // Nuevo campo en copyWith
  }) {
    return RouteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      sport: sport ?? this.sport,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // GETTERS PARA CONVERTIR Latitudes/Longitudes a LatLng
  LatLng get startPoint => LatLng(startLatitude, startLongitude);
  LatLng get endPoint => LatLng(endLatitude, endLongitude);

  // Método adicional para debug/logging
  @override
  String toString() {
    return 'RouteModel(id: $id, name: $name, sport: $sport, startPoint: (${startLatitude}, ${startLongitude}), endPoint: (${endLatitude}, ${endLongitude}), distance: ${distance.toStringAsFixed(2)}m, duration: $duration seg, isCompleted: $isCompleted)';
  }
}