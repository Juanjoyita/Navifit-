import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class AppwriteService {
  late Client client;
  late Account account;
  late Databases database;
  late Storage storage;

  AppwriteService() {
    client = Client()
      .setEndpoint('https://fra.cloud.appwrite.io/v1') // Tu Endpoint
      .setProject('67f4970e00257170a0c8');             // Tu Project ID

    account = Account(client);
    database = Databases(client);
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

  // Método para iniciar sesión (CORRECTO ahora)
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
}
