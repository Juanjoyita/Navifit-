// lib/screens/route_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/route_model.dart'; // Asegúrate de que tu RouteModel tiene un 'duration' de tipo int
import '../controllers/route_controller.dart';
import '../controllers/sport_controller.dart';
import '../controllers/auth_controller.dart';
import 'dart:async'; // ¡IMPORTANTE: Añadir para usar Timer!

class RouteDetailScreen extends StatefulWidget {
  const RouteDetailScreen({super.key});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  // Definición de tu paleta de colores
  static const Color primaryDark = Color(0xFF202221);
  static const Color secondaryDark = Color(0xFF303531);
  static const Color accentGoldLight = Color(0xFFB68B4B);
  static const Color accentGoldMedium = Color(0xFF956E2F);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFBBBBBB);

  // --- Lógica del Temporizador de Cuenta Regresiva ---
  Timer? _timer;
  late int _initialDuration; // Guarda la duración original de la ruta
  late int _remainingSeconds; // Tiempo restante actual en el temporizador
  bool _isRunning = false;
  
  // Instancias de los controladores
  // Se inicializan aquí o en initState para que estén disponibles antes de build
  final RouteController routeController = Get.find<RouteController>();
  final SportController sportController = Get.find<SportController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Recupera la ruta pasada como argumento
    final RouteModel? route = Get.arguments as RouteModel?;

    // Asigna la duración inicial. Si es null o menor a 0, usa 0.
    _initialDuration = route?.duration ?? 0;
    if (_initialDuration < 0) {
      _initialDuration = 0; // Asegura que no sea negativo
    }
    _remainingSeconds = _initialDuration;

    // Puedes añadir un print para depuración en la consola
    print('RouteDetailScreen: Initial Duration set to $_initialDuration seconds.');
  }

  @override
  void dispose() {
    _timer?.cancel(); // ¡Importante: Detener el timer cuando el widget se destruye!
    super.dispose();
  }

  void _startCountdown() {
    // No iniciar si ya está corriendo o si no queda tiempo
    if (_isRunning || _remainingSeconds <= 0) {
      if (_remainingSeconds <= 0 && !_isRunning) {
        // Muestra un mensaje si intentan iniciar con 0 tiempo restante
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
          _stopCountdown(); // Detener cuando llega a cero
          Get.snackbar(
            '¡Tiempo Agotado!',
            'El tiempo estimado para la ruta ha terminado.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent.withOpacity(0.9),
            colorText: primaryText,
            icon: const Icon(Icons.timer_off, color: primaryText),
            duration: const Duration(seconds: 5), // Haz que el snackbar dure más
          );
          // Opcional: Vibra o emite un sonido
          // import 'package:flutter/services.dart';
          // SystemSound.play(SystemSoundType.alert);
        }
      });
    });
  }

  void _stopCountdown() {
    if (!_isRunning && _timer == null) return; // Evitar detener si no está corriendo y no hay timer

    _timer?.cancel();
    _timer = null; // Limpiar el timer
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
    _stopCountdown(); // Primero detén si está corriendo
    setState(() {
      _remainingSeconds = _initialDuration; // Reiniciar al valor original
    });
    Get.snackbar(
      'Temporizador Reiniciado',
      'La cuenta regresiva ha vuelto al inicio.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.withOpacity(0.8),
      colorText: primaryText,
    );
  }
  // --- Fin Lógica del Temporizador de Cuenta Regresiva ---


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
            // Título de la Ruta
            Text(
              route.name,
              style: TextStyle(
                color: accentGoldLight,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Descripción (opcional)
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

            // Detalles de la ruta
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

            // Puntos de inicio y fin (coordenadas) - Mantenemos esto si quieres mostrar las coordenadas sin el mapa
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

            // --- Sección del Temporizador de Cuenta Regresiva ---
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
                    // Usa _remainingSeconds, no route.duration
                    routeController.formatDuration(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds <= 60 && _remainingSeconds > 0
                          ? Colors.orangeAccent // Naranja si queda menos de un minuto
                          : _remainingSeconds == 0
                              ? Colors.redAccent // Rojo si se agotó el tiempo
                              : accentGoldLight, // Normal si queda mucho
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isRunning || _remainingSeconds <= 0
                            ? null // Deshabilitar si ya está corriendo o el tiempo llegó a cero
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
                        onPressed: _isRunning ? _stopCountdown : null, // Habilitar solo si está corriendo
                        icon: const Icon(Icons.pause, color: primaryDark), // Icono de pausa
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
                  // Botón de Reiniciar siempre visible cuando no está corriendo, o si el tiempo llegó a cero
                  if (!_isRunning) // Mostrar solo si no está corriendo
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
            // --- Fin Sección del Temporizador de Cuenta Regresiva ---
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