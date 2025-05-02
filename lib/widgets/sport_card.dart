import 'package:flutter/material.dart';

class SportCard extends StatelessWidget {
  final String sport;
  final bool isSelected;
  final VoidCallback onTap;

  const SportCard({
    super.key,
    required this.sport,
    required this.isSelected,
    required this.onTap, required Color color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected ? Colors.blueAccent : Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(
                _getIconForSport(sport),
                size: 40,
                color: isSelected ? Colors.white : Colors.black,
              ),
              const SizedBox(height: 8),
              Text(
                sport,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForSport(String sport) {
    switch (sport) {
      case 'Running':
        return Icons.directions_run;
      case 'Ciclismo':
        return Icons.pedal_bike;
      case 'Senderismo':
        return Icons.terrain;
      default:
        return Icons.sports;
    }
  }
}
