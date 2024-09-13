import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  final _googleSignIn = GoogleSignIn();
  final _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<bool> build() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  Future<Map<String, dynamic>> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {
        'success': true,
      };
    } on FirebaseAuthException {
      return {
        'success': false,
        'error': 'Problema na autenticação. Verifique suas credenciais.',
      };
    }
  }

  Future<Map<String, dynamic>> signUpWithEmailAndPassword(
      {required String email,
      required String password,
      required String username}) async {
    try {
      final userCredentials =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .set({
        'username': username,
        'email': email,
      });

      return {
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao criar conta.',
      };
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _googleSignIn.signOut();
        throw Exception('Usuário não autorizado');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = FirebaseAuth.instance.currentUser!;

      final storedUser =
          await FirebaseFirestore.instance.doc('/users/${user.uid}').get();

      if (!storedUser.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': googleUser.displayName,
          'email': googleUser.email,
        });
      }

      return {
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao realizar login com o Google. Tente novamente.',
      };
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
