import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  Future<Map<String, dynamic>> call(Map<String, dynamic> userData) async {
    return await repository.register(userData);
  }
}