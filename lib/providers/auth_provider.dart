import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  
  // 🔥 NUEVO: Flag para ignorar cambios de auth durante el registro
  bool _isRegistering = false;

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
      // 🔥 NUEVO: Ignorar cambios de auth durante el registro
      if (_isRegistering) {
        return;
      }
      
      _user = state.session?.user;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
  }

  void _clearError() {
    _errorMessage = null;
  }

// REGISTRO
Future<bool> signUp({
  required String email,
  required String password,
  String? nombre,
}) async {
  _setLoading(true);
  _clearError();
  
  // 🔥 NUEVO: Activar flag de registro
  _isRegistering = true;

  try {
    await _authService.signUp(
      email: email,
      password: password,
      nombre: nombre,
    );
    
    // 🔥 NUEVO: Asegurar que el usuario NO esté establecido
    _user = null;
    
    _setLoading(false);
    
    // 🔥 NUEVO: Desactivar flag después de un pequeño delay
    // para dar tiempo a que se complete el signOut en el service
    Future.delayed(const Duration(milliseconds: 500), () {
      _isRegistering = false;
    });
    
    notifyListeners();
    return true;
  } on AuthServiceException catch (e) {
    _isRegistering = false; // Desactivar flag en caso de error
    _setError(e.mensaje);
    _setLoading(false);
    return false;
  } catch (e) {
    _isRegistering = false; // Desactivar flag en caso de error
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

  // LOGOUT
  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _user = null;
    _setLoading(false);
    notifyListeners();
  }

  // RESET PASSWORD
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
}
