import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService;

  AuthProvider(this._authService) {
    // Escuta mudanças de autenticação
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? _user;
  bool _loading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.signInWithEmail(email: email, password: password);
      // _user será atualizado pelo listener
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e));
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.registerWithEmail(email: email, password: password);
      // Você pode decidir se volta para tela de login ou já considera logado
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e));
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'weak-password':
        return 'Senha muito fraca.';
      default:
        return 'Erro: ${e.message}';
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _authService.signInWithGoogle();

      // Se user == null, é porque o usuário cancelou a seleção da conta
      if (user == null) {
        _setError('Login com Google cancelado.');
      } else {
        _user = user;
      }
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e));
    } catch (e) {
      _setError('Erro inesperado: $e');
    } finally {
      _setLoading(false);
    }
  }
}
