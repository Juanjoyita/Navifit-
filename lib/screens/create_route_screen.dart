import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/route_controller.dart';
import '../models/route_model.dart';

class CreateRouteScreen extends StatelessWidget {
  final RouteController routeController = Get.find();

  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Ruta')),
      body: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Nombre de la ruta'),
          ),
          ElevatedButton(
            onPressed: () {
              routeController.addRoute(
                RouteModel(
                  id: DateTime.now().toString(),
                  name: nameController.text,
                  coordinates: [],
                ),
              );
              Get.back();
            },
            child: Text('Guardar'),
          )
        ],
      ),
    );
  }
}
