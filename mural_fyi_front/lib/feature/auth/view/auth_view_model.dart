import 'package:flutter/foundation.dart';

import '../../../core/api/auth_session.dart';
import '../repository/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository, this._session) {
    _session.addListener(notifyListeners);
  }

  final AuthRepository _repository;
  final AuthSession _session;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _session.isAuthenticated;

  Future<bool> login(
      String username,
      String password,
      ) async {
    if (isLoading) return false;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final response = await _repository.login(
        username,
        password,
      );

      _session.start(
        response.accessToken,
        Duration(
          minutes: response.expiresInMinutes,
        ),
      );

      return isAuthenticated;
    } catch (error) {
      _errorMessage = error.toString();

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  void logout() {
    _errorMessage = null;
    _session.clear();
  }

  @override
  void dispose() {
    _session.removeListener(notifyListeners);
    super.dispose();
  }
}