import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ShoppingPage extends StatefulWidget {
  final List<String> subcategories;

  const ShoppingPage({super.key, required this.subcategories});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final Map<String, List<Map<String, dynamic>>> _productsByCategory = {
    'Draps': [
      {'name': 'Drap housse 90x200', 'price': 25.99, 'stock': 50},
      {'name': 'Drap housse 140x200', 'price': 35.99, 'stock': 30},
      {'name': 'Drap plat 240x250', 'price': 45.99, 'stock': 20},
    ],
    'Couettes': [
      {'name': 'Couette été 135x200', 'price': 79.99, 'stock': 15},
      {'name': 'Couette hiver 200x200', 'price': 129.99, 'stock': 10},
      {'name': 'Couette 4 saisons', 'price': 159.99, 'stock': 8},
    ],
    'Nappes de prière': [
      {'name': 'Nappe simple', 'price': 19.99, 'stock': 100},
      {'name': 'Nappe décorée', 'price': 34.99, 'stock': 60},
      {'name': 'Nappe premium', 'price': 49.99, 'stock': 30},
    ],
    'Tapis': [
      {'name': 'Tapis de salon', 'price': 89.99, 'stock': 25},
      {'name': 'Tapis de prière', 'price': 29.99, 'stock': 80},
      {'name': 'Tapis bébé', 'price': 39.99, 'stock': 40},
    ],
    'Sacs': [
      {'name': 'Sac à main', 'price': 49.99, 'stock': 45},
      {'name': 'Sac de voyage', 'price': 79.99, 'stock': 25},
      {'name': 'Sac à dos', 'price': 39.99, 'stock': 60},
    ],
    'Chaussures': [
      {'name': 'Chaussures ville', 'price': 69.99, 'stock': 40},
      {'name': 'Chaussures maison', 'price': 19.99, 'stock': 120},
      {'name': 'Chaussures sport', 'price': 89.99, 'stock': 30},
    ],
    'Parfums': [
      {'name': 'Eau de toilette', 'price': 39.99, 'stock': 70},
      {'name': 'Eau de parfum', 'price': 69.99, 'stock': 50},
      {'name': 'Parfum oriental', 'price': 89.99, 'stock': 20},
    ],
  };

  final Map<String, int> _cart = {};
  int _selectedCategoryIndex = 0;

  void _addToCart(String productName) {
    setState(() {
      _cart[productName] = (_cart[productName] ?? 0) + 1;
    });
  }

  void _removeFromCart(String productName) {
    setState(() {
      if (_cart[productName] != null && _cart[productName]! > 1) {
        _cart[productName] = _cart[productName]! - 1;
      } else {
        _cart.remove(productName);
      }
    });
  }

  double _getTotalPrice() {
    double total = 0;
    for (var entry in _cart.entries) {
      final product = _productsByCategory.values
          .expand((list) => list)
          .firstWhere((p) => p['name'] == entry.key);
      total += (product['price'] as double) * entry.value;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = widget.subcategories[_selectedCategoryIndex];
    final products = _productsByCategory[currentCategory] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFF),
      body: Column(
        children: [
          // Header
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [Color(0xFF1565C0), Color(0xFF2196F3)],
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
                      Badge(
                        label: Text('${_cart.length}'),
                        backgroundColor: Colors.red,
                        child: IconButton(
                          onPressed: () => _showCartDialog(),
                          icon: const Icon(
                            Icons.shopping_cart_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Shopping',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Courses et achats du quotidien',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          // Catégories horizontales
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: widget.subcategories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(widget.subcategories[index]),
                    selected: _selectedCategoryIndex == index,
                    selectedColor: const Color(0xFF1565C0),
                    labelStyle: TextStyle(
                      color: _selectedCategoryIndex == index
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Liste des produits
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final inCart = _cart[product['name']] ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Image placeholder
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.shopping_basket_rounded,
                              color: Color(0xFF1565C0),
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${product['price']}€',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Stock: ${product['stock']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Boutons quantité
                          Column(
                            children: [
                              if (inCart > 0)
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          _removeFromCart(product['name']),
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(
                                      '$inCart',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _addToCart(product['name']),
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                ElevatedButton(
                                  onPressed: () => _addToCart(product['name']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1565C0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Ajouter',
                                    style: TextStyle(color: Colors.white),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_cart.length} article${_cart.length > 1 ? 's' : ''}',
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
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _showCartDialog(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Commander',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Mon Panier',
            style: TextStyle(color: Color(0xFF1565C0)),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_cart.isEmpty)
                  const Column(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Votre panier est vide',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                else
                  ..._cart.entries.map((entry) {
                    final product = _productsByCategory.values
                        .expand((list) => list)
                        .firstWhere((p) => p['name'] == entry.key);

                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.shopping_basket_rounded,
                          size: 20,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      title: Text(entry.key),
                      subtitle: Text('${product['price']}€ × ${entry.value}'),
                      trailing: Text(
                        '${((product['price'] as double) * entry.value).toStringAsFixed(2)}€',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                if (_cart.isNotEmpty) Divider(color: Colors.grey.shade300),
                if (_cart.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_getTotalPrice().toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Continuer',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            if (_cart.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showOrderConfirmation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                ),
                child: const Text(
                  'Valider la commande',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showOrderConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Commande confirmée!',
            style: TextStyle(color: Colors.green),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 60, color: Colors.green),
              const SizedBox(height: 16),
              const Text('Votre commande a été enregistrée avec succès.'),
              const SizedBox(height: 8),
              Text('Total: ${_getTotalPrice().toStringAsFixed(2)}€'),
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
