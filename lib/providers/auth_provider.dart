import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isLoggedIn => _user != null;
  String? get userEmail => _user?.email;
  String? get userName => _user?.userMetadata?['nombre'];

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _user = _authService.currentUser;
    
    _authService.authStateChanges.listen((AuthState state) {
      _user = state.session?.user;
      notifyListeners();
    });
  }

  // REGISTRO
  Future<bool> signUp({
    required String email,
    required String password,
    String? nombre,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        nombre: nombre,
      );
      _user = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } on AuthServiceException catch (e) {
      _setError(e.mensaje);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  // LOGIN
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signIn(
        email: email,
        password: password,
      );
      _user = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } on AuthServiceException catch (e) {
      _setError(e.mensaje);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  // CERRAR SESIÓN
  Future<bool> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _user = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } on AuthServiceException catch (e) {
      _setError(e.mensaje);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  // RESTABLECER CONTRASEÑA
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } on AuthServiceException catch (e) {
      _setError(e.mensaje);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  // ACTUALIZAR CONTRASEÑA
  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updatePassword(newPassword);
      _setLoading(false);
      return true;
    } on AuthServiceException catch (e) {
      _setError(e.mensaje);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  // OBTENER PERFIL
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      return await _authService.getUserProfile();
    } catch (e) {
      _setError('Error al obtener perfil: $e');
      return null;
    }
  }

  // ACTUALIZAR PERFIL
  Future<bool> updateProfile({String? nombre}) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateProfile(nombre: nombre);
      _user = _authService.currentUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } on AuthServiceException catch (e) {
      _setError(e.mensaje);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}