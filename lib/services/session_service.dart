import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

class SessionService {
  SessionService._();

  static final SessionService instance = SessionService._();

  final ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier(null);

  UserModel? get currentUser => currentUserNotifier.value;

  void setCurrentUser(UserModel? user) {
    currentUserNotifier.value = user;
  }

  Future<UserModel> requireCurrentUser() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No authenticated user in session');
    }
    return user;
  }
}
