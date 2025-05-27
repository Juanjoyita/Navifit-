// lib/services/appwrite_service.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart'; // Mantener como models para User, Session, DocumentList
import '../models/mission_model.dart';

class AppwriteService {
  // El cliente debe ser final y se inicializa en el constructor
  final Client client;
  late Account account;
  late Databases database;
  late Storage storage;

  // IDs de base de datos y colección para misiones
  // ¡ASEGÚRATE DE QUE ESTOS IDs SEAN LOS CORRECTOS DE TU PROYECTO APPWRITE!
  final String databaseId = '680e512b0007f0381936';
  final String missionCollectionId = '681290670039287a54df';

  // CONSTRUCTOR CORREGIDO: Recibe el Client ya configurado
  AppwriteService({required this.client}) {
    account = Account(client);
    database = Databases(client); // Usa el cliente recibido
    storage = Storage(client);
  }

  /// Registrar un nuevo usuario
  Future<User> register({
    required String email,
    required String password,
    String? name, // Name puede ser opcional al crear una cuenta en Appwrite
    // userId y secret no son parámetros estándar aquí.
    // userId se genera con ID.unique() por defecto si no se pasa.
    // secret no existe en account.create.
  }) async {
    return await account.create(
      userId: ID.unique(), // Appwrite genera un ID único si no se proporciona
      email: email,
      password: password,
      name: name,
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
  // CORRECCIÓN: Hacemos sport y difficulty opcionales (nullable)
  Future<List<Mission>> getMissions({
    String? sport, // Ahora es opcional
    String? difficulty, // Ahora es opcional
  }) async {
    try {
      List<String> queries = [];
      if (sport != null && sport.isNotEmpty) {
        queries.add(Query.equal('sport', sport));
      }
      if (difficulty != null && difficulty.isNotEmpty) {
        queries.add(Query.equal('difficulty', difficulty));
      }

      // Si queries está vacía, listDocuments devolverá todos los documentos.
      DocumentList response = await database.listDocuments(
        databaseId: databaseId,
        collectionId: missionCollectionId,
        queries: queries,
      );

      print('AppwriteService: Documentos recibidos: ${response.documents.length}');

      if (response.documents.isEmpty) {
        print('AppwriteService: No se encontraron documentos para los filtros.');
      }

      return response.documents
          .map((doc) {
            print('AppwriteService: Procesando documento: ${doc.data}');
            return Mission.fromJson(doc.data);
          })
          .toList();
    } catch (e) {
      print('AppwriteService: Error al obtener misiones: $e');
      // Es mejor lanzar una excepción para que el controlador pueda manejarla
      throw Exception('Failed to load missions from Appwrite: $e');
    }
  }

  // Puedes añadir métodos para crear, actualizar, eliminar misiones, etc.
}