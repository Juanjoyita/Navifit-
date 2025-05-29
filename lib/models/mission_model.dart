// lib/models/mission_model.dart
import 'dart:convert'; // ¡Importante! Necesario para jsonDecode y jsonEncode
import 'package:latlong2/latlong.dart';

class Mission {
  final String id;
  final String sport;
  final String difficulty;
  final String title;
  final String description;
  final int durationTarget;
  final List<LatLng> points;

  Mission({
    required this.id,
    required this.sport,
    required this.difficulty,
    required this.title,
    required this.description,
    required this.durationTarget,
    required this.points,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    List<LatLng> parsedPoints = [];

    final String? pointsJsonString = json['pointsJson'] as String?;

    if (pointsJsonString != null && pointsJsonString.isNotEmpty) {
      try {

        final List<dynamic> rawPoints = jsonDecode(pointsJsonString);

        for (var pointData in rawPoints) {
          if (pointData is Map<String, dynamic>) {
            double? lat;
            double? lng;


            if (pointData.containsKey('latitude')) {
              lat = (pointData['latitude'] as num?)?.toDouble();
            }
            if (pointData.containsKey('longitude')) {
              lng = (pointData['longitude'] as num?)?.toDouble();
            }


            if (lat == null && pointData.containsKey('lat')) {
              lat = (pointData['lat'] as num?)?.toDouble();
            }
            if (lng == null && pointData.containsKey('lng')) {
              lng = (pointData['lng'] as num?)?.toDouble();
            }

            if (lat != null && lng != null) {
              parsedPoints.add(LatLng(lat, lng));
            } else {
              print('Advertencia: Punto incompleto o inválido en JSON decodificado: $pointData');
            }
          } else {
            print('Advertencia: Elemento de punto no es un Map en JSON decodificado: $pointData');
          }
        }
      } catch (e) {

        print('Error al decodificar pointsJson string de Appwrite: $e');
        print('String problemático: $pointsJsonString');
      }
    }

    return Mission(
      id: json['\$id'] as String, 
      sport: json['sport'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      durationTarget: json['durationTarget'] as int? ?? 0,
      points: parsedPoints,
    );
  }


  Map<String, dynamic> toJson() {
  
    final List<Map<String, dynamic>> pointsList = points
        .map((p) => {
              'lat': p.latitude,
              'lng': p.longitude,
            })
        .toList();

    return {

      'sport': sport,
      'difficulty': difficulty,
      'title': title,
      'description': description,
      'durationTarget': durationTarget,
      'pointsJson': jsonEncode(pointsList), 
    };
  }
}