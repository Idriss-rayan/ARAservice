import 'package:araservice/service_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  List<ProductSearch> _allProducts = [];
  List<ProductSearch> _displayedProducts = [];
  double _priceRange = 5000;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    _firestoreService.getAllProducts().listen((List<ProductSearch> products) {
      if (mounted) {
        setState(() {
          _allProducts = products;
          _applyFilters();
        });

        print('\n=== PRODUITS CHARGÉS ===');
        print('Nombre de produits: ${_allProducts.length}');
        for (var product in _allProducts) {
          print('- ${product.name} (${product.price} frs)');
        }
      }
    });
  }

  void _applyFilters() {
    if (_allProducts.isEmpty) {
      setState(() {
        _displayedProducts = [];
      });
      return;
    }

    print('\n=== APPLIQUER FILTRES ===');
    print('Recherche: "$_searchQuery"');
    print('Prix max: $_priceRange');

    final filtered = _allProducts.where((product) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPrice = product.price <= _priceRange;
      final shouldInclude = matchesSearch && matchesPrice;

      if (!shouldInclude) {
        print(
          '  EXCLU: ${product.name} - ${product.price} frs (raison: ${!matchesSearch ? "nom" : "prix"})',
        );
      }

      return shouldInclude;
    }).toList();

    print('Produits affichés: ${filtered.length}');
    for (var product in filtered) {
      print('  - ${product.name} (${product.price} frs)');
    }

    setState(() {
      _displayedProducts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final primaryColor = Colors.green[800]!;
    final gradientColors = [primaryColor, Colors.green[700]!];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              print('\n=== RÉINITIALISATION ===');
              setState(() {
                _searchQuery = '';
                _priceRange = 10000;
              });
              _applyFilters();
            },
            tooltip: 'Réinitialiser les filtres',
          ),
        ],
      ),
      body: _allProducts.isEmpty
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.green[100]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    Text(
                      'Chargement des produits...',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.green[100]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Barre de recherche avec animation
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Rechercher un produit...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: primaryColor,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: primaryColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _searchQuery = '';
                                          });
                                          _applyFilters();
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                  vertical: screenWidth * 0.03,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                                _applyFilters();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Filtre prix avec animation
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 600),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenWidth * 0.02,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Prix maximum: ${_priceRange.toStringAsFixed(0)} frs',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.02,
                                          vertical: screenWidth * 0.005,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: gradientColors,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${_displayedProducts.length}/${_allProducts.length}',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenWidth * 0.02),
                                  SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 6,
                                      thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: screenWidth * 0.025,
                                        disabledThumbRadius:
                                            screenWidth * 0.025,
                                      ),
                                      overlayShape: RoundSliderOverlayShape(
                                        overlayRadius: screenWidth * 0.035,
                                      ),
                                      activeTrackColor: primaryColor,
                                      inactiveTrackColor: Colors.green[200],
                                      thumbColor: Colors.white,
                                      overlayColor: primaryColor.withOpacity(
                                        0.2,
                                      ),
                                      valueIndicatorColor: primaryColor,
                                    ),
                                    child: Slider(
                                      value: _priceRange,
                                      min: 0,
                                      max: 20000,
                                      divisions: 20,
                                      label: _priceRange.toStringAsFixed(0),
                                      onChanged: (value) {
                                        setState(() {
                                          _priceRange = value;
                                        });
                                      },
                                      onChangeEnd: (value) {
                                        _applyFilters();
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '0 frs',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        '20000 frs',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Info sur les produits avec animation
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 700),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.green[50]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Plage de prix disponible:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenWidth * 0.035,
                                      color: primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.01),
                                  Text(
                                    'Min: ${_allProducts.map((p) => p.price).reduce((a, b) => a < b ? a : b)} frs '
                                    '| Max: ${_allProducts.map((p) => p.price).reduce((a, b) => a > b ? a : b)} frs',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenWidth * 0.02),

                  // Résultats avec animations en cascade
                  Expanded(
                    child: _displayedProducts.isEmpty
                        ? AnimationConfiguration.synchronized(
                            duration: const Duration(milliseconds: 800),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(
                                          screenWidth * 0.06,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.green[50]!,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 15,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.search_off,
                                          size: screenWidth * 0.2,
                                          color: primaryColor,
                                        ),
                                      ),
                                      SizedBox(height: screenWidth * 0.04),
                                      Text(
                                        'Aucun produit trouvé',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.05,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
                                      ),
                                      SizedBox(height: screenWidth * 0.02),
                                      Text(
                                        'Ajustez le filtre de prix ou votre recherche',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: screenWidth * 0.04),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                          gradient: LinearGradient(
                                            colors: gradientColors,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            print('\n=== AFFICHER TOUS ===');
                                            setState(() {
                                              _searchQuery = '';
                                              _priceRange = 20000;
                                            });
                                            _applyFilters();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.06,
                                              vertical: screenWidth * 0.03,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                          ),
                                          child: Text(
                                            'Afficher tous les produits',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.035,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : AnimationLimiter(
                            child: GridView.builder(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: screenWidth * 0.04,
                                    mainAxisSpacing: screenWidth * 0.04,
                                    childAspectRatio: 0.75,
                                  ),
                              itemCount: _displayedProducts.length,
                              itemBuilder: (context, index) {
                                final product = _displayedProducts[index];
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration: const Duration(milliseconds: 500),
                                  columnCount: 2,
                                  child: ScaleAnimation(
                                    child: FadeInAnimation(
                                      child: _buildProductCard(
                                        context,
                                        product,
                                        primaryColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductSearch product,
    Color primaryColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gradientColors = [primaryColor, Colors.green[700]!];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            print('\n=== PRODUIT SÉLECTIONNÉ ===');
            print('Nom: ${product.name}');
            print('Prix: ${product.price} frs');
            print('Catégorie: ${product.category}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image avec effet de bordure arrondie
              Container(
                height: screenWidth * 0.3,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.broken_image,
                              size: screenWidth * 0.1,
                              color: Colors.grey[400],
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.image,
                            size: screenWidth * 0.1,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
              ),

              // Contenu
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nom
                      Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Catégorie
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                          vertical: screenWidth * 0.005,
                        ),
                        decoration: BoxDecoration(
                          gradient: product.category == 'Ménager'
                              ? LinearGradient(
                                  colors: [
                                    Colors.blue[400]!,
                                    Colors.blue[600]!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Prix
                      Text(
                        '${product.price.toStringAsFixed(0)} frs',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                          color: primaryColor,
                        ),
                      ),
                    ],
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
