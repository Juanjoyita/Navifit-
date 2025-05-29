// lib/screens/route_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/route_model.dart';
import '../controllers/route_controller.dart';
import '../controllers/sport_controller.dart';
import '../controllers/auth_controller.dart';
import 'dart:async';

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({super.key});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  static const Color primaryDark = Color(0xFF202221);
  static const Color secondaryDark = Color(0xFF303531);
  static const Color accentGoldLight = Color(0xFFB68B4B);
  static const Color accentGoldMedium = Color(0xFF956E2F);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFBBBBBB);

  Timer? _timer;
  late int _initialDuration;
  late int _remainingSeconds;
  bool _isRunning = false;
  
  final RouteController routeController = Get.find<RouteController>();
  final SportController sportController = Get.find<SportController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    final RouteModel? route = Get.arguments as RouteModel?;

    _initialDuration = route?.duration ?? 0;
    if (_initialDuration < 0) {
      _initialDuration = 0;
    }
    _remainingSeconds = _initialDuration;

    print('RouteDetailScreen: Initial Duration set to $_initialDuration seconds.');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    if (_isRunning || _remainingSeconds <= 0) {
      if (_remainingSeconds <= 0 && !_isRunning) {
        Get.snackbar(
          'Tiempo Agotado',
          'No queda tiempo para iniciar la cuenta regresiva. Reinicia primero.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: primaryText,
        );
      }
      return; 
    }

    _isRunning = true;
    Get.snackbar(
      'Temporizador Iniciado',
      'Cuenta regresiva en marcha...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent.withOpacity(0.8),
      colorText: primaryText,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _stopCountdown();
          Get.snackbar(
            '¡Tiempo Agotado!',
            'El tiempo estimado para la ruta ha terminado.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent.withOpacity(0.9),
            colorText: primaryText,
            icon: const Icon(Icons.timer_off, color: primaryText),
            duration: const Duration(seconds: 5),
          );
        }
      });
    });
  }

  void _stopCountdown() {
    if (!_isRunning && _timer == null) return;

    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    Get.snackbar(
      'Temporizador Detenido',
      'La cuenta regresiva ha sido pausada.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: primaryText,
    );
  }

  void _resetCountdown() {
    _stopCountdown();
    setState(() {
      _remainingSeconds = _initialDuration;
    });
    Get.snackbar(
      'Temporizador Reiniciado',
      'La cuenta regresiva ha vuelto al inicio.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.withOpacity(0.8),
      colorText: primaryText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final RouteModel? route = Get.arguments as RouteModel?;

    if (route == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Ruta'),
          backgroundColor: secondaryDark,
          foregroundColor: accentGoldLight,
        ),
        backgroundColor: primaryDark,
        body: Center(
          child: Text(
            'Error: No se encontró la información de la ruta.',
            style: TextStyle(color: accentGoldLight, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: primaryDark,
      appBar: AppBar(
        title: Text(
          'Detalle de Ruta',
          style: TextStyle(
            color: accentGoldLight,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: secondaryDark,
        elevation: 0,
        iconTheme: IconThemeData(color: accentGoldLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              route.name,
              style: TextStyle(
                color: accentGoldLight,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            if (route.description != null && route.description!.isNotEmpty)
              Text(
                route.description!,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 16,
                ),
              ),
            const SizedBox(height: 20),

            Divider(color: accentGoldMedium.withOpacity(0.3), height: 1),
            const SizedBox(height: 20),

            _buildDetailRow(
              icon: Icons.straighten,
              label: 'Distancia:',
              value: routeController.formatDistance(route.distance),
              iconColor: accentGoldMedium,
              textColor: primaryText,
            ),
            _buildDetailRow(
              icon: Icons.timer,
              label: 'Duración Est.:',
              value: routeController.formatDuration(route.duration),
              iconColor: accentGoldMedium,
              textColor: primaryText,
            ),
            _buildDetailRow(
              icon: sportController.getSportIconData(route.sport),
              label: 'Deporte:',
              value: route.sport,
              iconColor: accentGoldMedium,
              textColor: primaryText,
            ),
            if (route.difficulty != null && route.difficulty!.isNotEmpty)
              _buildDetailRow(
                icon: sportController.getDifficultyIcon(route.difficulty!),
                label: 'Dificultad:',
                value: route.difficulty!,
                iconColor: sportController.getDifficultyColor(route.difficulty!),
                textColor: primaryText,
              ),
            _buildDetailRow(
              icon: Icons.calendar_month,
              label: 'Creada:',
              value: authController.formatDateTime(route.createdAt.toIso8601String()),
              iconColor: accentGoldMedium,
              textColor: primaryText,
            ),

            const SizedBox(height: 20),

            Text(
              'Coordenadas:',
              style: TextStyle(
                color: accentGoldLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inicio: Lat ${route.startPoint.latitude.toStringAsFixed(4)}, Lng ${route.startPoint.longitude.toStringAsFixed(4)}',
              style: TextStyle(color: secondaryText, fontSize: 15),
            ),
            Text(
              'Fin: Lat ${route.endPoint.latitude.toStringAsFixed(4)}, Lng ${route.endPoint.longitude.toStringAsFixed(4)}',
              style: TextStyle(color: secondaryText, fontSize: 15),
            ),
            const SizedBox(height: 25),

            Text(
              'Tiempo Restante Estimado:',
              style: TextStyle(
                color: accentGoldLight,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Text(
                    routeController.formatDuration(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds <= 60 && _remainingSeconds > 0
                          ? Colors.orangeAccent
                          : _remainingSeconds == 0
                              ? Colors.redAccent
                              : accentGoldLight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isRunning || _remainingSeconds <= 0
                            ? null
                            : _startCountdown,
                        icon: const Icon(Icons.play_arrow, color: primaryDark),
                        label: Text(
                          _isRunning ? 'Contando...' : 'Iniciar Temporizador',
                          style: TextStyle(fontSize: 16, color: primaryDark),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isRunning ? _stopCountdown : null,
                        icon: const Icon(Icons.pause, color: primaryDark),
                        label: const Text(
                          'Pausar',
                          style: TextStyle(fontSize: 16, color: primaryDark),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (!_isRunning)
                    OutlinedButton.icon(
                      onPressed: _resetCountdown,
                      icon: const Icon(Icons.refresh, color: accentGoldMedium),
                      label: Text('Reiniciar', style: TextStyle(color: accentGoldMedium)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accentGoldMedium),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.8),
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}