import 'package:araservice/service_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:url_launcher/url_launcher.dart';

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
  bool _showFloatingFilter = false;

  // Nouvelles couleurs
  final Color backgroundColor = const Color(0xFFE8F5F4);
  final Color primaryColor = const Color(0xFF00695C);
  final Color secondaryColor = const Color(0xFF2196F3);
  final Color accentColor = const Color(0xFF4DB6AC);
  final Color textColor = const Color(0xFF263238);

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

    final filtered = _allProducts.where((product) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPrice = product.price <= _priceRange;
      return matchesSearch && matchesPrice;
    }).toList();

    setState(() {
      _displayedProducts = filtered;
    });
  }

  Future<void> _orderViaWhatsApp(ProductSearch product) async {
    final message =
        '''
Bonjour! 😊

Je souhaite commander le produit suivant :

📦 ${product.name}
💰 Prix: ${product.price} frs
🏷️ Catégorie: ${product.category}

Je suis intéressé(e) par ce produit et j'aimerais en savoir plus sur:
- La disponibilité
- Les options de livraison
- Les modalités de paiement

Pouvez-vous me contacter pour finaliser la commande?

Merci! 🙏
    ''';

    // Utilisez Share.share directement
    try {
      await Share.share(message, subject: 'Commande: ${product.name}');
    } catch (e) {
      // Affichez une erreur si le partage échoue
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de partager: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showProductDetailsDialog(BuildContext context, ProductSearch product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 360;
    final isLargePhone = screenWidth >= 360 && screenWidth < 600;
    final isTablet = screenWidth >= 600;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(
            isTablet
                ? 40
                : isSmallPhone
                ? 12
                : 16,
          ),
          child: AnimationConfiguration.synchronized(
            duration: Duration(milliseconds: 500),
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 500 : double.infinity,
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, backgroundColor],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 25,
                        spreadRadius: 2,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(
                            isSmallPhone
                                ? 14
                                : isTablet
                                ? 24
                                : 20,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [primaryColor, secondaryColor],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_bag,
                                size: isSmallPhone
                                    ? 36
                                    : isTablet
                                    ? 60
                                    : 50,
                                color: Colors.white,
                              ),
                              SizedBox(height: isSmallPhone ? 6 : 10),
                              Text(
                                'Détails du produit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallPhone
                                      ? 16
                                      : isTablet
                                      ? 24
                                      : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(isSmallPhone ? 10 : 20),
                          child: Container(
                            height: isSmallPhone
                                ? 100
                                : isTablet
                                ? 180
                                : 140,
                            width: isSmallPhone
                                ? 100
                                : isTablet
                                ? 180
                                : 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.1),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Center(
                                                child: Icon(
                                                  Icons.image,
                                                  size: isSmallPhone
                                                      ? 36
                                                      : isTablet
                                                      ? 60
                                                      : 50,
                                                  color: accentColor,
                                                ),
                                              ),
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.shopping_bag,
                                        size: isSmallPhone
                                            ? 36
                                            : isTablet
                                            ? 60
                                            : 50,
                                        color: accentColor,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallPhone ? 10 : 20,
                          ),
                          child: Column(
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: isSmallPhone
                                      ? 14
                                      : isTablet
                                      ? 22
                                      : 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: isSmallPhone ? 8 : 15),

                              Wrap(
                                spacing: isSmallPhone ? 6 : 12,
                                runSpacing: isSmallPhone ? 6 : 12,
                                alignment: WrapAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallPhone ? 8 : 15,
                                      vertical: isSmallPhone ? 3 : 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [accentColor, secondaryColor],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      product.category,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: isSmallPhone
                                            ? 10
                                            : isTablet
                                            ? 16
                                            : 14,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmallPhone ? 8 : 15,
                                      vertical: isSmallPhone ? 3 : 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: primaryColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${product.price} frs',
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isSmallPhone
                                                ? 10
                                                : isTablet
                                                ? 18
                                                : 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: isSmallPhone ? 12 : 25),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallPhone ? 8 : 0,
                                ),
                                child: Text(
                                  'Vous souhaitez commander ce produit?',
                                  style: TextStyle(
                                    fontSize: isSmallPhone
                                        ? 12
                                        : isTablet
                                        ? 18
                                        : 16,
                                    color: textColor.withOpacity(0.8),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: isSmallPhone ? 8 : 20),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallPhone ? 8 : 0,
                                ),
                                child: Text(
                                  'Nous allons vous rediriger vers WhatsApp\npour finaliser votre commande',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isSmallPhone
                                        ? 10
                                        : isTablet
                                        ? 16
                                        : 14,
                                    color: textColor.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isSmallPhone ? 16 : 30),

                        Padding(
                          padding: EdgeInsets.all(isSmallPhone ? 10 : 20),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF25D366),
                                      Color(0xFF128C7E),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF25D366).withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _orderViaWhatsApp(product);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: isSmallPhone ? 10 : 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        color: Colors.white,
                                        size: isSmallPhone
                                            ? 18
                                            : isTablet
                                            ? 26
                                            : 22,
                                      ),
                                      SizedBox(width: isSmallPhone ? 6 : 8),
                                      Flexible(
                                        child: Text(
                                          'Commander via WhatsApp',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isSmallPhone
                                                ? 12
                                                : isTablet
                                                ? 18
                                                : 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: isSmallPhone ? 8 : 12),

                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: isSmallPhone ? 8 : 12,
                                  ),
                                ),
                                child: Text(
                                  'Annuler',
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.7),
                                    fontSize: isSmallPhone
                                        ? 12
                                        : isTablet
                                        ? 18
                                        : 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingFilterBar() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: _showFloatingFilter ? 16 : -300,
      left: 16,
      right: 16,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < -5 && !_showFloatingFilter) {
            setState(() => _showFloatingFilter = true);
          } else if (details.delta.dy > 5 && _showFloatingFilter) {
            setState(() => _showFloatingFilter = false);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
                offset: Offset(0, 5),
              ),
            ],
            border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showFloatingFilter = !_showFloatingFilter;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _showFloatingFilter
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Filtres',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_displayedProducts.length}/${_allProducts.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_showFloatingFilter)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Prix max:',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [accentColor, primaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_priceRange.toInt()} frs',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 6,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                          ),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 20,
                          ),
                          activeTrackColor: primaryColor,
                          inactiveTrackColor: accentColor.withOpacity(0.3),
                          thumbColor: Colors.white,
                          overlayColor: primaryColor.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _priceRange,
                          min: 0,
                          max: 20000,
                          divisions: 20,
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

                      SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0 frs',
                            style: TextStyle(color: textColor, fontSize: 12),
                          ),
                          Text(
                            '20000 frs',
                            style: TextStyle(color: textColor, fontSize: 12),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: primaryColor.withOpacity(0.1),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _priceRange = 10000;
                            });
                            _applyFilters();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh,
                                color: primaryColor,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Réinitialiser les filtres',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isSmallPhone = screenWidth < 360;
    final isMediumPhone = screenWidth >= 360 && screenWidth < 400;
    final isLargePhone = screenWidth >= 400 && screenWidth < 600;
    final isTablet = screenWidth >= 600;

    int crossAxisCount = 2;
    double childAspectRatio = 0.75;
    double mainSpacing = 12;
    double crossSpacing = 12;

    if (isSmallPhone) {
      crossAxisCount = 2;
      childAspectRatio = 0.65;
      mainSpacing = 8;
      crossSpacing = 8;
    } else if (isMediumPhone) {
      crossAxisCount = 2;
      childAspectRatio = 0.7;
      mainSpacing = 10;
      crossSpacing = 10;
    } else if (isLargePhone) {
      crossAxisCount = 2;
      childAspectRatio = 0.75;
      mainSpacing = 12;
      crossSpacing = 12;
    } else if (isTablet) {
      if (screenWidth > 800) {
        crossAxisCount = 4;
        childAspectRatio = 0.8;
      } else {
        crossAxisCount = 3;
        childAspectRatio = 0.8;
      }
      mainSpacing = 16;
      crossSpacing = 16;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recherche de Produits',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: isSmallPhone
                ? 14
                : isTablet
                ? 22
                : 18,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, secondaryColor],
            ),
          ),
        ),
        toolbarHeight: isSmallPhone
            ? 52
            : isTablet
            ? 72
            : 64,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [backgroundColor, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: _allProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Chargement des produits...',
                          style: TextStyle(
                            fontSize: isSmallPhone
                                ? 12
                                : isTablet
                                ? 18
                                : 16,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: EdgeInsets.all(
                            isSmallPhone
                                ? 10
                                : isTablet
                                ? 20
                                : 16,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Rechercher un produit...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: primaryColor,
                                  size: isSmallPhone
                                      ? 18
                                      : isTablet
                                      ? 26
                                      : 22,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.clear,
                                          color: primaryColor,
                                          size: isSmallPhone
                                              ? 18
                                              : isTablet
                                              ? 26
                                              : 22,
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
                                  horizontal: isSmallPhone ? 14 : 20,
                                  vertical: isSmallPhone ? 12 : 16,
                                ),
                                hintStyle: TextStyle(
                                  fontSize: isSmallPhone
                                      ? 12
                                      : isTablet
                                      ? 18
                                      : 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              style: TextStyle(
                                fontSize: isSmallPhone
                                    ? 12
                                    : isTablet
                                    ? 18
                                    : 16,
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

                      SizedBox(height: _showFloatingFilter ? 180 : 0),

                      Expanded(
                        child: _displayedProducts.isEmpty
                            ? Center(
                                child: SingleChildScrollView(
                                  physics: ClampingScrollPhysics(),
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      isSmallPhone ? 12 : 20,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(
                                            isSmallPhone ? 20 : 40,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white,
                                                backgroundColor,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryColor.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.search_off,
                                            size: isSmallPhone
                                                ? 50
                                                : isTablet
                                                ? 100
                                                : 80,
                                            color: primaryColor,
                                          ),
                                        ),
                                        SizedBox(
                                          height: isSmallPhone ? 16 : 24,
                                        ),
                                        Text(
                                          'Aucun produit trouvé',
                                          style: TextStyle(
                                            fontSize: isSmallPhone
                                                ? 16
                                                : isTablet
                                                ? 26
                                                : 22,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 8),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallPhone ? 20 : 40,
                                          ),
                                          child: Text(
                                            'Ajustez vos critères de recherche',
                                            style: TextStyle(
                                              fontSize: isSmallPhone
                                                  ? 12
                                                  : isTablet
                                                  ? 18
                                                  : 16,
                                              color: textColor.withOpacity(0.6),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(
                                          height: isSmallPhone ? 20 : 24,
                                        ),
                                        Container(
                                          width: double.infinity,
                                          constraints: BoxConstraints(
                                            maxWidth: isTablet ? 400 : 300,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                primaryColor,
                                                secondaryColor,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryColor.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 15,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _searchQuery = '';
                                                _priceRange = 20000;
                                                _showFloatingFilter = true;
                                              });
                                              _applyFilters();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: isSmallPhone
                                                    ? 12
                                                    : isTablet
                                                    ? 18
                                                    : 16,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                            ),
                                            child: Text(
                                              'Afficher tous les produits',
                                              style: TextStyle(
                                                fontSize: isSmallPhone
                                                    ? 12
                                                    : isTablet
                                                    ? 18
                                                    : 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : AnimationLimiter(
                                child: GridView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                    isSmallPhone ? 8 : 16,
                                    isSmallPhone ? 4 : 12,
                                    isSmallPhone ? 8 : 16,
                                    isSmallPhone ? 80 : 100,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: crossSpacing,
                                        mainAxisSpacing: mainSpacing,
                                        childAspectRatio: childAspectRatio,
                                      ),
                                  itemCount: _displayedProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = _displayedProducts[index];
                                    return AnimationConfiguration.staggeredGrid(
                                      position: index,
                                      duration: Duration(milliseconds: 500),
                                      columnCount: crossAxisCount,
                                      child: ScaleAnimation(
                                        child: FadeInAnimation(
                                          child: _buildProductCard(
                                            context,
                                            product,
                                            isSmallPhone: isSmallPhone,
                                            isTablet: isTablet,
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

          _buildFloatingFilterBar(),

          if (!_showFloatingFilter && _allProducts.isNotEmpty)
            Positioned(
              bottom: isSmallPhone ? 16 : 20,
              right: isSmallPhone ? 16 : 20,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _showFloatingFilter = true;
                  });
                },
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 8,
                child: Icon(Icons.filter_list, size: isSmallPhone ? 24 : 28),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductSearch product, {
    bool isSmallPhone = false,
    bool isTablet = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallPhone ? 14 : 20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: isSmallPhone ? 8 : 15,
            offset: Offset(0, isSmallPhone ? 3 : 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isSmallPhone ? 14 : 20),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(isSmallPhone ? 14 : 20),
          onTap: () => _showProductDetailsDialog(context, product),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: isSmallPhone
                    ? screenWidth * 0.25
                    : isTablet
                    ? screenWidth * 0.12
                    : screenWidth * 0.3,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isSmallPhone ? 14 : 20),
                    topRight: Radius.circular(isSmallPhone ? 14 : 20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isSmallPhone ? 14 : 20),
                    topRight: Radius.circular(isSmallPhone ? 14 : 20),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.shopping_bag,
                              size: isSmallPhone
                                  ? 24
                                  : isTablet
                                  ? 50
                                  : 40,
                              color: primaryColor.withOpacity(0.5),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.shopping_bag,
                            size: isSmallPhone
                                ? 24
                                : isTablet
                                ? 50
                                : 40,
                            color: primaryColor.withOpacity(0.5),
                          ),
                        ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isSmallPhone ? 6 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallPhone
                                ? 10
                                : isTablet
                                ? 16
                                : 14,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallPhone ? 4 : 8,
                          vertical: isSmallPhone ? 1 : 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              product.category == 'Ménager'
                                  ? Color(0xFF29B6F6)
                                  : accentColor,
                              product.category == 'Ménager'
                                  ? Color(0xFF0277BD)
                                  : primaryColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            isSmallPhone ? 4 : 8,
                          ),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            fontSize: isSmallPhone
                                ? 8
                                : isTablet
                                ? 14
                                : 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '${product.price} frs',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallPhone
                                    ? 12
                                    : isTablet
                                    ? 18
                                    : 16,
                                color: primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(isSmallPhone ? 3 : 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shopping_cart,
                              size: isSmallPhone
                                  ? 12
                                  : isTablet
                                  ? 20
                                  : 16,
                              color: primaryColor,
                            ),
                          ),
                        ],
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
