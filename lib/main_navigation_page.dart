import 'package:araservice/auth/auth_gate.dart';
import 'package:araservice/categories/mode_confession.dart';
import 'package:araservice/categories/pressing_page.dart'
    hide ModeConfectionPage;
import 'package:araservice/categories/produits_menagers_page.dart';
import 'package:araservice/categories/shopping_page.dart';
import 'package:araservice/components/dashboard_carousel.dart';
import 'package:araservice/components/dashboard_welcome_container.dart';
import 'package:araservice/services/firebase_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:araservice/auth/register_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Modèle de produit
class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String imageUrl;
  final bool isPopular;
  final bool isNew;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isPopular = false,
    this.isNew = false,
  });
}

// Modèle de catégorie
class Category {
  final String id;
  final String name;
  final IconData icon;
  final List<String> subcategories;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.subcategories,
  });
}

// Modèle d'article du panier
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

// Données fictives pour l'application
final List<Product> allProducts = [
  Product(
    id: '1',
    name: 'Draps en coton premium',
    category: 'Shopping',
    description: 'Draps en coton égyptien de haute qualité',
    price: 89.99,
    imageUrl: 'assets/draps.jpg',
    isPopular: true,
  ),
  Product(
    id: '2',
    name: 'Nappe de prière brodée',
    category: 'Shopping',
    description: 'Nappe de prière traditionnelle avec broderie',
    price: 29.99,
    imageUrl: 'assets/nappe.jpg',
    isPopular: true,
  ),
  Product(
    id: '3',
    name: 'Détergent liquide 5L',
    category: 'Produits ménagers',
    description: 'Détergent concentré pour lavage efficace',
    price: 19.99,
    imageUrl: 'assets/detergent.jpg',
    isNew: true,
  ),
  Product(
    id: '4',
    name: 'Eau de javel',
    category: 'Produits ménagers',
    description: 'Eau de javel désinfectante 2L',
    price: 8.99,
    imageUrl: 'assets/javel.jpg',
  ),
  Product(
    id: '5',
    name: 'Service de pressing complet',
    category: 'Pressing',
    description: 'Nettoyage et repassage de 5 vêtements',
    price: 49.99,
    imageUrl: 'assets/pressing.jpg',
    isPopular: true,
  ),
  Product(
    id: '6',
    name: 'Confection sur mesure',
    category: 'Mode',
    description: 'Création de vêtement selon vos mesures',
    price: 149.99,
    imageUrl: 'assets/confection.jpg',
    isNew: true,
  ),
  Product(
    id: '7',
    name: 'Couette été',
    category: 'Shopping',
    description: 'Couette légère pour l\'été',
    price: 79.99,
    imageUrl: 'assets/couette.jpg',
  ),
  Product(
    id: '8',
    name: 'Sac à main',
    category: 'Shopping',
    description: 'Sac à main élégant en cuir synthétique',
    price: 39.99,
    imageUrl: 'assets/sac.jpg',
  ),
];

