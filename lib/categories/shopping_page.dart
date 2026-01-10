import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:share_plus/share_plus.dart';

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
          image: '',
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

  void _showOrderConfirmation(BuildContext context) {
    if (_cartItems.isEmpty) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.1,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: screenWidth * 0.15,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Commande confirmée !',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  '${_calculateTotalItems()} articles commandés',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_calculateTotal().toStringAsFixed(0)} fcfa',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'Souhaitez-vous partager cette commande sur WhatsApp ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015,
                          ),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _shareOrderOnWhatsApp();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015,
                          ),
                        ),
                        icon: Icon(Icons.phone, size: screenWidth * 0.05),
                        label: Text(
                          'WhatsApp',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
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
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                    child: Text(
                      'Terminer sans partager',
                      style: TextStyle(fontSize: screenWidth * 0.04),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductData product, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
          Container(
            height: screenWidth * 0.3,
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
                size: screenWidth * 0.12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.015),
                      Text(
                        '${product.price.toStringAsFixed(0)} fcfa',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenWidth * 0.02),

                  if (cartItem.name.isNotEmpty)
                    _buildQuantityControls(cartItem, product, context)
                  else
                    SizedBox(
                      width: double.infinity,
                      height: screenWidth * 0.1,
                      child: ElevatedButton(
                        onPressed: () => _addToCart(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: screenWidth * 0.02,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: screenWidth * 0.045),
                            SizedBox(width: screenWidth * 0.015),
                            Text(
                              'Ajouter',
                              style: TextStyle(fontSize: screenWidth * 0.03),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(
    CartItem cartItem,
    ProductData product,
    BuildContext context,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _removeFromCart(cartItem.name),
            icon: Icon(Icons.remove, size: screenWidth * 0.045),
            color: const Color(0xFF1565C0),
            padding: EdgeInsets.all(screenWidth * 0.02),
            constraints: BoxConstraints(
              minWidth: screenWidth * 0.1,
              minHeight: screenWidth * 0.1,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${cartItem.quantity}',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1565C0),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _addToCart(product),
            icon: Icon(Icons.add, size: screenWidth * 0.045),
            color: const Color(0xFF1565C0),
            padding: EdgeInsets.all(screenWidth * 0.02),
            constraints: BoxConstraints(
              minWidth: screenWidth * 0.1,
              minHeight: screenWidth * 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartPanel() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (!_isCartVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _cartItems.isEmpty ? screenHeight * 0.15 : screenHeight * 0.6,
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
            Container(
              margin: EdgeInsets.only(top: screenHeight * 0.01),
              width: screenWidth * 0.1,
              height: screenHeight * 0.005,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Panier (${_calculateTotalItems()})',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_cartItems.isNotEmpty)
                    IconButton(
                      onPressed: _clearCart,
                      icon: Icon(
                        Icons.delete_outline,
                        size: screenWidth * 0.06,
                      ),
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
                        size: screenWidth * 0.15,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Panier vide',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: screenWidth * 0.1,
                            height: screenWidth * 0.1,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.shopping_bag,
                              size: screenWidth * 0.05,
                              color: const Color(0xFF1565C0),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  '${item.price.toStringAsFixed(0)} fcfa',
                                  style: TextStyle(
                                    color: const Color(0xFF1565C0),
                                    fontSize: screenWidth * 0.03,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
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
                                  icon: Icon(
                                    Icons.remove,
                                    size: screenWidth * 0.04,
                                  ),
                                  padding: EdgeInsets.all(screenWidth * 0.01),
                                  constraints: BoxConstraints(
                                    minWidth: screenWidth * 0.1,
                                    minHeight: screenWidth * 0.1,
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.08,
                                  child: Center(
                                    child: Text(
                                      '${item.quantity}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.04,
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
                                  icon: Icon(
                                    Icons.add,
                                    size: screenWidth * 0.04,
                                  ),
                                  padding: EdgeInsets.all(screenWidth * 0.01),
                                  constraints: BoxConstraints(
                                    minWidth: screenWidth * 0.1,
                                    minHeight: screenWidth * 0.1,
                                  ),
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
                padding: EdgeInsets.all(screenWidth * 0.04),
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
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${_calculateTotal().toStringAsFixed(0)} fcfa',
                              style: TextStyle(
                                fontSize: screenWidth * 0.055,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1565C0),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showOrderConfirmation(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: Icon(Icons.phone, size: screenWidth * 0.05),
                          label: Text(
                            'Commander',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showOrderConfirmation(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015,
                          ),
                        ),
                        child: Text(
                          'Voir options de commande',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035,
                          ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        title: Text(
          'Shopping ARA',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: screenWidth * 0.05,
          ),
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
                icon: Icon(Icons.shopping_cart, size: screenWidth * 0.06),
                color: Colors.white,
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: screenWidth * 0.02,
                  top: screenWidth * 0.02,
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.01),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: screenWidth * 0.04,
                      minHeight: screenWidth * 0.04,
                    ),
                    child: Text(
                      '${_calculateTotalItems()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.025,
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
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: screenWidth > 600 ? 3 : 2,
                          crossAxisSpacing: screenWidth * 0.03,
                          mainAxisSpacing: screenWidth * 0.04,
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
                                child: _buildProductCard(
                                  products[index],
                                  context,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

          _buildCartPanel(),
        ],
      ),

      floatingActionButton: _cartItems.isNotEmpty && !_isCartVisible
          ? Container(
              margin: EdgeInsets.only(
                bottom: screenHeight * 0.02,
                right: screenWidth * 0.04,
              ),
              child: FloatingActionButton(
                onPressed: _toggleCartVisibility,
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                child: Icon(Icons.shopping_cart, size: screenWidth * 0.06),
              ),
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF1565C0)),
          ),
          SizedBox(height: screenHeight * 0.03),
          Text(
            'Chargement des produits...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: screenWidth * 0.04,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: screenWidth * 0.2,
            color: Colors.grey[300],
          ),
          SizedBox(height: screenHeight * 0.03),
          Text(
            'Aucun produit disponible',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'Revenez plus tard',
            style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035),
          ),
          SizedBox(height: screenHeight * 0.04),
          ElevatedButton(
            onPressed: _initializeData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.015,
              ),
            ),
            child: Text(
              'Actualiser',
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
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
