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
      .setEndpoint('https://fra.cloud.appwrite.io/v1')
      .setProject('67f4970e00257170a0c8');

    account = Account(client);
    database = databases; // Usa la instancia que recibes
    storage = Storage(client);
  }

  // Método para registrar un usuario
  Future<User> register({required String email, required String password, required String name}) async {
    return await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }

  // Método para iniciar sesión
  Future<Session> login({required String email, required String password}) async {
    return await account.createEmailSession(
      email: email,
      password: password,
    );
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
  }

  // Método para obtener el usuario actual
  Future<User> getCurrentUser() async {
    return await account.get();
  }

  // Método para obtener misiones filtradas por deporte y dificultad usando tu modelo Mission
  Future<List<Mission>> getMissions( {required String sport, required String difficulty}) async {
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
