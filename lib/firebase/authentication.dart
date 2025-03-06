import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final  _firestore = FirebaseFirestore.instance;

  get user => _auth.currentUser;

  get uid => user.uid;

  // Creates a new user with email and password
  Future<String?> signUp({required String email, required String password, required String firstName, required String lastName, required String username}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _createUserDocument(firstName: firstName, lastName: lastName, username: username, email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  String getUID() {
    return user.uid;
  }

  // Sign in method
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _saveLoginState();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
  Future<String?> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> _clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('deviceID');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }


  Future<void> _createUserDocument({required String firstName, required String lastName, required String username, required String email}) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final userData = {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'deviceID': '',
    };
    await userDoc.set(userData);
  }

  Future signOut() async {
    await _auth.signOut();
    await _clearLoginState();
  }

  Future<void> deleteAccount(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Reauthenticate user
        AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);

        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete user authentication account
        await user.delete();
        await _clearLoginState();
      }
    } catch (e) {
      print('Error deleting account: $e');
    }
  }
}