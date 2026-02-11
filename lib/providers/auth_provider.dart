import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/firebase_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _service = FirebaseService();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<void> signUp(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name di Firebase Auth
    await credential.user!.updateDisplayName(name);

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      role: 'user',
    );

    await _service.saveUser(user.toMap(), user.uid);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _service.getUser(credential.user!.uid);
    _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
