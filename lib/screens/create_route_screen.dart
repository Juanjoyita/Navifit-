// lib/screens/create_route_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../controllers/route_controller.dart';
import '../controllers/location_controller.dart';
import '../controllers/sport_controller.dart';

class CreateRouteScreen extends StatelessWidget {
  final RouteController routeController = Get.find();
  final LocationController locationController = Get.find();
  final SportController sportController = Get.find();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  CreateRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Ruta Personalizada'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              routeController.resetRouteCreation();
              sportController.selectedSport.value = '';
              sportController.selectedDifficulty.value = ''; 
              nameController.clear();
              descriptionController.clear();
            },
            tooltip: 'Reiniciar selección',
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel de instrucciones y estado
          _buildInstructionPanel(),
          
          // Mapa
          Expanded(
            flex: 3,
            child: _buildMap(),
          ),
          
          // Panel de información y acciones
          _buildActionPanel(),
        ],
      ),
    );
  }

  Widget _buildInstructionPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Obx(() => Row(
            children: [
              _buildStepIndicator(
                step: 1,
                title: 'Punto de inicio',
                isActive: routeController.isSelectingStartPoint.value,
                isCompleted: routeController.startPoint.value != null,
              ),
              const SizedBox(width: 16),
              _buildStepIndicator(
                step: 2,
                title: 'Punto de destino',
                isActive: !routeController.isSelectingStartPoint.value && 
                      routeController.startPoint.value != null,
                isCompleted: routeController.endPoint.value != null,
              ),
            ],
          )),
          
          const SizedBox(height: 12),
          
          // Información de puntos seleccionados
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildPointInfo(
                  icon: Icons.play_arrow,
                  label: 'Inicio',
                  point: routeController.startPoint.value,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPointInfo(
                  icon: Icons.flag,
                  label: 'Destino',
                  point: routeController.endPoint.value,
                  color: Colors.red,
                ),
              ),
            ],
          )),
          
          // Distancia estimada
          Obx(() {
            final distance = routeController.estimatedDistance;
            if (distance != null) {
              return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.straighten, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Distancia: ${routeController.formatDistance(distance)}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int step,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color getColor() {
      if (isCompleted) return Colors.green;
      if (isActive) return Colors.blue;
      return Colors.grey;
    }

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: getColor(),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    step.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: getColor(),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPointInfo({
    required IconData icon,
    required String label,
    required LatLng? point,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  point != null
                      ? '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}'
                      : 'No seleccionado',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: point != null ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Obx(() {
      final currentPosition = locationController.currentPosition.value;
      
      if (currentPosition == null) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Obteniendo ubicación...'),
            ],
          ),
        );
      }

      final userLocation = LatLng(currentPosition.latitude, currentPosition.longitude);

      return FlutterMap(
        options: MapOptions(
          center: userLocation,
          zoom: 15.0,
          onTap: (tapPosition, point) {
            routeController.selectPoint(point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          
          // Marcadores
          MarkerLayer(
            markers: [
              // Ubicación actual del usuario
              Marker(
                width: 40.0,
                height: 40.0,
                point: userLocation,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              // Punto de inicio
              if (routeController.startPoint.value != null)
                Marker(
                  width: 50.0,
                  height: 50.0,
                  point: routeController.startPoint.value!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              
              // Punto de destino
              if (routeController.endPoint.value != null)
                Marker(
                  width: 50.0,
                  height: 50.0,
                  point: routeController.endPoint.value!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.flag,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
          
          // Línea de ruta
          if (routeController.bothPointsSelected)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    routeController.startPoint.value!,
                    routeController.endPoint.value!,
                  ],
                  strokeWidth: 4.0,
                  color: Colors.blue,
                  isDotted: true,
                ),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildActionPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botones de acción principales
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    routeController.resetRouteCreation();
                    sportController.selectedSport.value = ''; 
                    sportController.selectedDifficulty.value = ''; 
                    nameController.clear();
                    descriptionController.clear();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reiniciar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Obx(() => ElevatedButton.icon(
                  onPressed: routeController.bothPointsSelected
                      ? () => _showSaveDialog()
                      : null,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Ruta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                )),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Texto de ayuda
          Obx(() => Text(
            routeController.isSelectingStartPoint.value
                ? 'Toca en el mapa para seleccionar el punto de inicio'
                : routeController.startPoint.value != null && routeController.endPoint.value == null
                    ? 'Toca en el mapa para seleccionar el punto de destino'
                    : routeController.bothPointsSelected
                        ? '¡Perfecto! Ahora puedes guardar tu ruta'
                        : 'Selecciona ambos puntos para continuar',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          )),
        ],
      ),
    );
  }

  void _showSaveDialog() {
    // Resetear las selecciones del diálogo antes de mostrarlo
    sportController.selectedSport.value = '';
    sportController.selectedDifficulty.value = '';
    nameController.clear();
    descriptionController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('Guardar Ruta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo para el nombre
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la ruta *', 
                  hintText: 'Ej: Mi ruta favorita',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.route),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              
              const SizedBox(height: 16),
              
              // Campo para la descripción
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Describe tu ruta...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              
              const SizedBox(height: 16),
              
              // Selector de deporte
              Obx(() => DropdownButtonFormField<String>(
                value: sportController.selectedSport.value.isEmpty 
                    ? null 
                    : sportController.selectedSport.value,
                decoration: const InputDecoration(
                  labelText: 'Tipo de deporte *', 
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports),
                ),
                items: sportController.sports.map((sport) {
                  return DropdownMenuItem<String>(
                    value: sport,
                    child: Text(sport),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    sportController.selectedSport.value = value;
                  }
                },
                validator: (value) { 
                  if (value == null || value.isEmpty) {
                    return 'Selecciona un deporte';
                  }
                  return null;
                },
              )),
              
              const SizedBox(height: 16),
              
              Obx(() => DropdownButtonFormField<String>(
                value: sportController.selectedDifficulty.value.isEmpty 
                    ? null 
                    : sportController.selectedDifficulty.value,
                decoration: const InputDecoration(
                  labelText: 'Dificultad (opcional)', // Marcado como opcional
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                items: sportController.difficulties.map((difficulty) {
                  return DropdownMenuItem<String>(
                    value: difficulty,
                    child: Row(
                      children: [
                        Icon(
                          sportController.getDifficultyIcon(difficulty),
                          color: sportController.getDifficultyColor(difficulty), 
                        ),
                        const SizedBox(width: 8),
                        Text(difficulty),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    sportController.selectedDifficulty.value = value;
                  }
                },
              )),
              
              const SizedBox(height: 16),
              

              Obx(() {
                final estimatedDistance = routeController.estimatedDistance;
                final selectedSport = sportController.selectedSport.value;
              
                final estimatedDuration = selectedSport.isNotEmpty
                    ? routeController.calculateEstimatedDurationInSeconds(estimatedDistance, selectedSport)
                    : null; // Si no hay deporte seleccionado, no hay duración estimada.

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen de la ruta:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.straighten, color: Colors.blue[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Distancia: ${routeController.formatDistance(estimatedDistance)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.timer, color: Colors.blue[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Duración estimada: ${routeController.formatDuration(estimatedDuration)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              nameController.clear();
              descriptionController.clear();
              sportController.selectedSport.value = ''; // Reiniciar
              sportController.selectedDifficulty.value = ''; // Reiniciar
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validar campos obligatorios
              if (nameController.text.trim().isEmpty) {
                Get.snackbar('Error', 'El nombre de la ruta es obligatorio.', snackPosition: SnackPosition.BOTTOM);
                return;
              }
              if (sportController.selectedSport.value.isEmpty) {
                Get.snackbar('Error', 'Por favor, selecciona un deporte para la ruta.', snackPosition: SnackPosition.BOTTOM);
                return;
              }

              await routeController.saveRoute(
                name: nameController.text.trim(),
                description: descriptionController.text.trim().isEmpty
                    ? null
                    : descriptionController.text.trim(),
                sport: sportController.selectedSport.value, // Enviar el deporte seleccionado
                difficulty: sportController.selectedDifficulty.value.isEmpty
                    ? null
                    : sportController.selectedDifficulty.value, // Enviar la dificultad seleccionada
              );
              
              Get.back(); // Cerrar el diálogo de guardar
              // Los campos del diálogo se resetearán en la llamada a _showPostSaveOptions o en el reset del RouteController

              _showPostSaveOptions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showPostSaveOptions() {
    Get.dialog(
      AlertDialog(
        title: const Text('¿Qué quieres hacer ahora?'),
        content: const Text('Tu ruta se ha guardado exitosamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Cerrar diálogo de opciones post-guardado
              // Aquí podrías navegar a otra pantalla si lo deseas, ej. Get.offAllNamed('/home');
            },
            child: const Text('Volver'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Cerrar diálogo de opciones post-guardado
              // routeController.resetRouteCreation(); // Esto ya se llama dentro de saveRoute
              sportController.selectedSport.value = ''; // Resetear
              sportController.selectedDifficulty.value = ''; // Resetear
              nameController.clear();
              descriptionController.clear();
              // Quedarse en la pantalla para crear otra ruta
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Crear otra ruta'),
          ),
        ],
      ),
    );
  }
}