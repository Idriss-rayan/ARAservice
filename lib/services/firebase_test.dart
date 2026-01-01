import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createOrder({
    required Map<String, dynamic> formData,
    required int categoryIndex,
    required List<String> categories,
    required int imagesCount,
    required String whatsappMessage,
  }) async {
    final user = _auth.currentUser;

    await _firestore.collection('orders').add({
      // utilisateur
      'userId': user?.uid,
      'customerName': formData['customer_name'],
      'customerPhone': formData['customer_phone'],
      'customerEmail': formData['customer_email'],

      // type de service
      'serviceType':
          categories[categoryIndex], // Confection / Retouches / Prêt-à-porter
      // contenu de la commande
      'formData': formData,
      'imagesCount': imagesCount,
      'whatsappMessage': whatsappMessage,

      // statut
      'status': 'En attente',

      // dates
      'date': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
