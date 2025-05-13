import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../models/mission_model.dart';

class AppwriteService {
  late Client client;
  late Account account;
  late Databases database;
  late Storage storage;

  // IDs de base de datos y colección para misiones
  final String databaseId = '680e512b0007f0381936'; // Reemplaza por tu Database ID real
  final String missionCollectionId = '681290670039287a54df'; // Reemplaza por tu Collection ID real

  AppwriteService(Databases databases) {
    client = Client()
      .setEndpoint('https://fra.cloud.appwrite.io/v1') // Asegúrate de usar el endpoint correcto
      .setProject('67f4970e00257170a0c8'); // Reemplaza por tu Project ID real

    account = Account(client);
    database = Databases(client);
    storage = Storage(client);
  }

  /// Registrar un nuevo usuario
  Future<User> register({
    required String email,
    required String password,
    required String name,
    required String userId, // Ensure this is provided
    required String secret, // Ensure this is provided
  }) async {
    return await account.create(
      userId: userId, // Use the userId parameter
      email: email,
      password: password,
      name: name, // Use the secret parameter if required by your logic
    );
  }

  /// Iniciar sesión con email y contraseña
  Future<Session> login({
    required String email,
    required String password,
  }) async {
    try {
      return await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error al iniciar sesión: $e');
      rethrow;
    }
  }

  /// Cerrar sesión actual
  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
  }

  /// Obtener información del usuario actual
  Future<User> getCurrentUser() async {
    return await account.get();
  }

  /// Obtener lista de misiones filtradas por deporte y dificultad
  Future<List<Mission>> getMissions({
    required String sport,
    required String difficulty,
  }) async {
    try {
      final response = await database.listDocuments(
        databaseId: databaseId,
        collectionId: missionCollectionId,
        queries: [
          Query.equal('sport', sport),
          Query.equal('difficulty', difficulty),
        ],
      );

      return response.documents
          .map((doc) => Mission.fromJson(doc.data))
          .toList();
    } catch (e) {
      print('Error al obtener misiones: $e');
      return [];
    }
  }
}