final List<Category> categories = [
  Category(
    id: '1',
    name: 'Shopping',
    icon: Icons.shopping_basket,
    subcategories: [
      'Draps',
      'Couettes',
      'Nappes de prière',
      'Tapis',
      'Sacs',
      'Chaussures',
      'Parfums',
    ],
  ),
  Category(
    id: '2',
    name: 'Produits ménagers',
    icon: Icons.clean_hands,
    subcategories: ['Détergent liquide', 'Eau de javel', 'Produits nettoyants'],
  ),
  Category(
    id: '3',
    name: 'Pressing',
    icon: Icons.local_laundry_service,
    subcategories: ['Nettoyage à sec', 'Repassage', 'Retouches'],
  ),
  Category(
    id: '4',
    name: 'Mode & Confection',
    icon: Icons.content_cut,
    subcategories: ['Confection', 'Retouches', 'Prêt-à-porter'],
  ),
  Category(
    id: '5',
    name: 'Autres services',
    icon: Icons.more_horiz,
    subcategories: ['Livraison', 'Conseils', 'Packaging'],
  ),
];

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<CartItem> cartItems = [
    CartItem(product: allProducts[0], quantity: 2),
    CartItem(product: allProducts[2], quantity: 1),
  ];

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      HomeScreen(cartItems: cartItems),
      const SearchScreen(),
      const AccountScreen(),
      const CategoriesScreen(),
    ]);
  }

  void _updateCart(CartItem item) {
    setState(() {
      final index = cartItems.indexWhere(
        (element) => element.product.id == item.product.id,
      );
      if (index != -1) {
        cartItems[index].quantity = item.quantity;
      } else {
        cartItems.add(item);
      }
    });
  }

  void _removeFromCart(String productId) {
    setState(() {
      cartItems.removeWhere((item) => item.product.id == productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F5F4),
      //extendBody: true, // permet l'effet flottant
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: const Color(0xFF00695C),
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Accueil',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.grid_view_rounded),
              //   label: 'Catégories',
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                label: 'Recherche',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.shopping_cart_rounded),
              //   label: 'Panier',
              // ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Compte',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ÉCRAN 1 : ACCUEIL
class HomeScreen extends StatelessWidget {
  final List<CartItem> cartItems;

  const HomeScreen({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'ARA Service',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00695C), // Vert foncé
                Color(0xFF2196F3), // Bleu vif
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FDFF), // Bleu très clair
              Color(0xFFF0F9F8), // Vert très clair
              Color(0xFFE8F5F4), // Vert clair moyen
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bannière de bienvenue
              //DashboardWelcomeContainer(),
              DashboardCarousel(),
              const SizedBox(height: 28),
              // Catégories principales
              const Text(
                'Catégories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00695C),
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.6,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildCategoryCard(
                    context,
                    'Shopping',
                    Icons.shopping_basket_rounded,
                    const [Color(0xFF1565C0), Color(0xFF2196F3)],
                    0, // Passer l'index 0 pour Shopping
                  ),

                  _buildCategoryCard(
                    context,
                    'Produits ménagers',
                    Icons.clean_hands_rounded,
                    const [Color(0xFF00838F), Color(0xFF00BCD4)],
                    1, // Passer l'index
                  ),

                  _buildCategoryCard(
                    context,
                    'Pressing',
                    Icons.local_laundry_service_rounded,
                    const [Color(0xFF00796B), Color(0xFF4DB6AC)],
                    2,
                  ),

                  _buildCategoryCard(
                    context,
                    'Mode & Confection',
                    Icons.content_cut_rounded,
                    const [Color(0xFF004D40), Color(0xFF00695C)],
                    3,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Produits populaires
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Produits populaires',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF00695C),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4DB6AC).withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Voir tout',
                      style: TextStyle(
                        color: Color(0xFF00695C),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: allProducts.where((p) => p.isPopular).length,
                  itemBuilder: (context, index) {
                    final popularProducts = allProducts
                        .where((p) => p.isPopular)
                        .toList();
                    final product = popularProducts[index];
                    return _buildProductCard(context, product);
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Nouveautés
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nouveautés',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF00695C),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2196F3), Color(0xFF4DB6AC)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2196F3).withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Voir tout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: allProducts.where((p) => p.isNew).length,
                  itemBuilder: (context, index) {
                    final newProducts = allProducts
                        .where((p) => p.isNew)
                        .toList();
                    final product = newProducts[index];
                    return _buildProductCard(context, product);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradientColors,
    int index, // Ajouter l'index comme paramètre
  ) {
    return SizedBox(
      height: 110,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              final category =
                  categories[index]; // index est maintenant disponible

              Widget page;
              switch (category.name) {
                case 'Shopping':
                  page = ShoppingSimplePage();
                  break;
                case 'Produits ménagers':
                  page = ProduitsMenagersPage(
                    subcategories: category.subcategories,
                  );
                  break;
                case 'Mode & Confection':
                  page = ModeConfectionPage(
                    subcategories: category.subcategories,
                  );
                  break;
                case 'Pressing':
                  page = PressingPage(categoryName: category.name);
                  break;
                default:
                  page = ShoppingSimplePage();
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 36, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      width: 170, // Augmenté de 160 à 170
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image container avec hauteur fixe
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 60,
                      color: const Color(0xFF00695C).withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Nom du produit avec hauteur fixe
                SizedBox(
                  height: 40, // Hauteur fixe pour 2 lignes
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Spacer(), // Pousse le prix en bas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF00695C),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ), // Padding augmenté
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DB6AC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ÉCRAN 2 : CATÉGORIES
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catégories',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF00695C),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F2F1), // Vert très clair
              Color(0xFFF5F5F5), // Gris très léger pour le contraste
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Material(
                  color: Colors.white,
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF00695C),
                            const Color(0xFF4DB6AC),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(category.icon, color: Colors.white, size: 22),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00695C),
                      ),
                    ),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.expand_more,
                        color: Color(0xFF00695C),
                        size: 18,
                      ),
                    ),
                    children: category.subcategories.map((subcategory) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              const Color(0xFFF8FDFC),
                              const Color(0xFFE8F5F4),
                            ],
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 10,
                          ),
                          leading: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4DB6AC),
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(
                            subcategory,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF37474F),
                            ),
                          ),
                          trailing: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF4DB6AC).withOpacity(0.1),
                                  const Color(0xFF4DB6AC).withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF4DB6AC),
                              size: 16,
                            ),
                          ),
                          onTap: () {
                            // Naviguer vers les produits de la sous-catégorie
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ÉCRAN 3 : RECHERCHE
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  List<Product> _filteredProducts = allProducts;
  String _selectedCategory = 'Toutes';
  double _priceRange = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterProducts();
                });
              },
            ),
          ),

          // Filtres
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Dropdown avec largeur fixe
                SizedBox(
                  width: double.infinity, // Prend toute la largeur
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    isExpanded: true, // Important pour éviter l'overflow
                    items: ['Toutes', ...categories.map((cat) => cat.name)].map(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            overflow:
                                TextOverflow.ellipsis, // Gère les textes longs
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                        _filterProducts();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prix max: ${_priceRange.toStringAsFixed(0)} €'),
                    Slider(
                      value: _priceRange,
                      min: 0,
                      max: 500,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _priceRange = value;
                          _filterProducts();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    0.8, // Changé de 0.75 à 0.8 pour plus d'espace
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return _buildSearchProductCard(context, product);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = allProducts.where((product) {
        final matchesSearch =
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
        final matchesCategory =
            _selectedCategory == 'Toutes' ||
            product.category == _selectedCategory;
        final matchesPrice = product.price <= _priceRange;
        return matchesSearch && matchesCategory && matchesPrice;
      }).toList();
    });
  }

  Widget _buildSearchProductCard(BuildContext context, Product product) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container
              Container(
                height: 110, // Réduit de 120 à 110
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 60,
                    color: const Color(0xFF00695C).withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Nom du produit avec hauteur fixe
              SizedBox(
                height: 40, // Hauteur fixe pour 2 lignes
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.category,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Spacer(), // Pousse le prix en bas
              Text(
                '${product.price.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Color(0xFF00695C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ÉCRAN 4 : PANIER

// ÉCRAN 5 : COMPTE
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<User?> _authStateChanges;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _authStateChanges = _auth.authStateChanges();
  }

  Future<void> showLogoutDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// ICÔNE
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFF44336),
                    size: 32,
                  ),
                ),

                const SizedBox(height: 20),

                /// TITRE
                const Text(
                  'Déconnexion',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                /// TEXTE
                Text(
                  'Êtes-vous sûr de vouloir vous déconnecter ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 28),

                /// BOUTONS
                Row(
                  children: [
                    /// ANNULER
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// CONFIRMER
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await GoogleSignIn().signOut();
                          await FirebaseAuth.instance.signOut();

                          if (!context.mounted) return;

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const AuthPage()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF44336),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Se déconnecter',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Mon Compte',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A3C34),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A3C34)),
      ),
      body: StreamBuilder<User?>(
        stream: _authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF2E8B57)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chargement...',
                    style: TextStyle(
                      color: Color(0xFF1A3C34),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          _currentUser = snapshot.data;

          if (_currentUser != null) {
            return _buildAccount(_currentUser!);
          } else {
            return _buildAuth();
          }
        },
      ),
    );
  }

  // -----------------------
  // AUTH (Connexion / Inscription) - Avec ListView
  // -----------------------
  Widget _buildAuth() {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8F5F2), Color(0xFFD1E9E4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2E8B57).withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_outlined,
              size: 60,
              color: Color(0xFF2E8B57),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'Bienvenue',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A3C34),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Connectez-vous à votre compte',
            style: TextStyle(fontSize: 16, color: Color(0xFF5A716B)),
          ),
        ),
        const SizedBox(height: 40),

        // Email
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Color(0xFF1A3C34), fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: const TextStyle(
                color: Color(0xFF5A716B),
                fontSize: 14,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF2E8B57),
                  size: 22,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Mot de passe
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Color(0xFF1A3C34), fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              labelStyle: const TextStyle(
                color: Color(0xFF5A716B),
                fontSize: 14,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.lock_outlined,
                  color: Color(0xFF2E8B57),
                  size: 22,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Se connecter
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E8B57), Color(0xFF1A5D3E)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ElevatedButton(
            onPressed: () async {
              try {
                await _auth.signInWithEmailAndPassword(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );
              } catch (e) {
                _showErrorDialog(context, 'Erreur de connexion', e.toString());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login_rounded, size: 20),
                SizedBox(width: 10),
                Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Séparateur
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ou',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
          ],
        ),

        const SizedBox(height: 20),

        // Créer un compte
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2E8B57), width: 1.5),
          ),
          child: TextButton(
            onPressed: () async {
              try {
                await _auth.createUserWithEmailAndPassword(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );
              } catch (e) {
                _showErrorDialog(
                  context,
                  'Erreur d\'inscription',
                  e.toString(),
                );
              }
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Color(0xFF2E8B57),
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'Créer un compte',
                  style: TextStyle(
                    color: Color(0xFF2E8B57),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Options supplémentaires
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FDFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8F5F2), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    color: Color(0xFF2E8B57),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Besoin d\'aide ?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A3C34),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Mot de passe oublié
                  _showPasswordResetDialog(context, _emailController);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_reset_rounded,
                      color: Color(0xFF2E8B57),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        color: Color(0xFF2E8B57),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // Contact support
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF2E8B57),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Contacter le support',
                      style: TextStyle(
                        color: Color(0xFF2E8B57),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -----------------------
  // COMPTE CONNECTÉ - Avec ListView
  // -----------------------
  Widget _buildAccount(User user) {
    return Column(
      children: [
        // En-tête du profil
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8F5F2), Color(0xFFD1E9E4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF2E8B57).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2E8B57),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: user.photoURL != null
                    ? ClipOval(
                        child: Image.network(
                          user.photoURL!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'Utilisateur',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A3C34),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? '',
                      style: const TextStyle(
                        color: Color(0xFF5A716B),
                        fontSize: 14,
                      ),
                    ),
                    if (user.emailVerified)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E8B57).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 12,
                                  color: Color(0xFF2E8B57),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Vérifié',
                                  style: TextStyle(
                                    color: Color(0xFF2E8B57),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Liste des sections avec ListView
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Section: Informations personnelles
              _buildSectionHeader(
                icon: Icons.info_outline_rounded,
                title: 'Informations personnelles',
              ),
              const SizedBox(height: 12),

              _buildInfoTile(
                icon: Icons.email_rounded,
                title: 'Adresse email',
                value: user.email ?? 'Non défini',
                isVerified: user.emailVerified,
              ),

              // if (user.phoneNumber != null)
              //   _buildInfoTile(
              //     icon: Icons.phone_android_rounded,
              //     title: 'Téléphone',
              //     value: user.phoneNumber!,
              //   ),

              // _buildInfoTile(
              //   icon: Icons.fingerprint_rounded,
              //   title: 'Identifiant',
              //   value: 'UID: ${user.uid.substring(0, 12)}...',
              // ),
              _buildInfoTile(
                icon: Icons.calendar_month_rounded,
                title: 'Compte créé',
                value: user.metadata.creationTime != null
                    ? 'Le ${user.metadata.creationTime!.day}/${user.metadata.creationTime!.month}/${user.metadata.creationTime!.year}'
                    : 'Date inconnue',
              ),

              //const SizedBox(height: 24),

              // // Section: Préférences
              // _buildSectionHeader(
              //   icon: Icons.settings_outlined,
              //   title: 'Préférences',
              // ),
              // const SizedBox(height: 12),

              // _buildMenuItem(
              //   icon: Icons.history_rounded,
              //   title: 'Historique des commandes',
              //   onTap: () {},
              // ),

              // _buildMenuItem(
              //   icon: Icons.notifications_active_rounded,
              //   title: 'Notifications',
              //   onTap: () {},
              // ),

              // _buildMenuItem(
              //   icon: Icons.security_rounded,
              //   title: 'Sécurité',
              //   onTap: () {},
              // ),

              // _buildMenuItem(
              //   icon: Icons.privacy_tip_rounded,
              //   title: 'Confidentialité',
              //   onTap: () {},
              // ),

              // _buildMenuItem(
              //   icon: Icons.language_rounded,
              //   title: 'Langue',
              //   subtitle: 'Français',
              //   onTap: () {},
              // ),

              // _buildMenuItem(
              //   icon: Icons.help_outline_rounded,
              //   title: 'Centre d\'aide',
              //   onTap: () {},
              // ),
              const SizedBox(height: 24),

              // Section: Actions
              _buildSectionHeader(icon: Icons.tune_rounded, title: 'Actions'),
              const SizedBox(height: 12),

              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(14),
              //     border: Border.all(
              //       color: const Color(0xFFE0E0E0),
              //       width: 1.5,
              //     ),
              //   ),
              //   child: Column(
              //     children: [
              //       ListTile(
              //         leading: Container(
              //           width: 40,
              //           height: 40,
              //           decoration: BoxDecoration(
              //             color: const Color(0xFF4CAF50).withOpacity(0.1),
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: const Icon(
              //             Icons.upgrade_rounded,
              //             color: Color(0xFF4CAF50),
              //             size: 20,
              //           ),
              //         ),
              //         title: const Text(
              //           'Mettre à niveau le compte',
              //           style: TextStyle(
              //             color: Color(0xFF1A3C34),
              //             fontSize: 15,
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //         trailing: Container(
              //           padding: const EdgeInsets.symmetric(
              //             horizontal: 12,
              //             vertical: 6,
              //           ),
              //           decoration: BoxDecoration(
              //             color: const Color(0xFF4CAF50).withOpacity(0.1),
              //             borderRadius: BorderRadius.circular(20),
              //           ),
              //           child: const Text(
              //             'PRO',
              //             style: TextStyle(
              //               color: Color(0xFF4CAF50),
              //               fontSize: 12,
              //               fontWeight: FontWeight.w700,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 12),

              // Bouton Déconnexion
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFF44336).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    showLogoutDialog(context);
                  },

                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFF44336),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Se déconnecter',
                        style: TextStyle(
                          color: Color(0xFFF44336),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Informations légales
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FDFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE8F5F2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ARA Service',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E8B57),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© 2024 ARA Service. Tous droits réservés.',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Conditions d\'utilisation',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Politique de confidentialité',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  // -----------------------
  // WIDGETS RÉUTILISABLES
  // -----------------------

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E8B57), size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A3C34),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    bool isVerified = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2E8B57).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2E8B57), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1A3C34),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(color: Color(0xFF5A716B), fontSize: 13),
            ),
            if (isVerified) const SizedBox(height: 4),
            if (isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 10,
                      color: Color(0xFF4CAF50),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Email vérifié',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2E8B57).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2E8B57), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1A3C34),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF5A716B), fontSize: 13),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF5A716B),
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  // -----------------------
  // DIALOGS
  // -----------------------

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE8E7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFF44336),
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A3C34),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF5A716B), fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B57),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Compris',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordResetDialog(
    BuildContext context,
    TextEditingController emailController,
  ) {
    final resetEmailController = TextEditingController(
      text: emailController.text,
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: Color(0xFF2E8B57),
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Réinitialiser le mot de passe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A3C34),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Entrez votre email pour recevoir un lien de réinitialisation',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF5A716B), fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF2E8B57)),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: Color(0xFF2E8B57)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _auth.sendPasswordResetEmail(
                            email: resetEmailController.text.trim(),
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Email de réinitialisation envoyé !',
                              ),
                              backgroundColor: Color(0xFF2E8B57),
                            ),
                          );
                        } catch (e) {
                          _showErrorDialog(context, 'Erreur', e.toString());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E8B57),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Envoyer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ÉCRAN SUPPLEMENTAIRE : DÉTAILS DU PRODUIT
