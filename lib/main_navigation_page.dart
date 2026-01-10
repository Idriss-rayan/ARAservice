import 'package:araservice/auth/auth_gate.dart';
import 'package:araservice/categories/mode_confession.dart';
import 'package:araservice/categories/pressing_page.dart'
    hide ModeConfectionPage;
import 'package:araservice/categories/produits_menagers_page.dart';
import 'package:araservice/categories/shopping_page.dart';
import 'package:araservice/components/dashboard_carousel.dart';
import 'package:araservice/prod_fireb.dart';
import 'package:araservice/search_screen.dart';
import 'package:araservice/service_search.dart' hide FirestoreService;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Modèle de produit
// Modèle de produit - Mise à jour pour correspondre à Firestore
class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String? imageUrl;
  final bool isPopular;
  final bool isNew;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.imageUrl,
    this.isPopular = false,
    this.isNew = false,
    this.createdAt,
  });

  // Factory constructor pour créer un Product depuis Firestore
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'Shopping', // Vous devrez ajouter ce champ
      description: data['description'] ?? '', // Vous devrez ajouter ce champ
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
      isPopular: data['isPopular'] ?? false, // Vous devrez ajouter ce champ
      isNew: data['isNew'] ?? false, // Vous devrez ajouter ce champ
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isPopular': isPopular,
      'isNew': isNew,
      'createdAt': createdAt,
    };
  }
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

