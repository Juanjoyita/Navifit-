import 'package:flutter/material.dart';
import '../models/route_model.dart';

class RouteCard extends StatelessWidget {
  final RouteModel route;

  RouteCard({required this.route});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(route.name),
    );
  }
}
