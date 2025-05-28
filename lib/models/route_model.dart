// lib/models/route_model.dart
import 'package:latlong2/latlong.dart';

class RouteModel {
  final String? id; // El ID de Appwrite (puede ser nulo al crear)
  final String userId; // El ID del usuario creador
  final String name;
  // Atributos separados para latitud y longitud, usados para Appwrite
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  // Fin de atributos de coordenadas

  // CAMBIOS CRÍTICOS: `distance` y `duration` son ahora requeridos (no nullable)
  final double distance; // En metros (requerido por Appwrite)
  final int duration;   // En segundos (requerido por Appwrite)
  // FIN CAMBIOS CRÍTICOS

  final String? description;
  final String sport;
  final String? difficulty;
  final DateTime createdAt; // Se inicializa en la app, pero Appwrite tiene su propio $createdAt
  final DateTime? updatedAt; // Appwrite tiene su propio $updatedAt

  RouteModel({
    this.id,
    required this.userId,
    required this.name,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    // ¡IMPORTANTE! Ahora requeridos en el constructor
    required this.distance,
    required this.duration,
    // Fin de nuevos parámetros
    this.description,
    required this.sport,
    this.difficulty,
    required this.createdAt, // Sigue siendo requerido para el modelo local
    this.updatedAt,
  });

  // Constructor factory para crear RouteModel desde un mapa (ej. desde Appwrite)
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    // Para manejar los IDs y timestamps de Appwrite (con $)
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
      // ¡IMPORTANTE! Leer como no nulo.
      // Asegúrate de que los nombres de los campos en Appwrite sean 'distance' y 'duration'
      distance: (json['distance'] as num).toDouble(), // <--- CORRECCIÓN DE NOMBRE DEL CAMPO JSON
      duration: (json['duration'] as num).toInt(),   // <--- CORRECCIÓN DE NOMBRE DEL CAMPO JSON
      description: json['description'] as String?,
      sport: json['sport'] as String,
      difficulty: json['difficulty'] as String?,
      createdAt: created != null ? DateTime.parse(created) : DateTime.now(), // Appwrite devuelve $createdAt como String
      updatedAt: updated != null ? DateTime.parse(updated) : null,
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
      'distance': distance, // Ahora es requerido y no será nulo
      'duration': duration, // Ahora es requerido y no será nulo
      'description': description,
      'sport': sport,
      'difficulty': difficulty,
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
    String? description,
    String? sport,
    String? difficulty,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RouteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
      distance: distance ?? this.distance, // Asegurarse de pasar el valor no nulo
      description: description ?? this.description,
      sport: sport ?? this.sport,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration, // Asegurarse de pasar el valor no nulo
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // >>>>>> GETTERS PARA CONVERTIR Latitudes/Longitudes a LatLng <<<<<<
  // Esto permite que el resto de tu código que usa LatLng siga funcionando sin cambios mayores
  LatLng get startPoint => LatLng(startLatitude, startLongitude);
  LatLng get endPoint => LatLng(endLatitude, endLongitude); // <--- CORRECCIÓN: De endEndDate a endLatitude

  // Método adicional para debug/logging
  @override
  String toString() {
    return 'RouteModel(id: $id, name: $name, sport: $sport, startPoint: (${startLatitude}, ${startLongitude}), endPoint: (${endLatitude}, ${endLongitude}), distance: ${distance.toStringAsFixed(2)}m, duration: $duration seg)';
  }
}