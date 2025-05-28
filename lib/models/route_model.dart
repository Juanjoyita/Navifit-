// lib/models/route_model.dart
import 'package:latlong2/latlong.dart';

class RouteModel {
  final String? id; // El ID de Appwrite (puede ser nulo al crear)
  final String userId; // El ID del usuario creador
  final String name;
  final LatLng startPoint;
  final LatLng endPoint;
  final double? distance; // En metros
  final String? description;
  final String sport;
  final String? difficulty;
  final int? duration; // En segundos
  final DateTime createdAt; // Se inicializa en la app, pero Appwrite tiene su propio $createdAt
  final DateTime? updatedAt; // Appwrite tiene su propio $updatedAt

  RouteModel({
    this.id,
    required this.userId,
    required this.name,
    required this.startPoint,
    required this.endPoint,
    this.distance,
    this.description,
    required this.sport,
    this.difficulty,
    this.duration,
    required this.createdAt,
    this.updatedAt,
  });

  // Constructor factory para crear RouteModel desde un mapa (ej. desde Appwrite)
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final String? docId = json['\$id'] as String?;
    final String? created = json['\$createdAt'] as String?;
    final String? updated = json['\$updatedAt'] as String?;

    // CAMBIO IMPORTANTE AQUÍ: Si Appwrite envía un ARRAY para startPoint/endPoint,
    // necesitamos extraer el primer elemento (el objeto LatLng).
    // Si no es un array, se asume que es el objeto directamente.
    Map<String, dynamic>? startPointData;
    if (json['startPoint'] is List && (json['startPoint'] as List).isNotEmpty) {
      startPointData = (json['startPoint'] as List).first as Map<String, dynamic>;
    } else if (json['startPoint'] is Map<String, dynamic>) {
      startPointData = json['startPoint'] as Map<String, dynamic>;
    }

    Map<String, dynamic>? endPointData;
    if (json['endPoint'] is List && (json['endPoint'] as List).isNotEmpty) {
      endPointData = (json['endPoint'] as List).first as Map<String, dynamic>;
    } else if (json['endPoint'] is Map<String, dynamic>) {
      endPointData = json['endPoint'] as Map<String, dynamic>;
    }

    return RouteModel(
      id: docId,
      userId: json['userId'] as String,
      name: json['name'] as String,
      startPoint: LatLng(
        (startPointData?['latitude'] as num).toDouble(),
        (startPointData?['longitude'] as num).toDouble(),
      ),
      endPoint: LatLng(
        (endPointData?['latitude'] as num).toDouble(),
        (endPointData?['longitude'] as num).toDouble(),
      ),
      distance: (json['distance'] as num?)?.toDouble(),
      description: json['description'] as String?,
      sport: json['sport'] as String,
      difficulty: json['difficulty'] as String?,
      duration: json['duration'] as int?,
      createdAt: created != null ? DateTime.parse(created) : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
      updatedAt: updated != null ? DateTime.parse(updated) : null,
    );
  }

  // Método para convertir RouteModel a un mapa para Appwrite
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      // CAMBIO AQUÍ: Ahora 'startPoint' es un array que contiene un objeto LatLng
      'startPoint': [
        {
          'latitude': startPoint.latitude,
          'longitude': startPoint.longitude,
        }
      ],
      // CAMBIO AQUÍ: Ahora 'endPoint' es un array que contiene un objeto LatLng
      'endPoint': [
        {
          'latitude': endPoint.latitude,
          'longitude': endPoint.longitude,
        }
      ],
      'distance': distance,
      'description': description,
      'sport': sport,
      'difficulty': difficulty,
      'duration': duration,
    };
  }

  // Método copyWith para facilitar la creación de nuevas instancias con propiedades modificadas
  RouteModel copyWith({
    String? id,
    String? userId,
    String? name,
    LatLng? startPoint,
    LatLng? endPoint,
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
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      distance: distance ?? this.distance,
      description: description ?? this.description,
      sport: sport ?? this.sport,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}