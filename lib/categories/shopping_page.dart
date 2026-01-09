import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:share_plus/share_plus.dart'; // Ajout du package share_plus

class ShoppingSimplePage extends StatefulWidget {
  const ShoppingSimplePage({super.key});

  @override
  State<ShoppingSimplePage> createState() => _ShoppingSimplePageState();
}

class CartItem {
  final String name;
  final double price;
  int quantity;

  CartItem({required this.name, required this.price, this.quantity = 1});

  double get total => price * quantity;
}

class _ShoppingSimplePageState extends State<ShoppingSimplePage> {
  final List<CartItem> _cartItems = [];
  final Map<String, ProductData> _productsCache = {};
  bool _isLoading = true;
  bool _isCartVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('shopping_products')
          .get();

      for (var doc in snapshot.docs) {
        _productsCache[doc['name']] = ProductData(
          name: doc['name'],
          price: (doc['price'] as num).toDouble(),
          image: '', // Vous pouvez ajouter une URL d'image ici
        );
      }
    } catch (e) {
      print('Erreur de chargement: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addToCart(ProductData product) {
    setState(() {
      final existingItem = _cartItems.firstWhere(
        (item) => item.name == product.name,
        orElse: () => CartItem(name: '', price: 0),
      );

      if (existingItem.name.isNotEmpty) {
        existingItem.quantity++;
      } else {
        _cartItems.add(
          CartItem(name: product.name, price: product.price, quantity: 1),
        );
      }
    });

    _showSnackbar('${product.name} ajouté au panier');
  }

  void _removeFromCart(String productName) {
    setState(() {
      final itemIndex = _cartItems.indexWhere(
        (item) => item.name == productName,
      );
      if (itemIndex != -1) {
        if (_cartItems[itemIndex].quantity > 1) {
          _cartItems[itemIndex].quantity--;
        } else {
          _cartItems.removeAt(itemIndex);
        }
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
    _showSnackbar('Panier vidé');
  }

  double _calculateTotal() {
    return _cartItems.fold(0, (total, item) => total + item.total);
  }

  int _calculateTotalItems() {
    return _cartItems.fold(0, (total, item) => total + item.quantity);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleCartVisibility() {
    setState(() {
      _isCartVisible = !_isCartVisible;
    });
  }

  // Nouvelle fonction pour partager la commande sur WhatsApp
  Future<void> _shareOrderOnWhatsApp() async {
    if (_cartItems.isEmpty) return;

    final StringBuffer orderMessage = StringBuffer();
    orderMessage.write('📋 *COMMANDE ARA SHOPPING*\n\n');
    orderMessage.write('--------------------------------\n\n');

    for (var item in _cartItems) {
      orderMessage.write('• *${item.name}*\n');
      orderMessage.write('  Quantité: ${item.quantity}\n');
      orderMessage.write(
        '  Prix unitaire: ${item.price.toStringAsFixed(0)} fcfa\n',
      );
      orderMessage.write(
        '  Sous-total: ${item.total.toStringAsFixed(0)} fcfa\n\n',
      );
    }

    orderMessage.write('--------------------------------\n');
    orderMessage.write(
      '*TOTAL GÉNÉRAL: ${_calculateTotal().toStringAsFixed(0)} fcfa*\n\n',
    );
    orderMessage.write('🛒 Nombre d\'articles: ${_calculateTotalItems()}\n\n');
    orderMessage.write('Merci pour votre commande ! 😊');

    try {
      await Share.share(
        orderMessage.toString(),
        subject: 'Commande ARA Shopping',
        sharePositionOrigin: Rect.fromCenter(
          center: MediaQuery.of(context).size.center(Offset.zero),
          width: 100,
          height: 100,
        ),
      );
    } catch (e) {
      print('Erreur lors du partage: $e');
      _showSnackbar('Erreur lors du partage');
    }
  }

  void _showOrderConfirmation() {
    if (_cartItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Commande confirmée !',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '${_calculateTotalItems()} articles commandés',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${_calculateTotal().toStringAsFixed(0)} fcfa',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Souhaitez-vous partager cette commande sur WhatsApp ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _shareOrderOnWhatsApp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.phone, size: 20),
                  label: const Text('WhatsApp'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                _clearCart();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1565C0),
                side: const BorderSide(color: Color(0xFF1565C0)),
              ),
              child: const Text('Terminer sans partager'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductData product) {
    final cartItem = _cartItems.firstWhere(
      (item) => item.name == product.name,
      orElse: () => CartItem(name: '', price: 0),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1565C0).withOpacity(0.9),
                  const Color(0xFF1565C0).withOpacity(0.4),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.shopping_bag,
                size: 50,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${product.price.toStringAsFixed(0)} fcfa',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 12),

                if (cartItem.name.isNotEmpty)
                  _buildQuantityControls(cartItem, product)
                else
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 18),
                          SizedBox(width: 6),
                          Text('Ajouter'),
                        ],
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

  Widget _buildQuantityControls(CartItem cartItem, ProductData product) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _removeFromCart(cartItem.name),
            icon: const Icon(Icons.remove, size: 18),
            color: const Color(0xFF1565C0),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${cartItem.quantity}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _addToCart(product),
            icon: const Icon(Icons.add, size: 18),
            color: const Color(0xFF1565C0),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCartPanel() {
    if (!_isCartVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _cartItems.isEmpty
            ? 100
            : 280, // Ajusté pour le bouton WhatsApp
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Panier (${_calculateTotalItems()})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_cartItems.isNotEmpty)
                    IconButton(
                      onPressed: _clearCart,
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                    ),
                ],
              ),
            ),

            if (_cartItems.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 40,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Panier vide',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.shopping_bag,
                              size: 20,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.price.toStringAsFixed(0)} fcfa',
                                  style: const TextStyle(
                                    color: Color(0xFF1565C0),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => _removeFromCart(item.name),
                                  icon: const Icon(Icons.remove, size: 16),
                                  padding: const EdgeInsets.all(4),
                                ),
                                SizedBox(
                                  width: 30,
                                  child: Center(
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    final product = _productsCache[item.name];
                                    if (product != null) {
                                      _addToCart(product);
                                    }
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  padding: const EdgeInsets.all(4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            if (_cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${_calculateTotal().toStringAsFixed(0)} fcfa',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _showOrderConfirmation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: const Icon(Icons.phone, size: 20),
                          label: const Text(
                            'Commander',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showOrderConfirmation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Voir options de commande',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        title: const Text(
          'Shopping ARA',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _toggleCartVisibility,
                icon: const Icon(Icons.shopping_cart),
                color: Colors.white,
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_calculateTotalItems()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? _buildLoadingState()
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('shopping_products')
                      .orderBy('name')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return _buildLoadingState();
                    }

                    final products = snapshot.data!.docs.map((doc) {
                      return ProductData(
                        name: doc['name'],
                        price: (doc['price'] as num).toDouble(),
                        image: '',
                      );
                    }).toList();

                    if (products.isEmpty) {
                      return _buildEmptyState();
                    }

                    return AnimationLimiter(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.75,
                            ),
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredGrid(
                            position: index,
                            duration: const Duration(milliseconds: 400),
                            columnCount: 2,
                            child: ScaleAnimation(
                              scale: 0.5,
                              child: FadeInAnimation(
                                child: _buildProductCard(products[index]),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

          // Cart Panel
          _buildCartPanel(),
        ],
      ),

      // Bottom button to show cart
      floatingActionButton: _cartItems.isNotEmpty && !_isCartVisible
          ? FloatingActionButton(
              onPressed: _toggleCartVisibility,
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              child: const Icon(Icons.shopping_cart),
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF1565C0)),
          ),
          const SizedBox(height: 20),
          Text(
            'Chargement des produits...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text(
            'Aucun produit disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text('Revenez plus tard', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _initializeData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Actualiser'),
          ),
        ],
      ),
    );
  }
}

class ProductData {
  final String name;
  final double price;
  final String image;

  ProductData({required this.name, required this.price, required this.image});
}
