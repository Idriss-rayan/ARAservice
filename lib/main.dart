import 'package:flutter/material.dart';

void main() {
  runApp(const ARAApp());
}

class ARAApp extends StatelessWidget {
  const ARAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARA Service',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00695C),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF00695C),
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00695C),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainNavigationScreen(),
    );
  }
}

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
    subcategories: ['Confection sur mesure', 'Retouches', 'Prêt-à-porter'],
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
      const CategoriesScreen(),
      const SearchScreen(),
      CartScreen(cartItems: cartItems),
      const AccountScreen(),
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
                icon: Icon(Icons.grid_view_rounded),
                label: 'Catégories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                label: 'Recherche',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_rounded),
                label: 'Panier',
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

  const HomeScreen({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Badge(
              label: Text(
                cartItems.length.toString(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.red,
              textColor: Colors.white,
              child: IconButton(
                icon: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Color(0xFFE3F2FD)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_rounded,
                    color: Color(0xFF00695C),
                    size: 22,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CartScreen(cartItems: cartItems),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00695C), Color(0xFF4DB6AC)],
                    stops: [0.0, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00695C).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.spa_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Moi c est ARA, votre assistant personnel pour tous vos besoins de nettoyage, couture et service à domicile.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Votre partenaire pour un quotidien impeccable',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '(Nettoyer, coudre, servir)',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

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
                    const Color(0xFF2196F3),
                  ),
                  _buildCategoryCard(
                    context,
                    'Produits ménagers',
                    Icons.clean_hands_rounded,
                    const Color(0xFF00BCD4),
                  ),
                  _buildCategoryCard(
                    context,
                    'Mode & Confection',
                    Icons.content_cut_rounded,
                    const Color(0xFF00695C),
                  ),
                  _buildCategoryCard(
                    context,
                    'Pressing',
                    Icons.local_laundry_service_rounded,
                    const Color(0xFF4DB6AC),
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
    Color color,
  ) {
    return Container(
      height: 110, // Hauteur fixe pour éviter l'overflow
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: color.withOpacity(0.1),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              // Naviguer vers la catégorie
            },
            child: Padding(
              padding: const EdgeInsets.all(12), // Padding réduit
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize:
                    MainAxisSize.min, // Important pour éviter l'expansion
                children: [
                  Icon(icon, size: 36, color: color), // Taille réduite
                  const SizedBox(height: 8), // Espacement réduit
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14, // Taille réduite
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2, // Limite à 2 lignes
                    overflow: TextOverflow
                        .ellipsis, // Points de suspension si trop long
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
class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartScreen({super.key, required this.cartItems});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _showDeleteConfirmation = false;
  int? _itemToDeleteIndex;

  @override
  Widget build(BuildContext context) {
    final total = widget.cartItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mon Panier',
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
          ),
        ),
        actions: [
          if (widget.cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4DB6AC), Color(0xFF2196F3)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                onPressed: () {
                  _showClearCartDialog(context);
                },
              ),
            ),
        ],
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
        child: Column(
          children: [
            // En-tête avec résumé
            if (widget.cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF00695C), Color(0xFF2196F3)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
                          '${widget.cartItems.length} ${widget.cartItems.length > 1 ? 'articles' : 'article'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ${total.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: widget.cartItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE3F2FD),
                                    Color(0xFFE8F5E9),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                size: 70,
                                color: Color(0xFF00695C),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Votre panier est vide',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00695C),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Parcourez nos produits et ajoutez-les\nà votre panier',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Naviguer vers l'accueil
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00695C),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.storefront_rounded, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      'Explorer',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Stack(
                      children: [
                        // Effet de fond
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFFE3F2FD).withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Liste des articles
                        ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: widget.cartItems.length,
                          itemBuilder: (context, index) {
                            final cartItem = widget.cartItems[index];
                            final product = cartItem.product;
                            final itemTotal = cartItem.totalPrice;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(bottom: 16),
                              transform:
                                  _showDeleteConfirmation &&
                                      _itemToDeleteIndex == index
                                  ? Matrix4.translationValues(10, 0, 0)
                                  : Matrix4.identity(),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailScreen(
                                              product: product,
                                            ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Image du produit
                                          Container(
                                            width: 90,
                                            height: 90,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: product.isPopular
                                                    ? [
                                                        const Color(0xFF2196F3),
                                                        const Color(0xFF4DB6AC),
                                                      ]
                                                    : [
                                                        const Color(0xFF4DB6AC),
                                                        const Color(0xFF00695C),
                                                      ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    size: 40,
                                                  ),
                                                ),
                                                if (product.isPopular)
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      decoration:
                                                          const BoxDecoration(
                                                            color:
                                                                Colors.orange,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                      child: const Icon(
                                                        Icons.star_rounded,
                                                        color: Colors.white,
                                                        size: 12,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),

                                          // Détails du produit
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF263238),
                                                    height: 1.3,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  product.category,
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF00695C,
                                                    ).withOpacity(0.8),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),

                                                // Prix et quantité
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${product.price.toStringAsFixed(2)} €',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: Color(
                                                                  0xFF00695C,
                                                                ),
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          'Total: ${itemTotal.toStringAsFixed(2)} €',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Color(
                                                                  0xFF4DB6AC,
                                                                ),
                                                              ),
                                                        ),
                                                      ],
                                                    ),

                                                    // Contrôle de quantité
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            const LinearGradient(
                                                              colors: [
                                                                Color(
                                                                  0xFFE3F2FD,
                                                                ),
                                                                Color(
                                                                  0xFFE8F5E9,
                                                                ),
                                                              ],
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              25,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          _buildQuantityButton(
                                                            Icons.remove,
                                                            () {
                                                              if (cartItem
                                                                      .quantity >
                                                                  1) {
                                                                setState(() {
                                                                  cartItem
                                                                      .quantity--;
                                                                });
                                                              } else {
                                                                _showDeleteDialog(
                                                                  context,
                                                                  index,
                                                                );
                                                              }
                                                            },
                                                            cartItem.quantity ==
                                                                1,
                                                          ),
                                                          Container(
                                                            width: 40,
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 8,
                                                                ),
                                                            child: Center(
                                                              child: Text(
                                                                cartItem
                                                                    .quantity
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Color(
                                                                    0xFF00695C,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          _buildQuantityButton(
                                                            Icons.add,
                                                            () {
                                                              setState(() {
                                                                cartItem
                                                                    .quantity++;
                                                              });
                                                            },
                                                            false,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Bouton supprimer
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8,
                                              top: 4,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                _showDeleteDialog(
                                                  context,
                                                  index,
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(
                                                    0.1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.red
                                                        .withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
            ),

            // Barre de résumé et paiement
            if (widget.cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Détails du total
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF8FDFF), Color(0xFFF0F9F8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF4DB6AC).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildTotalRow(
                            'Sous-total',
                            '${(total * 0.95).toStringAsFixed(2)} €',
                          ),
                          const SizedBox(height: 8),
                          _buildTotalRow('Livraison', 'Gratuite'),
                          const SizedBox(height: 12),
                          Divider(
                            color: const Color(0xFF00695C).withOpacity(0.2),
                            height: 1,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF00695C),
                                ),
                              ),
                              Text(
                                '${total.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF00695C),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Boutons d'action
                    Row(
                      children: [
                        // Expanded(
                        //   child: OutlinedButton(
                        //     onPressed: () {
                        //       // Continuer les achats
                        //       Navigator.of(context).pop();
                        //     },
                        //     style: OutlinedButton.styleFrom(
                        //       padding: const EdgeInsets.symmetric(vertical: 18),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //       side: BorderSide(
                        //         color: const Color(0xFF4DB6AC).withOpacity(0.5),
                        //         width: 2,
                        //       ),
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         const Icon(
                        //           Icons.arrow_back_rounded,
                        //           color: Color(0xFF00695C),
                        //           size: 20,
                        //         ),
                        //         const SizedBox(width: 10),
                        //         Text(
                        //           'Continuer',
                        //           style: TextStyle(
                        //             fontSize: 16,
                        //             fontWeight: FontWeight.w700,
                        //             color: const Color(0xFF00695C),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CheckoutScreen(total: total),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00695C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                              shadowColor: const Color(
                                0xFF00695C,
                              ).withOpacity(0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Commander',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF00695C),
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Garanties
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4DB6AC).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: const Color(0xFF4DB6AC),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Paiement sécurisé • Livraison gratuite • Satisfaction garantie',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF00695C),
                                fontWeight: FontWeight.w500,
                              ),
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
    );
  }

  Widget _buildTotalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00695C),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton(
    IconData icon,
    VoidCallback onPressed,
    bool isDisabled,
  ) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey[200] : Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 18,
          color: isDisabled ? Colors.grey[400] : const Color(0xFF00695C),
        ),
        onPressed: isDisabled ? null : onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Supprimer l\'article',
            style: TextStyle(
              color: Color(0xFF00695C),
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer "${widget.cartItems[index].product.name}" de votre panier ?',
            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  color: Color(0xFF00695C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.cartItems.removeAt(index);
                });
                Navigator.pop(context);

                // Afficher un snackbar de confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF00695C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    behavior: SnackBarBehavior.floating,
                    content: const Text(
                      'Article supprimé du panier',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Vider le panier',
            style: TextStyle(
              color: Color(0xFF00695C),
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vider tout votre panier ?',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  color: Color(0xFF00695C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.cartItems.clear();
                });
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF00695C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    behavior: SnackBarBehavior.floating,
                    content: const Text(
                      'Panier vidé avec succès',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Vider',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ÉCRAN 5 : COMPTE
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isLoggedIn = false;
  String _userName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Compte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_isLoggedIn)
              Column(
                children: [
                  const SizedBox(height: 40),
                  const Icon(
                    Icons.person_outline,
                    size: 80,
                    color: Color(0xFF00695C),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Connectez-vous à votre compte',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoggedIn = true;
                          _userName = 'Client ARA';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isLoggedIn = true;
                          _userName = 'Nouveau Client';
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Color(0xFF00695C)),
                      ),
                      child: const Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF00695C),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2F1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFF00695C),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Membre depuis 2023',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mes Commandes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00695C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Historique des commandes',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.local_shipping,
                    title: 'Suivi de commande',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Mon Profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00695C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: 'Adresses de livraison',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.payment,
                    title: 'Moyens de paiement',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Paramètres',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoggedIn = false;
                          _userName = '';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Déconnexion',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00695C)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
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
      appBar: AppBar(title: const Text('Détails du produit')),
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
      appBar: AppBar(title: const Text('Paiement')),
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
                  icon: Icons.credit_card,
                  title: 'Carte bancaire',
                  isSelected: true,
                ),
                _buildPaymentMethod(
                  icon: Icons.money,
                  title: 'Espèces à la livraison',
                  isSelected: false,
                ),
                _buildPaymentMethod(
                  icon: Icons.mobile_friendly,
                  title: 'Mobile Money',
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
      appBar: AppBar(title: const Text('Confirmation')),
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
