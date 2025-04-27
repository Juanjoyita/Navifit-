import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/route_controller.dart';
import '../widgets/route_card.dart';

class RouteListScreen extends StatelessWidget {
  final RouteController routeController = Get.put(RouteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rutas')),
      body: Obx(() {
        return ListView.builder(
          itemCount: routeController.routes.length,
          itemBuilder: (context, index) {
            final route = routeController.routes[index];
            return RouteCard(route: route);
          },
        );
      }),
    );
  }
}
