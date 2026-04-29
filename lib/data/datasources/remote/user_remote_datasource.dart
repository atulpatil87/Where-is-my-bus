import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbauth;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

class UserRemoteDataSource {
  final FirebaseFirestore _firestore;
  final fbauth.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  UserRemoteDataSource(this._firestore, this._auth, this._googleSignIn);

  Stream<fbauth.User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw const AuthException(message: 'Google sign-in cancelled.');
      final auth = await account.authentication;
      final credential = fbauth.GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);
      return _getOrCreateUser(userCred.user!, 'google');
    } on fbauth.FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Google sign-in failed.');
    }
  }

  Future<String> sendOTP(String phone) async {
    String verificationId = '';
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        throw AuthException(message: e.message ?? 'OTP send failed.');
      },
      codeSent: (id, _) => verificationId = id,
      codeAutoRetrievalTimeout: (_) {},
    );
    return verificationId;
  }

  Future<UserModel> verifyOTP(String otp, String verificationId) async {
    try {
      final credential = fbauth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final userCred = await _auth.signInWithCredential(credential);
      return _getOrCreateUser(userCred.user!, 'phone');
    } on fbauth.FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'OTP verification failed.');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<UserModel> getUserProfile(String userId) async {
    final doc = await _firestore
        .collection(FirebaseConstants.collectionUsers)
        .doc(userId)
        .get();
    if (!doc.exists) throw const NotFoundException(message: 'User profile not found.');
    final data = doc.data()!;
    data['id'] = doc.id;
    return UserModel.fromJson(data);
  }

  Future<void> updateProfile(UserModel user) async {
    await _firestore
        .collection(FirebaseConstants.collectionUsers)
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }

  Future<UserModel> _getOrCreateUser(fbauth.User fbUser, String provider) async {
    final doc = await _firestore
        .collection(FirebaseConstants.collectionUsers)
        .doc(fbUser.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return UserModel.fromJson(data);
    }

    final now = DateTime.now();
    final newUser = UserModel(
      id: fbUser.uid,
      name: fbUser.displayName ?? 'User',
      email: fbUser.email,
      phone: fbUser.phoneNumber,
      avatarUrl: fbUser.photoURL,
      authProvider: provider,
      selectedCities: const ['pune'],
      primaryCity: 'pune',
      savedRoutes: const [],
      savedStops: const [],
      preferences: const UserPreferencesModel(),
      stats: const UserStatsModel(),
      badges: const [],
      createdAt: now,
      lastActiveAt: now,
    );

    await _firestore
        .collection(FirebaseConstants.collectionUsers)
        .doc(fbUser.uid)
        .set(newUser.toJson());

    return newUser;
  }
}

class AuthException extends AppException {
  const AuthException({required super.message});
}
