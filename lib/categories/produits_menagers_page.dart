import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:share_plus/share_plus.dart';

class ProduitsMenagersPage extends StatefulWidget {
  const ProduitsMenagersPage({super.key});

  @override
  State<ProduitsMenagersPage> createState() => _ProduitsMenagersPageState();
}

class _ProduitsMenagersPageState extends State<ProduitsMenagersPage>
    with SingleTickerProviderStateMixin {
  final Map<String, Map<String, dynamic>> _cart = {};
  final CollectionReference productsRef = FirebaseFirestore.instance.collection(
    'produits_menagers',
  );

  static const String defaultImageUrl =
      'https://cdn-icons-png.flaticon.com/512/679/679720.png';

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _quartierController = TextEditingController();
  final _villeController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isShowingForm = false;
  bool _isLoading = false;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _quartierController.dispose();
    _villeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _addToCart(String id, Map<String, dynamic> product) {
    final wasEmpty = _cart.isEmpty;

    setState(() {
      _cart[id] = {...product, 'quantity': (_cart[id]?['quantity'] ?? 0) + 1};
    });

    if (wasEmpty) {
      _animationController.forward(from: 0);
    }

    _showSnackBar(
      '${product['name']} ajouté au panier',
      Icons.check_circle,
      const Color(0xFF004D40),
    );
  }

  void _removeFromCart(String id) {
    final productName = _cart[id]?['name'] ?? '';
    setState(() {
      if (_cart[id]!['quantity'] > 1) {
        _cart[id]!['quantity']--;
      } else {
        _cart.remove(id);
        _showSnackBar(
          '$productName retiré du panier',
          Icons.remove_shopping_cart,
          Colors.orange,
        );
      }
    });
  }

  void _showSnackBar(String message, IconData icon, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: screenWidth * 0.05),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }

  double _getTotalPrice() {
    double total = 0;
    for (var p in _cart.values) {
      total += (p['price'] as double) * (p['quantity'] as int);
    }
    return total;
  }

  Future<void> _sendOrderToWhatsApp() async {
    if (_cart.isEmpty) return;

    final fields = {
      'Nom': _nameController.text,
      'Prénom': _surnameController.text,
      'Téléphone': _phoneController.text,
      'Quartier': _quartierController.text,
      'Ville': _villeController.text,
    };

    for (var entry in fields.entries) {
      if (entry.value.isEmpty) {
        _showSnackBar(
          'Veuillez remplir le champ "${entry.key}"',
          Icons.warning,
          Colors.orange,
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    String message =
        '''
🛒 *COMMANDE DE PRODUITS MÉNAGERS* 🛒

📋 *Détails de la commande :*
${_cart.entries.map((e) => '${e.value['quantity']}x ${e.value['name']} - ${e.value['price']}fr').join('\n')}

💰 *Total : ${_getTotalPrice().toStringAsFixed(2)}fr*

👤 *Informations client :*
${fields.entries.map((e) => '${e.key} : ${e.value}').join('\n')}

📅 *Date :* ${DateTime.now().toLocal().toString().split('.')[0]}
''';

    // Remplacez <NUMERO> par votre numéro WhatsApp
    final url = Uri.parse(
      'https://wa.me/<NUMERO>?text=${Uri.encodeComponent(message)}',
    );

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showSnackBar('Erreur lors de l\'envoi', Icons.error, Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleForm() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: _isShowingForm
          ? _buildPersonalInfoForm()
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                // AppBar avec dégradé bleu élégant
                SliverAppBar(
                  expandedHeight: screenHeight * 0.2,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF006064),
                            const Color(0xFF00838F),
                            const Color(0xFF0097A7),
                          ],
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: screenHeight * 0.04),
                              Text(
                                'PRODUITS MÉNAGERS',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: screenWidth * 0.008,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                'Nettoyage et entretien',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.white.withOpacity(0.95),
                                  letterSpacing: screenWidth * 0.005,
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Résumé du panier en bleu
                if (_cart.isNotEmpty)
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: Container(
                        height: screenHeight * 0.12,
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF006064).withOpacity(0.1),
                              blurRadius: 25,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: screenWidth * 0.15,
                                    height: screenWidth * 0.15,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF006064),
                                          const Color(0xFF00838F),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      Icons.shopping_cart_checkout,
                                      color: Colors.white,
                                      size: screenWidth * 0.07,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${_cart.length} article${_cart.length > 1 ? 's' : ''}',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF006064),
                                        ),
                                      ),
                                      Text(
                                        '${_cart.values.fold<int>(0, (sum, item) => sum + (item['quantity'] as int))} unités',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          color: const Color(
                                            0xFF006064,
                                          ).withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${_getTotalPrice().toStringAsFixed(2)}fr',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.055,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF006064),
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

                // Grille de produits avec animations en cascade
                SliverPadding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  sliver: StreamBuilder<QuerySnapshot>(
                    stream: productsRef
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SliverFillRemaining(
                          child: Center(
                            child: SizedBox(
                              width: screenWidth * 0.15,
                              height: screenWidth * 0.15,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation(
                                  const Color(0xFF006064),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.grey.shade400,
                                  size: screenWidth * 0.15,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  'Erreur de chargement',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: screenWidth * 0.04,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final items = snapshot.data?.docs ?? [];
                      if (items.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cleaning_services_outlined,
                                  color: Colors.grey.shade300,
                                  size: screenWidth * 0.2,
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                Text(
                                  'Aucun produit disponible',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: screenWidth * 0.045,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  'Revenez plus tard',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return AnimationLimiter(
                        child: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isTablet ? 3 : 2,
                                mainAxisSpacing: screenWidth * 0.03,
                                crossAxisSpacing: screenWidth * 0.03,
                                childAspectRatio: 0.75,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final doc = items[index];
                            final product = doc.data() as Map<String, dynamic>;
                            final inCart = _cart[doc.id];
                            return _buildProductCard(
                              id: doc.id,
                              product: product,
                              inCart: inCart,
                              context: context,
                            );
                          }, childCount: items.length),
                        ),
                      );
                    },
                  ),
                ),

                // Bouton flottant pour le formulaire en bleu
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                      height: _isExpanded ? null : screenHeight * 0.08,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF006064).withOpacity(0.1),
                            blurRadius: 30,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Bouton d'expansion en bleu
                          Container(
                            height: screenHeight * 0.08,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF006064),
                                  const Color(0xFF00838F),
                                  const Color(0xFF0097A7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                              child: InkWell(
                                onTap: _toggleForm,
                                borderRadius: BorderRadius.circular(25),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.05,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.shopping_bag_rounded,
                                            color: Colors.white,
                                            size: screenWidth * 0.055,
                                          ),
                                          SizedBox(width: screenWidth * 0.03),
                                          Text(
                                            'Finaliser la commande',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenWidth * 0.04,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      AnimatedRotation(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        turns: _isExpanded ? 0.5 : 0,
                                        child: Icon(
                                          Icons.expand_more,
                                          color: Colors.white,
                                          size: screenWidth * 0.07,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Formulaire avec animation d'expansion
                          if (_isExpanded)
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.05),
                              child: Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.02),
                                  _buildFormSection(
                                    title: 'Informations personnelles',
                                    icon: Icons.person_outline,
                                    children: [
                                      _buildInputField(
                                        controller: _surnameController,
                                        label: 'Prénom',
                                        icon: Icons.person,
                                      ),
                                      SizedBox(height: screenHeight * 0.015),
                                      _buildInputField(
                                        controller: _nameController,
                                        label: 'Nom',
                                        icon: Icons.person,
                                      ),
                                      SizedBox(height: screenHeight * 0.015),
                                      _buildInputField(
                                        controller: _phoneController,
                                        label: 'Téléphone',
                                        icon: Icons.phone,
                                        keyboardType: TextInputType.phone,
                                      ),
                                      SizedBox(height: screenHeight * 0.015),
                                      _buildInputField(
                                        controller: _quartierController,
                                        label: 'Quartier',
                                        icon: Icons.location_city,
                                      ),
                                      SizedBox(height: screenHeight * 0.015),
                                      _buildInputField(
                                        controller: _villeController,
                                        label: 'Ville',
                                        icon: Icons.place,
                                      ),
                                    ],
                                    context: context,
                                  ),
                                  SizedBox(height: screenHeight * 0.03),

                                  // Récapitulatif de la commande
                                  if (_cart.isNotEmpty)
                                    Container(
                                      padding: EdgeInsets.all(
                                        screenWidth * 0.04,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F7F9),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFE0F2F1),
                                          width: 2,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.receipt_long,
                                                color: const Color(0xFF006064),
                                                size: screenWidth * 0.055,
                                              ),
                                              SizedBox(
                                                width: screenWidth * 0.025,
                                              ),
                                              Text(
                                                'Récapitulatif de commande',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(
                                                    0xFF006064,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: screenHeight * 0.02),
                                          ..._cart.entries.map((entry) {
                                            final item = entry.value;
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: screenHeight * 0.01,
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: screenWidth * 0.1,
                                                    height: screenWidth * 0.1,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      color: const Color(
                                                        0xFF006064,
                                                      ).withOpacity(0.1),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .cleaning_services_rounded,
                                                      color: const Color(
                                                        0xFF006064,
                                                      ),
                                                      size: screenWidth * 0.05,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth * 0.03,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          item['name'],
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize:
                                                                screenWidth *
                                                                0.035,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${item['price']}fr / unité',
                                                          style: TextStyle(
                                                            fontSize:
                                                                screenWidth *
                                                                0.03,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    '${item['quantity']}x',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.035,
                                                      color: const Color(
                                                        0xFF006064,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth * 0.03,
                                                  ),
                                                  Text(
                                                    '${(item['price'] * item['quantity']).toStringAsFixed(2)}fr',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.035,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          Divider(height: screenHeight * 0.03),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Total',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.045,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                '${_getTotalPrice().toStringAsFixed(2)}fr',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.055,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(
                                                    0xFF006064,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                  SizedBox(height: screenHeight * 0.03),
                                  SizedBox(
                                    width: double.infinity,
                                    height: screenHeight * 0.07,
                                    child: ElevatedButton(
                                      onPressed: _sendOrderToWhatsApp,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF25D366,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        elevation: 5,
                                        shadowColor: const Color(
                                          0xFF25D366,
                                        ).withOpacity(0.4),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              width: screenWidth * 0.06,
                                              height: screenWidth * 0.06,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.phone,
                                                  size: screenWidth * 0.06,
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.03,
                                                ),
                                                Text(
                                                  'Commander via WhatsApp',
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.04,
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPersonalInfoForm() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return CustomScrollView(
      slivers: [
        // AppBar avec bouton retour
        SliverAppBar(
          expandedHeight: screenHeight * 0.15,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF006064), const Color(0xFF00838F)],
                ),
              ),
            ),
            title: Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isShowingForm = false;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Informations personnelles',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ],
            ),
            titlePadding: EdgeInsets.zero,
            centerTitle: false,
          ),
        ),

        // Formulaire détaillé
        SliverPadding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildFormSection(
                title: 'Coordonnées',
                icon: Icons.contact_page_outlined,
                children: [
                  _buildInputField(
                    controller: _surnameController,
                    label: 'Prénom',
                    icon: Icons.person,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildInputField(
                    controller: _nameController,
                    label: 'Nom',
                    icon: Icons.person,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildInputField(
                    controller: _phoneController,
                    label: 'Téléphone',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildInputField(
                    controller: _quartierController,
                    label: 'Quartier',
                    icon: Icons.location_city,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildInputField(
                    controller: _villeController,
                    label: 'Ville',
                    icon: Icons.place,
                  ),
                ],
                context: context,
              ),
              SizedBox(height: screenHeight * 0.03),

              // Récapitulatif de la commande
              if (_cart.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF006064).withOpacity(0.1),
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
                          Icon(
                            Icons.shopping_cart_checkout,
                            color: const Color(0xFF006064),
                            size: screenWidth * 0.055,
                          ),
                          SizedBox(width: screenWidth * 0.025),
                          Text(
                            'Votre commande',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF006064),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      ..._cart.entries.map((entry) {
                        final item = entry.value;
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: screenWidth * 0.1,
                                height: screenWidth * 0.1,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(
                                    0xFF006064,
                                  ).withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.cleaning_services_rounded,
                                  color: const Color(0xFF006064),
                                  size: screenWidth * 0.05,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: screenWidth * 0.035,
                                      ),
                                    ),
                                    Text(
                                      '${item['price']}fr / unité',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${item['quantity']}x',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.035,
                                  color: const Color(0xFF006064),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Text(
                                '${(item['price'] * item['quantity']).toStringAsFixed(2)}fr',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      Divider(height: screenHeight * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total à payer',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${_getTotalPrice().toStringAsFixed(2)}fr',
                            style: TextStyle(
                              fontSize: screenWidth * 0.055,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF006064),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              SizedBox(height: screenHeight * 0.04),

              // Bouton d'envoi
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.07,
                child: ElevatedButton(
                  onPressed: _sendOrderToWhatsApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF25D366).withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: screenWidth * 0.06,
                          height: screenWidth * 0.06,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: screenWidth * 0.06),
                            SizedBox(width: screenWidth * 0.03),
                            Text(
                              'Envoyer la commande',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required String id,
    required Map<String, dynamic> product,
    required Map<String, dynamic>? inCart,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006064).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec effet de superposition
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  Container(
                    color: const Color(0xFFF5F7F9),
                    child: product['image'] != null
                        ? Image.network(
                            product['image'] ?? defaultImageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: const Color(0xFF006064),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.cleaning_services_rounded,
                              color: Colors.grey.shade400,
                              size: screenWidth * 0.1,
                            ),
                          ),
                  ),
                  // Overlay gradient bleu
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF006064).withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Badge de quantité si dans le panier
                  if (inCart != null)
                    Positioned(
                      top: screenWidth * 0.03,
                      right: screenWidth * 0.03,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenWidth * 0.015,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF006064),
                              const Color(0xFF00838F),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF006064).withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          '${inCart['quantity']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Détails du produit
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: screenWidth * 0.038,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF006064),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  product['description'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: screenWidth * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Prix réduit
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${product['price']?.toStringAsFixed(2) ?? ''}fr',
                          style: TextStyle(
                            fontSize: screenWidth * 0.033,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF006064),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Prix',
                          style: TextStyle(
                            fontSize: screenWidth * 0.025,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),

                    // Contrôle de quantité ultra compact
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.005,
                        vertical: screenWidth * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: inCart == null
                            ? Colors.transparent
                            : const Color(0xFF006064).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: inCart == null
                              ? Colors.transparent
                              : const Color(0xFF006064),
                          width: inCart == null ? 0 : 1.0,
                        ),
                      ),
                      child: inCart == null
                          ? GestureDetector(
                              onTap: () => _addToCart(id, product),
                              child: Container(
                                padding: EdgeInsets.all(screenWidth * 0.015),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF006064),
                                      const Color(0xFF00838F),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add_shopping_cart_rounded,
                                  color: Colors.white,
                                  size: screenWidth * 0.035,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => _removeFromCart(id),
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      screenWidth * 0.005,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF006064,
                                      ).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.remove_rounded,
                                      size: screenWidth * 0.03,
                                      color: const Color(
                                        0xFF006064,
                                      ).withOpacity(0.8),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.01,
                                  ),
                                  child: Text(
                                    '${inCart['quantity']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.03,
                                      color: const Color(0xFF006064),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () => _addToCart(id, product),
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      screenWidth * 0.005,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF006064),
                                          const Color(0xFF00838F),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: screenWidth * 0.03,
                                      color: Colors.white,
                                    ),
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
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006064).withOpacity(0.1),
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
              Icon(
                icon,
                color: const Color(0xFF006064),
                size: screenWidth * 0.055,
              ),
              SizedBox(width: screenWidth * 0.025),
              Text(
                title,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF006064),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.05),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF5F7F9),
        border: Border.all(color: const Color(0xFFE0F2F1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: const Color(0xFF006064),
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: const Color(0xFF006064),
                  size: screenWidth * 0.05,
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.04,
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: TextStyle(
          fontSize: screenWidth * 0.038,
          color: const Color(0xFF006064),
          fontWeight: FontWeight.w500,
        ),
        cursorColor: const Color(0xFF006064),
      ),
    );
  }
}
