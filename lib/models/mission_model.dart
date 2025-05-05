import 'dart:convert';

class Mission {
  final String id;
  final String sport;
  final String difficulty;
  final List<Map<String, double>> points;
  final int durationTarget;
  final String title;
  final String description;

  Mission({
    required this.id,
    required this.sport,
    required this.difficulty,
    required this.points,
    required this.durationTarget,
    required this.title,
    required this.description,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    List<Map<String, double>> parsedPoints = [];

    try {
      if (json['pointsJson'] != null && json['pointsJson'] is String) {
        final decoded = jsonDecode(json['pointsJson']) as List;
        parsedPoints = decoded
            .map<Map<String, double>>((point) => {
                  'lat': (point['lat'] as num).toDouble(),
                  'lng': (point['lng'] as num).toDouble(),
                })
            .toList();
      }
    } catch (e) {
      print('❌ Error al parsear pointsJson: $e');
    }

    return Mission(
      id: json['\$id'] ?? '',
      sport: json['sport'] ?? '',
      difficulty: json['difficulty'] ?? '',
      points: parsedPoints,
      durationTarget: json['durationTarget'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
