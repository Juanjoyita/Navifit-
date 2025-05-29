// lib/models/route_model.dart
import 'package:latlong2/latlong.dart';


class RouteModel {
  final String? id; 
  final String userId; 
  final String name;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;

  final double distance; 
  final int duration;   

  final String? description;
  final String sport;
  final String? difficulty;
  final DateTime createdAt;
  final DateTime? updatedAt;




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

  });


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

    );
  }


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

    };
  }

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
    );
  }


  LatLng get startPoint => LatLng(startLatitude, startLongitude);
  LatLng get endPoint => LatLng(endLatitude, endLongitude);


  @override
  String toString() {
    return 'RouteModel(id: $id, name: $name, sport: $sport, startPoint: (${startLatitude}, ${startLongitude}), endPoint: (${endLatitude}, ${endLongitude}), distance: ${distance.toStringAsFixed(2)})';

  }
}