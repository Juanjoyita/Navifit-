class RouteModel {
  final String id;
  final String name;
  final List<double> coordinates; // Podríamos hacerlo mejor con LatLng después

  RouteModel({required this.id, required this.name, required this.coordinates});
} 