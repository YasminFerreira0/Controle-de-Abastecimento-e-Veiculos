import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<User?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  Future<void> signOut() => _auth.signOut();

  Future<User?> signInWithGoogle() async {
    // Passo 1: abrir o popup / seleção de conta Google
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Se o usuário cancelou o login (fechou a janela)
    if (googleUser == null) {
      return null;
    }

    // Passo 2: pegar os tokens de autenticação
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Passo 3: criar a credencial para o Firebase
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Passo 4: logar no Firebase com essa credencial
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  
}