class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du produit'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 150,
                  color: const Color(0xFF00695C).withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB6AC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${product.price.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00695C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Ajouter au panier
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Ajouter au panier',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ÉCRAN SUPPLEMENTAIRE : PAIEMENT
class CheckoutScreen extends StatelessWidget {
  final double total;

  const CheckoutScreen({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Récapitulatif de la commande',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Sous-total'), Text('199.98 €')],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Livraison'), Text('Gratuite')],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${total.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00695C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Moyen de paiement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildPaymentMethod(
                  icon: Icons.money,
                  title: 'Espèces à la livraison',
                  isSelected: false,
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderConfirmationScreen(total: total),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Confirmer le paiement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    required bool isSelected,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? const Color(0xFFE0F2F1) : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00695C)),
        title: Text(title),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF00695C))
            : null,
        onTap: () {
          // Changer le moyen de paiement
        },
      ),
    );
  }
}

// ÉCRAN SUPPLEMENTAIRE : CONFIRMATION DE COMMANDE
class OrderConfirmationScreen extends StatelessWidget {
  final double total;

  const OrderConfirmationScreen({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 60,
                  color: Color(0xFF00695C),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Commande confirmée !',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00695C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Votre commande a été prise en compte avec succès.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'N° de commande: #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Montant total'), Text('Livraison')],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${total.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00695C),
                            ),
                          ),
                          const Text(
                            'Gratuite',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Retour à l'accueil
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Retour à l\'accueil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Suivre la commande
                },
                child: const Text(
                  'Suivre ma commande',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF00695C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
