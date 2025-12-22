import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProduitsMenagersPage extends StatefulWidget {
  final List<String> subcategories;

  const ProduitsMenagersPage({super.key, required this.subcategories});

  @override
  State<ProduitsMenagersPage> createState() => _ProduitsMenagersPageState();
}

class _ProduitsMenagersPageState extends State<ProduitsMenagersPage> {
  final Map<String, List<Map<String, dynamic>>> _products = {
    'Détergent liquide': [
      {
        'name': 'Détergent liquide 5L',
        'price': 12.99,
        'description': 'Pour toutes surfaces',
      },
      {
        'name': 'Détergent concentré',
        'price': 15.99,
        'description': 'Haute efficacité',
      },
      {
        'name': 'Détergent écologique',
        'price': 18.99,
        'description': 'Bio dégradable',
      },
    ],
    'Eau de javel': [
      {'name': 'Javel 2.5L', 'price': 6.99, 'description': 'Désinfection'},
      {'name': 'Javel parfumée', 'price': 8.99, 'description': 'Lavande'},
      {
        'name': 'Javel sans chlore',
        'price': 10.99,
        'description': 'Alternative douce',
      },
    ],
    'Produits nettoyants': [
      {'name': 'Nettoyant vitres', 'price': 7.99, 'description': 'Sans traces'},
      {
        'name': 'Décapant four',
        'price': 9.99,
        'description': 'Dégraissant puissant',
      },
      {
        'name': 'Désodorisant',
        'price': 5.99,
        'description': 'Parfum fraîcheur',
      },
    ],
  };

  final Map<String, Map<String, dynamic>> _cart = {};
  int _selectedCategoryIndex = 0;

  void _addToCart(String productName, Map<String, dynamic> product) {
    setState(() {
      _cart[productName] = {
        ...product,
        'quantity': (_cart[productName]?['quantity'] ?? 0) + 1,
      };
    });
  }

  void _removeFromCart(String productName) {
    setState(() {
      if (_cart[productName] != null && _cart[productName]!['quantity'] > 1) {
        _cart[productName]!['quantity'] = _cart[productName]!['quantity'] - 1;
      } else {
        _cart.remove(productName);
      }
    });
  }

  double _getTotalPrice() {
    double total = 0;
    for (var product in _cart.values) {
      total += (product['price'] as double) * (product['quantity'] as int);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = widget.subcategories[_selectedCategoryIndex];
    final products = _products[currentCategory] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFF),
      body: Column(
        children: [
          // Header
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [Color(0xFF00838F), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.eco_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Écologique',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Produits Ménagers',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Nettoyage et entretien professionnel',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // Catégories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.subcategories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedCategoryIndex == index
                          ? const Color(0xFF00838F)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: _selectedCategoryIndex == index
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Produits
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final inCart = _cart[product['name']];

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image placeholder
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00838F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.cleaning_services_rounded,
                            color: Color(0xFF00838F),
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          product['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00838F),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),

                        Text(
                          product['description'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${product['price']}€',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),

                            if (inCart != null)
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _removeFromCart(product['name']),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                  Text(
                                    '${inCart['quantity']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _addToCart(product['name'], product),
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              )
                            else
                              ElevatedButton(
                                onPressed: () =>
                                    _addToCart(product['name'], product),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00838F),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Ajouter',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (index * 100).ms);
              },
            ),
          ),

          // Panier résumé
          if (_cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_cart.values.fold<int>(0, (sum, product) => sum + (product['quantity'] as int))} articles',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Total: ${_getTotalPrice().toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00838F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showProductDetails(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00838F)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Voir détails',
                            style: TextStyle(color: Color(0xFF00838F)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _placeOrder(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00838F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Commander',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showProductDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Conseils d\'utilisation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00838F),
                ),
              ),
              const SizedBox(height: 16),
              _buildAdviceItem('Diluer correctement selon les instructions'),
              _buildAdviceItem('Porter des gants de protection'),
              _buildAdviceItem('Ne pas mélanger différents produits'),
              _buildAdviceItem('Conserver hors de portée des enfants'),
              const SizedBox(height: 20),
              const Text(
                'Ces produits sont écologiques et respectueux de l\'environnement.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdviceItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF00838F),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _placeOrder() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Commander',
            style: TextStyle(color: Color(0xFF00838F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Voulez-vous commander ces produits ?'),
              const SizedBox(height: 16),
              ..._cart.entries.map((entry) {
                final product = entry.value;
                return ListTile(
                  title: Text(entry.key),
                  subtitle: Text(
                    '${product['price']}€ × ${product['quantity']}',
                  ),
                  trailing: Text(
                    '${((product['price'] as double) * (product['quantity'] as int)).toStringAsFixed(2)}€',
                  ),
                );
              }),
              Divider(color: Colors.grey.shade300),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_getTotalPrice().toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00838F),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showOrderSuccess();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00838F),
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderSuccess() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 60, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                'Commande confirmée !',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Votre commande sera livrée sous 24h.'),
              const SizedBox(height: 16),
              Text('Référence: CMD-${DateTime.now().millisecondsSinceEpoch}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _cart.clear();
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
