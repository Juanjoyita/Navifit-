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
    // ASUMIMOS que 'pointsJson' es una CADENA JSON en Appwrite
    final String? pointsJsonString = json['pointsJson'] as String?;

    if (pointsJsonString != null && pointsJsonString.isNotEmpty) {
      try {
        // CORRECCIÓN: Decodificar la cadena JSON primero
        // Esto convertirá la cadena "[{\"lat\\\":1.1961}]" a una List<dynamic>
        final List<dynamic> rawPoints = jsonDecode(pointsJsonString);

        for (var pointData in rawPoints) {
          if (pointData is Map<String, dynamic>) {
            double? lat;
            double? lng;

            // Intenta leer como 'latitude'/'longitude'
            // Usamos 'num?' para manejar ints o doubles y '.toDouble()' para asegurar double
            if (pointData.containsKey('latitude')) {
              lat = (pointData['latitude'] as num?)?.toDouble();
            }
            if (pointData.containsKey('longitude')) {
              lng = (pointData['longitude'] as num?)?.toDouble();
            }

            // Si no se encontraron, intenta leer como 'lat'/'lng'
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
        // Si hay un error al decodificar la cadena JSON (por ejemplo, si no es un JSON válido)
        print('Error al decodificar pointsJson string de Appwrite: $e');
        print('String problemático: $pointsJsonString');
      }
    }

    return Mission(
      id: json['\$id'] as String, // Asegúrate que tu JSON realmente usa '$id' para el ID
      sport: json['sport'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      durationTarget: json['durationTarget'] as int? ?? 0,
      points: parsedPoints, // Asignar la lista de LatLng parseada
    );
  }

  // Para convertir la Misión de vuelta a JSON (para guardar o enviar a Appwrite)
  Map<String, dynamic> toJson() {
    // CORRECCIÓN: Codificar la lista de puntos a una CADENA JSON para guardar como String en Appwrite
    final List<Map<String, dynamic>> pointsList = points
        .map((p) => {
              'lat': p.latitude, // Usando 'lat'/'lng' por consistencia con tus datos de ejemplo
              'lng': p.longitude,
            })
        .toList();

    return {
      // Si '$id' es tu clave de ID. Appwrite normalmente lo ignora al crear un nuevo documento.
      // Puedes comentarlo si no quieres enviarlo al crear un nuevo documento.
      // '\$id': id,
      'sport': sport,
      'difficulty': difficulty,
      'title': title,
      'description': description,
      'durationTarget': durationTarget,
      'pointsJson': jsonEncode(pointsList), // <-- Codificar a String aquí
    };
  }
}