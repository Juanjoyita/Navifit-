import 'package:latlong2/latlong.dart';

class RouteModel {
  final String id;
  final String name;
  final LatLng startPoint;
  final LatLng endPoint;
  final double? distance; // Distancia estimada en metros
  final DateTime createdAt;
  final String? description;
  final String? userId; // ID del usuario propietario (para Appwrite)

  RouteModel({
    required this.id,
    required this.name,
    required this.startPoint,
    required this.endPoint,
    this.distance,
    required this.createdAt,
    this.description,
    this.userId,
  });

  // Convertir a JSON para guardar en Appwrite
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startPoint': {
        'latitude': startPoint.latitude,
        'longitude': startPoint.longitude,
      },
      'endPoint': {
        'latitude': endPoint.latitude,
        'longitude': endPoint.longitude,
      },
      'distance': distance,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      // userId se agregará en el servicio
    };
  }

  // Crear desde JSON (datos de Appwrite)
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] ?? json['\$id'] ?? '', // Appwrite usa $id
      name: json['name'] ?? '',
      startPoint: LatLng(
        (json['startPoint']['latitude'] as num).toDouble(),
        (json['startPoint']['longitude'] as num).toDouble(),
      ),
      endPoint: LatLng(
        (json['endPoint']['latitude'] as num).toDouble(),
        (json['endPoint']['longitude'] as num).toDouble(),
      ),
      distance: json['distance']?.toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : json['\$createdAt'] != null
              ? DateTime.parse(json['\$createdAt'])
              : DateTime.now(),
      description: json['description'],
      userId: json['userId'],
    );
  }

  // Calcular distancia entre dos puntos usando la fórmula de Haversine
  double calculateDistance() {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, startPoint, endPoint);
  }

  // Crear una copia con valores modificados
  RouteModel copyWith({
    String? id,
    String? name,
    LatLng? startPoint,
    LatLng? endPoint,
    double? distance,
    DateTime? createdAt,
    String? description,
    String? userId,
  }) {
    return RouteModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      distance: distance ?? this.distance,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      userId: userId ?? this.userId,
    );
  }

  // Para debug
  @override
  String toString() {
    return 'RouteModel(id: $id, name: $name, distance: $distance, userId: $userId)';
  }

  // Verificar igualdad
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}