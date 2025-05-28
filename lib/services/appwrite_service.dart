// lib/services/appwrite_service.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../models/mission_model.dart';
import '../models/route_model.dart';

class AppwriteService {
  final Client client;
  late Account account;
  late Databases database;
  late Storage storage;

  // IDs de base de datos y colecciones
  final String databaseId = '680e512b0007f0381936';
  final String missionCollectionId = '681290670039287a54df';
  final String userRoutesCollectionId = '68122e3200197b0a383a'; // Nueva colección para rutas

  AppwriteService({required this.client}) {
    account = Account(client);
    database = Databases(client);
    storage = Storage(client);
  }

  /// Registrar un nuevo usuario
  Future<User> register({
    required String email,
    required String password,
    String? name,
  }) async {
    return await account.create(
      userId: ID.unique(),
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
  Future<List<Mission>> getMissions({
    String? sport,
    String? difficulty,
  }) async {
    try {
      List<String> queries = [];
      if (sport != null && sport.isNotEmpty) {
        queries.add(Query.equal('sport', sport));
      }
      if (difficulty != null && difficulty.isNotEmpty) {
        queries.add(Query.equal('difficulty', difficulty));
      }

      DocumentList response = await database.listDocuments(
        databaseId: databaseId,
        collectionId: missionCollectionId,
        queries: queries,
      );

      print('AppwriteService: Documentos recibidos: ${response.documents.length}');

      return response.documents
          .map((doc) {
            print('AppwriteService: Procesando documento: ${doc.data}');
            return Mission.fromJson(doc.data);
          })
          .toList();
    } catch (e) {
      print('AppwriteService: Error al obtener misiones: $e');
      throw Exception('Failed to load missions from Appwrite: $e');
    }
  }

  // ============== MÉTODOS PARA RUTAS DE USUARIO ==============

  /// Crear una nueva ruta de usuario
  Future<RouteModel> createUserRoute(RouteModel route) async {
    try {
      // Obtener el usuario actual para asociar la ruta con el usuario
      final user = await getCurrentUser();
      
      // Preparar los datos para Appwrite incluyendo el userId
      final routeData = route.toJson();
      routeData['userId'] = user.$id; // Asociar la ruta con el usuario actual
      
      final response = await database.createDocument(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        documentId: ID.unique(),
        data: routeData,
      );

      print('AppwriteService: Ruta creada exitosamente: ${response.$id}');
      
      // Crear un nuevo RouteModel con el ID de Appwrite
      return RouteModel.fromJson({
        ...response.data,
        'id': response.$id, // Usar el ID generado por Appwrite
      });
    } catch (e) {
      print('AppwriteService: Error al crear ruta: $e');
      throw Exception('Failed to create user route: $e');
    }
  }

  /// Obtener todas las rutas del usuario actual
  Future<List<RouteModel>> getUserRoutes() async {
    try {
      final user = await getCurrentUser();
      
      final response = await database.listDocuments(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        queries: [
          Query.equal('userId', user.$id),
          Query.orderDesc('\$createdAt'), // Ordenar por fecha de creación, más recientes primero
        ],
      );

      print('AppwriteService: Rutas del usuario obtenidas: ${response.documents.length}');

      return response.documents
          .map((doc) {
            final routeData = doc.data;
            routeData['id'] = doc.$id; // Usar el ID del documento de Appwrite
            return RouteModel.fromJson(routeData);
          })
          .toList();
    } catch (e) {
      print('AppwriteService: Error al obtener rutas del usuario: $e');
      throw Exception('Failed to load user routes: $e');
    }
  }

  /// Obtener una ruta específica por ID
  Future<RouteModel?> getUserRouteById(String routeId) async {
    try {
      final response = await database.getDocument(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        documentId: routeId,
      );

      final routeData = response.data;
      routeData['id'] = response.$id;
      
      return RouteModel.fromJson(routeData);
    } catch (e) {
      print('AppwriteService: Error al obtener ruta por ID: $e');
      return null;
    }
  }

  /// Actualizar una ruta existente
  Future<RouteModel> updateUserRoute(String routeId, RouteModel updatedRoute) async {
    try {
      final user = await getCurrentUser();
      
      // Preparar los datos actualizados
      final routeData = updatedRoute.toJson();
      routeData['userId'] = user.$id; // Mantener la asociación con el usuario
      
      final response = await database.updateDocument(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        documentId: routeId,
        data: routeData,
      );

      print('AppwriteService: Ruta actualizada exitosamente: $routeId');
      
      return RouteModel.fromJson({
        ...response.data,
        'id': response.$id,
      });
    } catch (e) {
      print('AppwriteService: Error al actualizar ruta: $e');
      throw Exception('Failed to update user route: $e');
    }
  }

  /// Eliminar una ruta
  Future<void> deleteUserRoute(String routeId) async {
    try {
      await database.deleteDocument(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        documentId: routeId,
      );

      print('AppwriteService: Ruta eliminada exitosamente: $routeId');
    } catch (e) {
      print('AppwriteService: Error al eliminar ruta: $e');
      throw Exception('Failed to delete user route: $e');
    }
  }

  /// Contar el número total de rutas del usuario
  Future<int> getUserRoutesCount() async {
    try {
      final user = await getCurrentUser();
      
      final response = await database.listDocuments(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        queries: [
          Query.equal('userId', user.$id),
          Query.limit(1), // Solo necesitamos el conteo
        ],
      );

      return response.total;
    } catch (e) {
      print('AppwriteService: Error al contar rutas: $e');
      return 0;
    }
  }

  /// Buscar rutas por nombre
  Future<List<RouteModel>> searchUserRoutes(String searchTerm) async {
    try {
      final user = await getCurrentUser();
      
      final response = await database.listDocuments(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        queries: [
          Query.equal('userId', user.$id),
          Query.search('name', searchTerm),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return response.documents
          .map((doc) {
            final routeData = doc.data;
            routeData['id'] = doc.$id;
            return RouteModel.fromJson(routeData);
          })
          .toList();
    } catch (e) {
      print('AppwriteService: Error al buscar rutas: $e');
      throw Exception('Failed to search user routes: $e');
    }
  }
}