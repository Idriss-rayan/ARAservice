import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupère les produits ménagers
  Stream<List<ProductSearch>> getProduitsMenagers() {
    return _firestore
        .collection('produits_menagers')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return ProductSearch(
              id: doc.id,
              name: data['name'] ?? '',
              price: (data['price'] ?? 0).toDouble(),
              imageUrl: data['image'] ?? '',
              category: data['category'] ?? 'Ménager', // Ajout de la catégorie
            );
          }).toList(),
        );
  }

  /// Récupère les produits shopping
  Stream<List<ProductSearch>> getShoppingProducts() {
    return _firestore
        .collection('shopping_products')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return ProductSearch(
              id: doc.id,
              name: data['name'] ?? '',
              price: (data['price'] ?? 0).toDouble(),
              imageUrl: data['imageUrl'] ?? '',
              category: data['category'] ?? 'Shopping', // Ajout de la catégorie
            );
          }).toList(),
        );
  }

  /// Combine tous les produits
  Stream<List<ProductSearch>> getAllProducts() {
    return Rx.combineLatest2<
      List<ProductSearch>,
      List<ProductSearch>,
      List<ProductSearch>
    >(getProduitsMenagers(), getShoppingProducts(), (menagers, shopping) {
      return [...menagers, ...shopping];
    });
  }
}

/// Classe ProductSearch avec catégorie
class ProductSearch {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;

  ProductSearch({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
  });
}