// Créer une classe TextStyles responsive
class ResponsiveText {
  static TextStyle title(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return TextStyle(
      fontSize: width * 0.06,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF00695C),
      letterSpacing: 0.5,
    );
  }

  static TextStyle body(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.normal);
  }
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
      backgroundColor: const Color(0xFFE8F5F4),
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
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                label: 'Recherche',
              ),
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
  final FirestoreService firestoreService = FirestoreService();

  HomeScreen({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'ARA Service',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: screenWidth * 0.06,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00695C), Color(0xFF2196F3)],
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
            colors: [Color(0xFFF8FDFF), Color(0xFFF0F9F8), Color(0xFFE8F5F4)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardCarousel(),
              SizedBox(height: screenHeight * 0.03),
              Text('Catégories', style: ResponsiveText.title(context)),
              SizedBox(height: screenHeight * 0.02),

              GridView.count(
                crossAxisCount: screenWidth > 600 ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: screenWidth < 360 ? 1.3 : 1.6,
                mainAxisSpacing: screenWidth * 0.04,
                crossAxisSpacing: screenWidth * 0.04,
                children: [
                  _buildCategoryCard(
                    context,
                    'Shopping',
                    Icons.shopping_basket_rounded,
                    const [Color(0xFF1565C0), Color(0xFF2196F3)],
                    0,
                  ),
                  _buildCategoryCard(
                    context,
                    'Produits ménagers',
                    Icons.clean_hands_rounded,
                    const [Color(0xFF00838F), Color(0xFF00BCD4)],
                    1,
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

              SizedBox(height: screenHeight * 0.04),
              Text('Produits populaires', style: ResponsiveText.title(context)),
              SizedBox(height: screenHeight * 0.02),

              StreamBuilder<List<Product>>(
                stream: firestoreService.getPopularProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: screenWidth * 0.7,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return SizedBox(
                      height: screenWidth * 0.7,
                      child: Center(child: Text('Erreur: ${snapshot.error}')),
                    );
                  }

                  final popularProducts = snapshot.data ?? [];

                  if (popularProducts.isEmpty) {
                    return SizedBox(
                      height: screenWidth * 0.7,
                      child: const Center(
                        child: Text('Aucun produit populaire disponible'),
                      ),
                    );
                  }

                  return SizedBox(
                    height: screenWidth * 0.7,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: popularProducts.length,
                      itemBuilder: (context, index) {
                        final product = popularProducts[index];
                        return _buildProductCard(context, product);
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.04),
              Text('Nouveautés', style: ResponsiveText.title(context)),
              SizedBox(height: screenHeight * 0.02),

              StreamBuilder<List<Product>>(
                stream: firestoreService.getNewProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: screenWidth * 0.7,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return SizedBox(
                      height: screenWidth * 0.7,
                      child: Center(child: Text('Erreur: ${snapshot.error}')),
                    );
                  }

                  final newProducts = snapshot.data ?? [];

                  if (newProducts.isEmpty) {
                    return SizedBox(
                      height: screenWidth * 0.7,
                      child: const Center(
                        child: Text('Aucun nouveau produit disponible'),
                      ),
                    );
                  }

                  return SizedBox(
                    height: screenWidth * 0.7,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: newProducts.length,
                      itemBuilder: (context, index) {
                        final product = newProducts[index];
                        return _buildProductCard(context, product);
                      },
                    ),
                  );
                },
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
    int index,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
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
            final category = categories[index];
            Widget page;

            switch (category.name) {
              case 'Shopping':
                page = const ShoppingSimplePage();
                break;
              case 'Produits ménagers':
                page = const ProduitsMenagersPage();
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
                page = const ShoppingSimplePage();
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: screenWidth * 0.1, color: Colors.white),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.030,
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
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.45;

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: screenWidth * 0.04),
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
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: screenWidth * 0.15,
                      color: const Color(0xFF00695C).withOpacity(0.5),
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                SizedBox(
                  height: screenWidth * 0.12,
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.035,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: screenWidth * 0.03,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(2)} frs',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.04,
                        color: const Color(0xFF00695C),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenWidth * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DB6AC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: screenWidth * 0.045,
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Catégories',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: screenWidth * 0.05,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF00695C),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F2F1), Color(0xFFF5F5F5)],
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(screenWidth * 0.05),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Container(
              margin: EdgeInsets.only(bottom: screenWidth * 0.04),
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
                    tilePadding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenWidth * 0.03,
                    ),
                    leading: Container(
                      width: screenWidth * 0.11,
                      height: screenWidth * 0.11,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF00695C), Color(0xFF4DB6AC)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        category.icon,
                        color: Colors.white,
                        size: screenWidth * 0.055,
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00695C),
                      ),
                    ),
                    trailing: Container(
                      width: screenWidth * 0.08,
                      height: screenWidth * 0.08,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.expand_more,
                        color: const Color(0xFF00695C),
                        size: screenWidth * 0.05,
                      ),
                    ),
                    children: category.subcategories.map((subcategory) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFFF8FDFC), Color(0xFFE8F5F4)],
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                            vertical: screenWidth * 0.025,
                          ),
                          leading: Container(
                            width: screenWidth * 0.02,
                            height: screenWidth * 0.02,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4DB6AC),
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(
                            subcategory,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF37474F),
                            ),
                          ),
                          trailing: Container(
                            width: screenWidth * 0.07,
                            height: screenWidth * 0.07,
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
                            child: Icon(
                              Icons.chevron_right,
                              color: const Color(0xFF4DB6AC),
                              size: screenWidth * 0.04,
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
                const Text(
                  'Déconnexion',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
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
                Row(
                  children: [
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

  Widget _buildAuth() {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView(
      padding: EdgeInsets.all(screenWidth * 0.04),
      children: [
        SizedBox(height: screenWidth * 0.1),
        Center(
          child: Container(
            width: screenWidth * 0.3,
            height: screenWidth * 0.3,
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
            child: Icon(
              Icons.person_outlined,
              size: screenWidth * 0.15,
              color: const Color(0xFF2E8B57),
            ),
          ),
        ),
        SizedBox(height: screenWidth * 0.06),
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
        SizedBox(height: screenWidth * 0.02),
        const Center(
          child: Text(
            'Connectez-vous à votre compte',
            style: TextStyle(fontSize: 16, color: Color(0xFF5A716B)),
          ),
        ),
        SizedBox(height: screenWidth * 0.1),

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
        SizedBox(height: screenWidth * 0.04),

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
        SizedBox(height: screenWidth * 0.06),

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

        SizedBox(height: screenWidth * 0.05),

        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Text(
                'ou',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
          ],
        ),

        SizedBox(height: screenWidth * 0.05),

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

        SizedBox(height: screenWidth * 0.08),

        Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
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
              SizedBox(height: screenWidth * 0.03),
              TextButton(
                onPressed: () {
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
              SizedBox(height: screenWidth * 0.02),
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

  Widget _buildAccount(User user) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
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
                    width: screenWidth * 0.18,
                    height: screenWidth * 0.18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2E8B57),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: user.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              user.photoURL!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person_rounded,
                            size: screenWidth * 0.08,
                            color: Colors.white,
                          ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'Utilisateur',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A3C34),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Text(
                          user.email ?? '',
                          style: TextStyle(
                            color: const Color(0xFF5A716B),
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                        if (user.emailVerified)
                          Padding(
                            padding: EdgeInsets.only(top: screenWidth * 0.01),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.02,
                                    vertical: screenWidth * 0.005,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2E8B57,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      screenWidth * 0.03,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        size: screenWidth * 0.03,
                                        color: const Color(0xFF2E8B57),
                                      ),
                                      SizedBox(width: screenWidth * 0.01),
                                      Text(
                                        'Vérifié',
                                        style: TextStyle(
                                          color: const Color(0xFF2E8B57),
                                          fontSize: screenWidth * 0.03,
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
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.05),

            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              children: [
                _buildSectionHeader(
                  icon: Icons.info_outline_rounded,
                  title: 'Informations personnelles',
                ),
                SizedBox(height: screenWidth * 0.03),

                _buildInfoTile(
                  icon: Icons.email_rounded,
                  title: 'Adresse email',
                  value: user.email ?? 'Non défini',
                  isVerified: user.emailVerified,
                ),

                _buildInfoTile(
                  icon: Icons.calendar_month_rounded,
                  title: 'Compte créé',
                  value: user.metadata.creationTime != null
                      ? 'Le ${user.metadata.creationTime!.day}/${user.metadata.creationTime!.month}/${user.metadata.creationTime!.year}'
                      : 'Date inconnue',
                ),

                SizedBox(height: screenWidth * 0.06),

                _buildSectionHeader(icon: Icons.tune_rounded, title: 'Actions'),
                SizedBox(height: screenWidth * 0.03),

                Container(
                  width: double.infinity,
                  height: screenWidth * 0.14,
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
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: const Color(0xFFF44336),
                          size: screenWidth * 0.05,
                        ),
                        SizedBox(width: screenWidth * 0.025),
                        Text(
                          'Se déconnecter',
                          style: TextStyle(
                            color: const Color(0xFFF44336),
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenWidth * 0.08),

                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
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
                      SizedBox(height: screenWidth * 0.02),
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.01),
                      Text(
                        '© 2024 ARA Service. Tous droits réservés.',
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.03),
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
                                fontSize: screenWidth * 0.03,
                                color: Colors.grey[600],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              'Politique de confidentialité',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
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
                SizedBox(height: screenWidth * 0.05),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E8B57), size: screenWidth * 0.045),
          SizedBox(width: screenWidth * 0.02),
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A3C34),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.025),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: ListTile(
        leading: Container(
          width: screenWidth * 0.1,
          height: screenWidth * 0.1,
          decoration: BoxDecoration(
            color: const Color(0xFF2E8B57).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2E8B57),
            size: screenWidth * 0.05,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF1A3C34),
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: const Color(0xFF5A716B),
                fontSize: screenWidth * 0.035,
              ),
            ),
            if (isVerified) SizedBox(height: screenWidth * 0.01),
            if (isVerified)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenWidth * 0.005,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.025),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: screenWidth * 0.025,
                      color: const Color(0xFF4CAF50),
                    ),
                    SizedBox(width: screenWidth * 0.01),
                    Text(
                      'Email vérifié',
                      style: TextStyle(
                        color: const Color(0xFF4CAF50),
                        fontSize: screenWidth * 0.03,
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du produit'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: screenWidth * 0.6,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: screenWidth * 0.3,
                  color: const Color(0xFF00695C).withOpacity(0.5),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.05),
            Text(
              product.name,
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenWidth * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB6AC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.category,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${product.price.toStringAsFixed(2)} frs',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00695C),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.05),
            Text(
              'Description',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              product.description,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenWidth * 0.08),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Ajouter au panier
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Ajouter au panier',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Récapitulatif de la commande',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Card(
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Sous-total'), Text('199.98 frs')],
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Livraison'), Text('Gratuite')],
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    Divider(color: Colors.grey[300]),
                    SizedBox(height: screenWidth * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${total.toStringAsFixed(2)} frs',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00695C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.08),
            Text(
              'Moyen de paiement',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Column(
              children: [
                _buildPaymentMethod(
                  icon: Icons.money,
                  title: 'Espèces à la livraison',
                  isSelected: false,
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.08),
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
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Confirmer le paiement',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.25,
                height: screenWidth * 0.25,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: screenWidth * 0.15,
                  color: const Color(0xFF00695C),
                ),
              ),
              SizedBox(height: screenWidth * 0.08),
              Text(
                'Commande confirmée !',
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00695C),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenWidth * 0.04),
              Text(
                'Votre commande a été prise en compte avec succès.',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenWidth * 0.02),
              Text(
                'N° de commande: #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenWidth * 0.06),
              Card(
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Montant total'), Text('Livraison')],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${total.toStringAsFixed(2)} frs',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00695C),
                            ),
                          ),
                          Text(
                            'Gratuite',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.08),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Retour à l\'accueil',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
              TextButton(
                onPressed: () {
                  // Suivre la commande
                },
                child: Text(
                  'Suivre ma commande',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: const Color(0xFF00695C),
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
