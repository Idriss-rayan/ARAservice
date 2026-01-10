import 'package:araservice/main_navigation_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream pour récupérer tous les produits
  Stream<List<Product>> getAllProducts() {
    return _firestore
        .collection('shopping_products')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Récupérer les produits populaires
  Stream<List<Product>> getPopularProducts() {
    return _firestore
        .collection('shopping_products')
        // Filtre uniquement si isPopular existe et vaut true
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromFirestore(doc.data(), doc.id))
              .where((product) => product.isPopular ?? false)
              .toList(),
        );
  }

  // Récupérer les nouveautés
  Stream<List<Product>> getNewProducts() {
    return _firestore
        .collection('shopping_products')
        // Filtre uniquement si isNew existe et vaut true
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromFirestore(doc.data(), doc.id))
              .where((product) => product.isNew ?? false)
              .toList(),
        );
  }

  // Rechercher des produits
  Stream<List<Product>> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return _firestore
        .collection('shopping_products')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromFirestore(doc.data(), doc.id))
              .where(
                (product) =>
                    product.name.toLowerCase().contains(lowerQuery) ||
                    (product.description ?? '').toLowerCase().contains(
                      lowerQuery,
                    ),
              )
              .toList(),
        );
  }

  // Filtrer par catégorie
  Stream<List<Product>> getProductsByCategory(String category) {
    final lowerCategory = category.toLowerCase();
    return _firestore
        .collection('shopping_products')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Product.fromFirestore(doc.data(), doc.id))
              .where(
                (product) =>
                    (product.category ?? '').toLowerCase() == lowerCategory,
              )
              .toList(),
        );
  }
}
