import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class ShoppingPage extends StatefulWidget {
  final List<String> subcategories;

  const ShoppingPage({super.key, required this.subcategories});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final Map<String, List<Map<String, dynamic>>> _productsByCategory = {
    'Draps': [
      {
        'name': 'Drap housse 90x200',
        'price': 25.99,
        'stock': 50,
        'image': 'assets/draps1.jpg',
        'description':
            'Drap housse en coton percale de haute qualité. Lavable à 60°C.',
        'colors': ['Blanc', 'Bleu', 'Gris'],
        'rating': 4.5,
      },
      {
        'name': 'Drap housse 140x200',
        'price': 35.99,
        'stock': 30,
        'image': 'assets/draps2.jpg',
        'description': 'Drap housse 140x200 en coton égyptien.',
        'colors': ['Blanc', 'Crème', 'Bleu clair'],
        'rating': 4.2,
      },
      {
        'name': 'Drap plat 240x250',
        'price': 45.99,
        'stock': 20,
        'image': 'assets/draps3.jpg',
        'description': 'Drap plat grand format pour lit king size.',
        'colors': ['Blanc', 'Ivoire'],
        'rating': 4.8,
      },
    ],
    'Couettes': [
      {
        'name': 'Couette été 135x200',
        'price': 79.99,
        'stock': 15,
        'image': 'assets/couette1.jpg',
        'description': 'Couette légère pour l\'été, garnissage synthétique.',
        'colors': ['Blanc', 'Gris'],
        'rating': 4.3,
      },
      {
        'name': 'Couette hiver 200x200',
        'price': 129.99,
        'stock': 10,
        'image': 'assets/couette2.jpg',
        'description': 'Couette chaude pour l\'hiver avec duvet naturel.',
        'colors': ['Blanc', 'Bleu foncé'],
        'rating': 4.7,
      },
      {
        'name': 'Couette 4 saisons',
        'price': 159.99,
        'stock': 8,
        'image': 'assets/couette3.jpg',
        'description': 'Couette modulable avec 2 garnitures séparables.',
        'colors': ['Blanc', 'Gris perle'],
        'rating': 4.9,
      },
    ],
    'Nappes de prière': [
      {
        'name': 'Nappe simple',
        'price': 19.99,
        'stock': 100,
        'image': 'assets/nappe1.jpg',
        'description': 'Nappe de prière simple et pratique.',
        'colors': ['Vert', 'Bleu', 'Marron'],
        'rating': 4.1,
      },
      {
        'name': 'Nappe décorée',
        'price': 34.99,
        'stock': 60,
        'image': 'assets/nappe2.jpg',
        'description': 'Nappe avec motifs orientaux brodés.',
        'colors': ['Rouge', 'Or', 'Vert émeraude'],
        'rating': 4.6,
      },
      {
        'name': 'Nappe premium',
        'price': 49.99,
        'stock': 30,
        'image': 'assets/nappe3.jpg',
        'description': 'Nappe premium en soie avec broderies dorées.',
        'colors': ['Or', 'Bordeaux', 'Noir'],
        'rating': 4.8,
      },
    ],
  };

  final Map<String, int> _cart = {};
  int _selectedCategoryIndex = 0;
  final PageController _categoryController = PageController();
  final TextEditingController _searchController = TextEditingController();
  bool _searchMode = false;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _categoryController.addListener(() {
      final page = _categoryController.page?.round() ?? 0;
      if (page != _selectedCategoryIndex) {
        setState(() {
          _selectedCategoryIndex = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(String productName) {
    setState(() {
      _cart[productName] = (_cart[productName] ?? 0) + 1;
    });
    _showSnackBar('$productName ajouté au panier', Colors.green);
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  double _getTotalPrice() {
    double total = 0;
    for (var entry in _cart.entries) {
      final product = _getProductByName(entry.key);
      total += (product['price'] as double) * entry.value;
    }
    return total;
  }

  Map<String, dynamic> _getProductByName(String name) {
    return _productsByCategory.values
        .expand((list) => list)
        .firstWhere((p) => p['name'] == name);
  }

  String _getOrderSummary() {
    String summary = '📦 COMMANDE 📦\n\n';
    for (var entry in _cart.entries) {
      final product = _getProductByName(entry.key);
      summary +=
          '▫️ ${entry.key}\n   ×${entry.value} = ${(product['price'] as double) * entry.value}€\n\n';
    }
    summary +=
        '━━━━━━━━━━━━━━\n💰 TOTAL: ${_getTotalPrice().toStringAsFixed(2)}€\n\n📱 Merci pour votre commande !';
    return summary;
  }

  Future<void> _sendWhatsAppOrder() async {
    if (_cart.isEmpty) {
      _showSnackBar('Votre panier est vide', Colors.orange);
      return;
    }

    final phoneNumber = '880189489397';
    final message = Uri.encodeComponent(_getOrderSummary());
    final url = 'https://wa.me/$phoneNumber?text=$message';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showSnackBar('Impossible d\'ouvrir WhatsApp', Colors.red);
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchMode = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _searchMode = true;
      _searchResults = _productsByCategory.values
          .expand((list) => list)
          .where(
            (product) =>
                product['name'].toLowerCase().contains(query.toLowerCase()) ||
                (product['description'] as String).toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(25),
        child: TextField(
          controller: _searchController,
          onChanged: _performSearch,
          decoration: InputDecoration(
            hintText: 'Rechercher un produit...',
            hintStyle: TextStyle(color: Colors.grey.shade600),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIndicator() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: PageView.builder(
        controller: _categoryController,
        itemCount: widget.subcategories.length,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index) {
          setState(() {
            _selectedCategoryIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final category = widget.subcategories[index];
          final isSelected = _selectedCategoryIndex == index;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                _categoryController.animateToPage(
                  index,
                  duration: 300.ms,
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: 300.ms,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade100, Colors.grey.shade200],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1565C0).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList() {
    final currentCategory = widget.subcategories[_selectedCategoryIndex];
    final products = _productsByCategory[currentCategory] ?? [];

    if (_searchMode) {
      return _buildSearchResults();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductItem(product, index);
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aucun produit trouvé',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return _buildProductItem(product, index);
      },
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product, int index) {
    final inCart = _cart[product['name']] ?? 0;
    final rating = product['rating'] as double;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child:
            Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image du produit
                      Container(
                        width: 120,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          image:
                              (product['image'] as String?)?.contains('http') ??
                                  false
                              ? DecorationImage(
                                  image: NetworkImage(product['image']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            (product['image'] as String?)?.contains('http') ??
                                false
                            ? null
                            : Center(
                                child: Icon(
                                  _getProductIcon(product['name']),
                                  size: 40,
                                  color: const Color(0xFF1565C0),
                                ),
                              ),
                      ),

                      // Détails du produit
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      product['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (product['stock'] <= 5)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Bientôt épuisé',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.orange.shade800,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Note
                              Row(
                                children: [
                                  ...List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < rating.floor()
                                          ? Icons.star
                                          : starIndex < rating
                                          ? Icons.star_half
                                          : Icons.star_border,
                                      size: 14,
                                      color: Colors.amber,
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Prix
                              Text(
                                '${product['price']}€',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Stock
                              Text(
                                'Stock: ${product['stock']} unités',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (product['stock'] as int) > 10
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Contrôle quantité
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _addToCart(product['name']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF1565C0,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Ajouter',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (inCart > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF1565C0,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed: () => _removeFromCart(
                                              product['name'],
                                            ),
                                            icon: Icon(
                                              Icons.remove,
                                              size: 16,
                                              color: Colors.red.shade600,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              '$inCart',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1565C0),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _addToCart(product['name']),
                                            icon: Icon(
                                              Icons.add,
                                              size: 16,
                                              color: Colors.green.shade600,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: (index * 100).ms)
                .slideX(begin: 0.1, duration: 300.ms, curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Panier',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_cart.length} article${_cart.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${_getTotalPrice().toStringAsFixed(2)}€',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _cart.isEmpty ? null : () => _showCartDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _cart.isEmpty
                  ? Colors.grey.shade300
                  : const Color(0xFF1565C0),
              foregroundColor: _cart.isEmpty
                  ? Colors.grey.shade600
                  : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
            ),
            icon: Icon(
              Icons.shopping_cart_checkout_rounded,
              color: _cart.isEmpty ? Colors.grey.shade600 : Colors.white,
            ),
            label: Text(
              'Voir le panier',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _cart.isEmpty ? Colors.grey.shade600 : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCartDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildCartSheet();
      },
    );
  }

  Widget _buildCartSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Titre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_cart_rounded,
                  color: Color(0xFF1565C0),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Votre panier',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${_cart.length} article${_cart.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_cart.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _cart.clear();
                      });
                      Navigator.pop(context);
                      _showSnackBar('Panier vidé', Colors.blue);
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade600,
                      size: 18,
                    ),
                    label: Text(
                      'Vider',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Liste des articles
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Votre panier est vide',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Ajoutez des produits pour continuer',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      ..._cart.entries.map((entry) {
                        final product = _getProductByName(entry.key);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE3F2FD),
                                      Color(0xFFBBDEFB),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getProductIcon(product['name']),
                                  color: const Color(0xFF1565C0),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product['price']}€ l\'unité',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${((product['price'] as double) * entry.value).toStringAsFixed(2)}€',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1565C0),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              _removeFromCart(entry.key),
                                          icon: Icon(
                                            Icons.remove,
                                            size: 18,
                                            color: Colors.red.shade600,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Text(
                                            '${entry.value}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _addToCart(entry.key),
                                          icon: Icon(
                                            Icons.add,
                                            size: 18,
                                            color: Colors.green.shade600,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      // Récapitulatif
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1565C0).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              'Sous-total',
                              '${_getTotalPrice().toStringAsFixed(2)}€',
                            ),
                            _buildSummaryRow(
                              'Livraison',
                              _getTotalPrice() > 100 ? 'Gratuite' : '5.99€',
                              isHighlighted: _getTotalPrice() > 100,
                            ),
                            const Divider(
                              color: Colors.white30,
                              height: 24,
                              thickness: 1,
                            ),
                            _buildSummaryRow(
                              'TOTAL',
                              '${(_getTotalPrice() + (_getTotalPrice() > 100 ? 0 : 5.99)).toStringAsFixed(2)}€',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
          ),

          // Bouton de commande
          if (_cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _sendWhatsAppOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.phone, size: 24),
                  label: const Text(
                    'Commander via WhatsApp',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isHighlighted = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              color: isHighlighted ? Colors.yellow.shade300 : Colors.white,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 22 : 16,
              color: isHighlighted ? Colors.yellow.shade300 : Colors.white,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFF),
      body: Column(
        children: [
          // Header avec dégradé bleu
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF2196F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Barre de navigation supérieure
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Badge(
                      label: Text('${_cart.length}'),
                      backgroundColor: Colors.red,
                      child: IconButton(
                        onPressed: () => _showCartDialog(),
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Titre
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shopping ARA service',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Barre de recherche
          _buildSearchBar(),

          // Catégories
          _buildCategoryIndicator(),

          // Liste des produits
          Expanded(child: _buildProductList()),

          // Navigation inférieure
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  // Méthodes utilitaires
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Draps':
        return Icons.bed_rounded;
      case 'Couettes':
        return Icons.thermostat_auto_rounded;
      case 'Nappes de prière':
        return Icons.flag_rounded;
      case 'Tapis':
        return Icons.carpenter_rounded;
      case 'Sacs':
        return Icons.work_rounded;
      case 'Chaussures':
        return Icons.shopping_bag_rounded;
      case 'Parfums':
        return Icons.spa_rounded;
      default:
        return Icons.shopping_basket_rounded;
    }
  }

  IconData _getProductIcon(String productName) {
    if (productName.toLowerCase().contains('drap')) return Icons.bed_rounded;
    if (productName.toLowerCase().contains('couette'))
      return Icons.thermostat_auto_rounded;
    if (productName.toLowerCase().contains('nappe')) return Icons.flag_rounded;
    if (productName.toLowerCase().contains('tapis'))
      return Icons.carpenter_rounded;
    return Icons.shopping_basket_rounded;
  }
}
