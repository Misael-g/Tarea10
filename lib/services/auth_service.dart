import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthException implements Exception {
  final String mensaje;
  AuthException(this.mensaje);

  @override
  String toString() => mensaje;
}

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener usuario actual
  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  String? get userEmail => currentUser?.email;
  String? get userId => currentUser?.id;

  // Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // REGISTRO de nuevo usuario
  Future<User> signUp({
    required String email,
    required String password,
    String? nombre,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: nombre != null ? {'nombre': nombre} : null,
      );

      if (response.user == null) {
        throw AuthException('Error al crear la cuenta');
      }

      return response.user!;
    } on AuthException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('already registered')) {
        throw AuthException('Este correo ya está registrado');
      } else if (e.toString().contains('Invalid email')) {
        throw AuthException('Correo electrónico inválido');
      } else if (e.toString().contains('Password should be at least')) {
        throw AuthException('La contraseña debe tener al menos 6 caracteres');
      }
      throw AuthException('Error al registrar: ${e.toString()}');
    }
  }

  // LOGIN con email y contraseña
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Error al iniciar sesión');
      }

      return response.user!;
    } on AuthException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        throw AuthException('Correo o contraseña incorrectos');
      } else if (e.toString().contains('Email not confirmed')) {
        throw AuthException('Debes confirmar tu correo electrónico');
      }
      throw AuthException('Error al iniciar sesión: ${e.toString()}');
    }
  }

  // CERRAR SESIÓN
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthException('Error al cerrar sesión: ${e.toString()}');
    }
  }

  // ENVIAR EMAIL de restablecimiento de contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: SupabaseConfig.resetPasswordUrl,
      );
    } catch (e) {
      if (e.toString().contains('not found')) {
        throw AuthException('No existe una cuenta con este correo');
      }
      throw AuthException('Error al enviar correo: ${e.toString()}');
    }
  }

  // ACTUALIZAR CONTRASEÑA (después de hacer clic en el enlace del correo)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthException('Error al actualizar contraseña: ${e.toString()}');
    }
  }

  // OBTENER PERFIL del usuario
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      // Aquí podrías obtener datos adicionales del usuario desde una tabla de perfiles
      return {
        'id': currentUser!.id,
        'email': currentUser!.email,
        'nombre': currentUser!.userMetadata?['nombre'],
        'created_at': currentUser!.createdAt,
      };
    } catch (e) {
      throw AuthException('Error al obtener perfil: ${e.toString()}');
    }
  }

  // ACTUALIZAR PERFIL
  Future<void> updateProfile({String? nombre}) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {'nombre': nombre},
        ),
      );
    } catch (e) {
      throw AuthException('Error al actualizar perfil: ${e.toString()}');
    }
  }

  // VERIFICAR si el email está confirmado
  bool get isEmailConfirmed {
    return currentUser?.emailConfirmedAt != null;
  }

  // REENVIAR email de confirmación
  Future<void> resendConfirmationEmail() async {
    try {
      if (currentUser?.email == null) {
        throw AuthException('No hay usuario autenticado');
      }
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: currentUser!.email!,
      );
    } catch (e) {
      throw AuthException('Error al reenviar email: ${e.toString()}');
    }
  }
}