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
  /// IMPORTANTE: Si el usuario no está logueado, esta función lanzará una AppwriteException.
  /// Tu AuthController debe manejar esto para establecer el usuario como null.
  Future<User> getCurrentUser() async {
    try {
      return await account.get();
    } catch (e) {
      // No imprimas el error aquí si esperas que el usuario no esté logueado
      // La intención es que el AuthController capture esto para saber si hay usuario.
      // print('AppwriteService - Error al obtener usuario actual: $e');
      rethrow; // Relanza el error para que AuthController lo capture
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
            // Asegúrate de que tu Mission.fromJson maneje '$id' si lo usas
            // print('AppwriteService - Procesando documento de misión: ${doc.data}');
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
      final User user = await getCurrentUser(); // Obtener el usuario actual
      
      // Prepara los datos para Appwrite incluyendo el userId y asegurando que sea String
      final Map<String, dynamic> routeData = route.toJson();
      routeData['userId'] = user.$id; // Asocia la ruta con el ID del usuario actual

      final Document response = await database.createDocument(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        documentId: ID.unique(), // Deja que Appwrite genere un ID único
        data: routeData,
        // *** IMPORTANTE: Define permisos aquí. Por defecto, solo el creador puede leer/escribir. ***
        permissions: [
          Permission.read(Role.user(user.$id)),
          Permission.write(Role.user(user.$id)),
          // Puedes añadir Permission.read(Role.any()) si quieres que sean rutas públicas
        ],
      );

      print('AppwriteService - Ruta creada exitosamente: ${response.$id}');
      
      // Retorna el RouteModel creado con el ID de Appwrite
      return RouteModel.fromJson({
        ...response.data,
        '\$id': response.$id, // Usa el ID generado por Appwrite para el modelo
        '\$createdAt': response.$createdAt,
        '\$updatedAt': response.$updatedAt,
      });
    } catch (e) {
      print('AppwriteService - Error al crear ruta: $e');
      rethrow; // Relanza el error para que el controlador lo maneje
    }
  }

  /// Obtener todas las rutas del usuario actual
  Future<List<RouteModel>> getUserRoutes() async {
    try {
      final User user = await getCurrentUser(); // Obtener el usuario actual
      
      final DocumentList response = await database.listDocuments(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        queries: [
          Query.equal('userId', user.$id), // Filtra por el ID del usuario actual
          Query.orderDesc('\$createdAt'), // Ordena por fecha de creación, más recientes primero
        ],
      );

      print('AppwriteService - Rutas del usuario obtenidas: ${response.documents.length}');

      return response.documents
          .map((doc) => RouteModel.fromJson({
            ...doc.data,
            '\$id': doc.$id, // Asegura que el ID de Appwrite se mapee a 'id' en RouteModel
            '\$createdAt': doc.$createdAt,
            '\$updatedAt': doc.$updatedAt,
          }))
          .toList();
    } catch (e) {
      print('AppwriteService - Error al obtener rutas del usuario: $e');
      rethrow; // Relanza el error
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

      // Mapea el ID de Appwrite al campo 'id' de tu modelo
      return RouteModel.fromJson({
        ...response.data,
        '\$id': response.$id,
        '\$createdAt': response.$createdAt,
        '\$updatedAt': response.$updatedAt,
      });
    } catch (e) {
      print('AppwriteService - Error al obtener ruta por ID: $e');
      // Si es un error 404 (documento no encontrado), podrías retornar null
      if (e is AppwriteException && e.code == 404) {
        return null;
      }
      rethrow; // Relanza otros errores
    }
  }

  /// Actualizar una ruta existente
  Future<RouteModel> updateUserRoute(String routeId, RouteModel updatedRoute) async {
    try {
      // No necesitas volver a obtener el usuario aquí si `updatedRoute` ya contiene el `userId`
      // y si confías en que el `RouteController` solo enviará rutas del usuario actual.
      // Si la seguridad fuera extrema, podrías verificar el userId antes de actualizar.
      
      final Map<String, dynamic> routeData = updatedRoute.toJson();
      // Eliminar el campo 'id' si tu toJson lo incluye y Appwrite no lo espera para la actualización
      routeData.remove('id'); 
      // Appwrite tampoco espera '\$createdAt' ni '\$updatedAt' en el data para update
      routeData.remove('createdAt');
      routeData.remove('updatedAt');

      final Document response = await database.updateDocument(
        databaseId: databaseId,
        collectionId: userRoutesCollectionId,
        documentId: routeId,
        data: routeData, // Pasa solo los campos que quieres actualizar
        // Puedes actualizar los permisos si es necesario
      );

      print('AppwriteService - Ruta actualizada exitosamente: $routeId');
      
      return RouteModel.fromJson({
        ...response.data,
        '\$id': response.$id, // Mapea el ID de Appwrite al campo 'id'
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
          Query.limit(1), // Solo necesitamos el conteo, no los documentos completos
        ],
      );

      return response.total;
    } catch (e) {
      print('AppwriteService - Error al contar rutas: $e');
      // Podrías retornar 0 o relanzar el error dependiendo de cómo quieras manejarlo
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
          Query.equal('userId', user.$id), // Solo rutas del usuario actual
          Query.search('name', searchTerm), // Busca en el campo 'name'
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