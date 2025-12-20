import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTest {
  // Test Firestore
  static Future<void> testFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('test')
          .doc('connection_test')
          .set({
            'message': 'Firestore is working!',
            'timestamp': DateTime.now(),
          });
      print('✅ Firestore test: SUCCESS');
    } catch (e) {
      print('❌ Firestore test FAILED: $e');
    }
  }

  // Test Firebase Auth
  static Future<void> testAuth() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      print('✅ Auth test: Current user = ${user?.uid ?? "No user"}');
    } catch (e) {
      print('❌ Auth test FAILED: $e');
    }
  }

  // Vérification Firebase initialisation
  static Future<void> checkFirebase() async {
    try {
      final app = Firebase.app();
      print('✅ Firebase initialized: ${app.name}');
    } catch (e) {
      print('❌ Firebase NOT initialized: $e');
    }
  }
}
