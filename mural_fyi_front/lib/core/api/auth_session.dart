import 'dart:async';
import 'package:flutter/foundation.dart';

class AuthSession extends ChangeNotifier {
  String? _token;
  DateTime? _expiresAt;
  Timer? _expirationTimer;

  String? get token =>
      _expiresAt != null &&
      DateTime.now().isBefore(_expiresAt!)
          ? _token
          : null;

  bool get isAuthenticated => token != null;

  void start(String token, Duration duration) {
    _expirationTimer?.cancel();

    _token = token;
    _expiresAt = DateTime.now().add(duration);
    _expirationTimer = Timer(duration, clear);

    notifyListeners();
  }

  void clear() {
    _expirationTimer?.cancel();
    _expirationTimer = null;
    _token = null;
    _expiresAt = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _expirationTimer?.cancel();
    super.dispose();
  }
}