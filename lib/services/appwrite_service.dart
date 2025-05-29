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

  // IDs de base de datos y colecciones (tus IDs)
  final String databaseId = '680e512b0007f0381936';
  final String missionCollectionId = '681290670039287a54df';
  final String userRoutesCollectionId = '68122e3200197b0a383a'; // Colección para rutas

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
    try {
      return await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
    } catch (e) {
      print('AppwriteService - Error al registrar: $e');
      rethrow;
    }
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
      print('AppwriteService - Error al iniciar sesión: $e');
      rethrow;
    }
  }

  /// Cerrar sesión actual
  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
      print('AppwriteService - Sesión cerrada exitosamente.');
    } catch (e) {
      print('AppwriteService - Error al cerrar sesión: $e');
      rethrow;
    }
  }

  /// Obtener información del usuario actual
  Future<User> getCurrentUser() async {
    try {
      return await account.get();
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar el nombre del usuario actual
  Future<void> updateUserName(String newName) async {
    try {
      await account.updateName(name: newName);
      print('AppwriteService - Nombre actualizado exitosamente: $newName');
    } on AppwriteException catch (e) {
      print('AppwriteService - Error de Appwrite al actualizar nombre: $e');
      rethrow; // Re-lanzar la excepción para que AuthController la maneje
    } catch (e) {
      print('AppwriteService - Error inesperado al actualizar nombre: $e');
      throw AppwriteException('Error al actualizar el nombre: ${e.toString()}');
    }
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

      print('AppwriteService - Documentos de misión recibidos: ${response.documents.length}');

      return response.documents
          .map((doc) {
            return Mission.fromJson(doc.data);
          })
          .toList();
    } catch (e) {
      print('AppwriteService - Error al obtener misiones: $e');
      throw Exception('Failed to load missions from Appwrite: $e');
    }
  }

  // ============== MÉTODOS PARA RUTAS DE USUARIO ==============

  /// Crear una nueva ruta de usuario
  Future<RouteModel> createUserRoute(RouteModel route) async {
    try {
      final User user = await getCurrentUser();
      
      final Map<String, dynamic> routeData = route.toJson();
      // Asegurar que el userId de la ruta sea el del usuario actual
      routeData['userId'] = user.$id; 

      final Document response = await database.createDocument(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        documentId: ID.unique(),
        data: routeData,
        permissions: [
          Permission.read(Role.user(user.$id)),
          Permission.write(Role.user(user.$id)),
        ],
      );

      print('AppwriteService - Ruta creada exitosamente: ${response.$id}');
      
      return RouteModel.fromJson({
        ...response.data,
        '\$id': response.$id,
        '\$createdAt': response.$createdAt,
        '\$updatedAt': response.$updatedAt,
      });
    } catch (e) {
      print('AppwriteService - Error al crear ruta: $e');
      rethrow;
    }
  }

  /// Obtener todas las rutas del usuario actual
  Future<List<RouteModel>> getUserRoutes() async {
    try {
      final User user = await getCurrentUser();
      
      final DocumentList response = await database.listDocuments(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        queries: [
          Query.equal('userId', user.$id),
          Query.orderDesc('\$createdAt'),
        ],
      );

      print('AppwriteService - Rutas del usuario obtenidas: ${response.documents.length}');

      return response.documents
          .map((doc) => RouteModel.fromJson({
            ...doc.data,
            '\$id': doc.$id,
            '\$createdAt': doc.$createdAt,
            '\$updatedAt': doc.$updatedAt,
          }))
          .toList();
    } catch (e) {
      print('AppwriteService - Error al obtener rutas del usuario: $e');
      rethrow;
    }
  }

  /// Obtener una ruta específica por ID
  Future<RouteModel?> getUserRouteById(String routeId) async {
    try {
      final Document response = await database.getDocument(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        documentId: routeId,
      );

      return RouteModel.fromJson({
        ...response.data,
        '\$id': response.$id,
        '\$createdAt': response.$createdAt,
        '\$updatedAt': response.$updatedAt,
      });
    } catch (e) {
      print('AppwriteService - Error al obtener ruta por ID: $e');
      if (e is AppwriteException && e.code == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// Actualizar una ruta existente
  Future<RouteModel> updateUserRoute(String routeId, RouteModel updatedRoute) async {
    try {
      final Map<String, dynamic> routeData = updatedRoute.toJson();
      routeData.remove('id'); 
      routeData.remove('createdAt');
      routeData.remove('updatedAt');

      final Document response = await database.updateDocument(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        documentId: routeId,
        data: routeData,
      );

      print('AppwriteService - Ruta actualizada exitosamente: $routeId');
      
      return RouteModel.fromJson({
        ...response.data,
        '\$id': response.$id,
        '\$createdAt': response.$createdAt,
        '\$updatedAt': response.$updatedAt,
      });
    } catch (e) {
      print('AppwriteService - Error al actualizar ruta: $e');
      rethrow;
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

      print('AppwriteService - Ruta eliminada exitosamente: $routeId');
    } catch (e) {
      print('AppwriteService - Error al eliminar ruta: $e');
      rethrow;
    }
  }

  /// Contar el número total de rutas del usuario
  Future<int> getUserRoutesCount() async {
    try {
      final User user = await getCurrentUser();
      
      final DocumentList response = await database.listDocuments(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        queries: [
          Query.equal('userId', user.$id),
          Query.limit(1),
        ],
      );

      return response.total;
    } catch (e) {
      print('AppwriteService - Error al contar rutas: $e');
      return 0;
    }
  }

  /// Buscar rutas por nombre para el usuario actual
  Future<List<RouteModel>> searchUserRoutes(String searchTerm) async {
    try {
      final User user = await getCurrentUser();
      
      final response = await database.listDocuments(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        queries: [
          Query.equal('userId', user.$id),
          Query.search('name', searchTerm),
          Query.orderDesc('\$createdAt'),
        ],
      );

      print('AppwriteService - Rutas encontradas en búsqueda: ${response.documents.length}');

      return response.documents
          .map((doc) => RouteModel.fromJson({
            ...doc.data,
            '\$id': doc.$id,
            '\$createdAt': doc.$createdAt,
            '\$updatedAt': doc.$updatedAt,
          }))
          .toList();
    } catch (e) {
      print('AppwriteService - Error al buscar rutas: $e');
      rethrow;
    }
  }
}