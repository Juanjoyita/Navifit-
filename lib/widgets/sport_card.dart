import 'package:flutter/material.dart';
import '../models/sport_model.dart';

class SportCard extends StatelessWidget {
  final SportModel sport;
  final VoidCallback onTap;

  SportCard({required this.sport, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(sport.name),
      onTap: onTap,
    );
  }
}
