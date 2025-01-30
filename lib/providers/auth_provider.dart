import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smart_shopping/main.dart';
import 'package:string_literal_finder_annotations/string_literal_finder_annotations.dart';

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
        'success': true, // NON-NLS
      };
    } on FirebaseAuthException {
      return {
        'success': false, // NON-NLS
        'error': AppLocalizations.of(navigatorKey.currentContext!)! // NON-NLS
            .authenticationFailedError,
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
          .collection('users') // NON-NLS
          .doc(userCredentials.user!.uid)
          .set({
        'username': username, // NON-NLS
        'email': email, // NON-NLS
      });

      return {
        'success': true, // NON-NLS
      };
    } catch (e) {
      return {
        'success': false, // NON-NLS
        'error': AppLocalizations.of(navigatorKey.currentContext!)! // NON-NLS
            .accountCreationError,
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

      final storedUser = await FirebaseFirestore.instance
          .doc('/users/${user.uid}') // NON-NLS
          .get(); // NON-NLS

      if (!storedUser.exists) {
        await FirebaseFirestore.instance
            .collection(nonNls('users'))
            .doc(user.uid)
            .set({
          'username': googleUser.displayName, // NON-NLS
          'email': googleUser.email, // NON-NLS
        });
      }

      return {
        'success': true, // NON-NLS
      };
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack);
      return {
        'success': false, // NON-NLS
        'error': // NON-NLS
            AppLocalizations.of(navigatorKey.currentContext!)!.googleLoginError,
      };
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
