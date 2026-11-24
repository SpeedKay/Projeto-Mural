import '../../../core/api/api_client.dart';
import '../model/login_response_dto.dart';

abstract interface class AuthRepository {
  Future<LoginResponseDto> login(
    String username,
    String password,
  );
}

class HttpAuthRepository implements AuthRepository {
  const HttpAuthRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<LoginResponseDto> login(
    String username,
    String password,
  ) async {
    final json = await _apiClient.post('/auth/login', {
      'username': username,
      'password': password,
    });

    return LoginResponseDto.fromJson(
      json as Map<String, dynamic>,
    );
  }
}