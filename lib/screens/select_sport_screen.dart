import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sport_controller.dart';
import '../widgets/sport_card.dart';

class SelectSportScreen extends StatelessWidget {
  final SportController sportController = Get.put(SportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Selecciona un deporte')),
      body: Obx(() {
        return ListView.builder(
          itemCount: sportController.sports.length,
          itemBuilder: (context, index) {
            final sport = sportController.sports[index];
            return SportCard(
              sport: sport,
              onTap: () {
                sportController.selectSport(sport);
                Get.toNamed('/routes');
              },
            );
          },
        );
      }),
    );
  }
}
