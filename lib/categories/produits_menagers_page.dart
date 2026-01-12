import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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

  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showCartBadge = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
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
      _showCartBadge = true;
    });

    if (wasEmpty) {
      _animationController.forward(from: 0);
    }

    _showSnackBar(
      '${product['name']} ajouté au panier',
      Icons.check_circle,
      const Color(0xFF004D40),
    );

    // Cacher le badge après 2 secondes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showCartBadge = false;
        });
      }
    });
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

  // Fonction pour afficher le dialog de finalisation
  Future<void> _showCheckoutDialog() async {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        int currentStep = 0;
        final steps = ['Panier', 'Informations', 'Confirmation'];

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(screenWidth * 0.04),
              child: Container(
                height: screenHeight * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header avec étapes
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF006064),
                            const Color(0xFF00838F),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: screenWidth * 0.05,
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Text(
                                  'Finaliser la commande',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03,
                                  vertical: screenWidth * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_cart.length} article${_cart.length > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Étapes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: steps.asMap().entries.map((entry) {
                              final index = entry.key;
                              final step = entry.value;
                              final isActive = index == currentStep;
                              final isCompleted = index < currentStep;

                              return Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        if (index > 0)
                                          Expanded(
                                            child: Container(
                                              height: 2,
                                              color: isCompleted || isActive
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(
                                                      0.3,
                                                    ),
                                            ),
                                          ),
                                        Container(
                                          width: screenWidth * 0.07,
                                          height: screenWidth * 0.07,
                                          decoration: BoxDecoration(
                                            color: isCompleted
                                                ? Colors.white
                                                : isActive
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: isCompleted
                                                ? Icon(
                                                    Icons.check,
                                                    color: const Color(
                                                      0xFF006064,
                                                    ),
                                                    size: screenWidth * 0.04,
                                                  )
                                                : Text(
                                                    '${index + 1}',
                                                    style: TextStyle(
                                                      color: isActive
                                                          ? const Color(
                                                              0xFF006064,
                                                            )
                                                          : Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth * 0.035,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        if (index < steps.length - 1)
                                          Expanded(
                                            child: Container(
                                              height: 2,
                                              color: isCompleted
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(
                                                      0.3,
                                                    ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Text(
                                      step,
                                      style: TextStyle(
                                        color: isActive || isCompleted
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.6),
                                        fontSize: screenWidth * 0.03,
                                        fontWeight: isActive
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Contenu des étapes
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: currentStep == 0
                            ? _buildCartStep(setStateDialog)
                            : currentStep == 1
                            ? _buildInfoStep(setStateDialog)
                            : _buildConfirmationStep(),
                      ),
                    ),

                    // Boutons de navigation
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(25),
                        ),
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (currentStep > 0)
                            Expanded(
                              child: SizedBox(
                                height: screenHeight * 0.06,
                                child: OutlinedButton(
                                  onPressed: () {
                                    setStateDialog(() {
                                      currentStep--;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: const Color(0xFF006064),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back,
                                        size: screenWidth * 0.04,
                                        color: const Color(0xFF006064),
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(
                                        'Précédent',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.038,
                                          color: const Color(0xFF006064),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (currentStep > 0)
                            SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: SizedBox(
                              height: screenHeight * 0.06,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (currentStep < steps.length - 1) {
                                    setStateDialog(() {
                                      currentStep++;
                                    });
                                  } else {
                                    _sendOrderToWhatsApp();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: screenWidth * 0.05,
                                        height: screenWidth * 0.05,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (currentStep == steps.length - 1)
                                            Icon(
                                              Icons.phone,
                                              size: screenWidth * 0.05,
                                            ),
                                          SizedBox(width: screenWidth * 0.02),
                                          Text(
                                            currentStep == steps.length - 1
                                                ? 'WhatsApp'
                                                : 'Suivant',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.038,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (currentStep < steps.length - 1)
                                            Icon(
                                              Icons.arrow_forward,
                                              size: screenWidth * 0.04,
                                            ),
                                        ],
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
          },
        );
      },
    );
  }

  Widget _buildCartStep(StateSetter setStateDialog) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Expanded(
          child: _cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.grey[300],
                        size: screenWidth * 0.2,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'Votre panier est vide',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Ajoutez des produits pour continuer',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _cart.length,
                  itemBuilder: (context, index) {
                    final entry = _cart.entries.elementAt(index);
                    final id = entry.key;
                    final item = entry.value;

                    return Dismissible(
                      key: Key(id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: screenWidth * 0.05),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: screenWidth * 0.06,
                        ),
                      ),
                      onDismissed: (direction) {
                        setStateDialog(() {
                          _cart.remove(id);
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: screenHeight * 0.01),
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: screenWidth * 0.15,
                              height: screenWidth * 0.15,
                              decoration: BoxDecoration(
                                color: const Color(0xFF006064).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.cleaning_services_rounded,
                                color: const Color(0xFF006064),
                                size: screenWidth * 0.06,
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
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenWidth * 0.038,
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
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setStateDialog(() {
                                      if (item['quantity'] > 1) {
                                        _cart[id]!['quantity']--;
                                      } else {
                                        _cart.remove(id);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(screenWidth * 0.02),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: screenWidth * 0.04,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  '${item['quantity']}',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF006064),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                GestureDetector(
                                  onTap: () {
                                    setStateDialog(() {
                                      _cart[id]!['quantity']++;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(screenWidth * 0.02),
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
                                      Icons.add,
                                      size: screenWidth * 0.04,
                                      color: Colors.white,
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
                ),
        ),
        if (_cart.isNotEmpty)
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F9),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE0F2F1), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    color: const Color(0xFF006064),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoStep(StateSetter setStateDialog) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListView(
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
        SizedBox(height: screenHeight * 0.03),
        Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7F9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE0F2F1), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF006064),
                    size: screenWidth * 0.05,
                  ),
                  SizedBox(width: screenWidth * 0.025),
                  Text(
                    'Information',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF006064),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Votre commande sera envoyée via WhatsApp. Assurez-vous que votre numéro est correct.',
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: const Color(0xFF25D366),
            size: screenWidth * 0.15,
          ),
          SizedBox(height: screenHeight * 0.03),
          Text(
            'Récapitulatif',
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF006064),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F9),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE0F2F1), width: 2),
            ),
            child: Column(
              children: [
                ..._cart.entries.map((entry) {
                  final item = entry.value;
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.01,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['name'],
                            style: TextStyle(fontSize: screenWidth * 0.038),
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
                        color: const Color(0xFF006064),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF25D366).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: const Color(0xFF25D366),
                      size: screenWidth * 0.06,
                    ),
                    SizedBox(width: screenWidth * 0.025),
                    Text(
                      'Envoi via WhatsApp',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF25D366),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Votre commande sera envoyée directement sur WhatsApp. Assurez-vous d\'avoir l\'application installée.',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required String id,
    required Map<String, dynamic> product,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final inCart = _cart[id];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _addToCart(id, product);
        },
        child: AnimationConfiguration.staggeredGrid(
          position: _cart.keys.toList().indexOf(id) + 1,
          columnCount: 2,
          duration: const Duration(milliseconds: 500),
          child: ScaleAnimation(
            scale: 0.5,
            child: FadeInAnimation(
              child: Container(
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
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Container(
                              color: const Color(0xFFF5F7F9),
                              child: product['image'] != null
                                  ? Image.network(
                                      product['image'] ?? defaultImageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
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
                          ),
                        ),
                        // Détails
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${product['price']?.toStringAsFixed(2) ?? ''}fr',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.038,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF006064),
                                    ),
                                  ),
                                  if (inCart != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.03,
                                        vertical: screenWidth * 0.01,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF006064),
                                            const Color(0xFF00838F),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${inCart['quantity']}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.03,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Overlay de sélection
                    if (inCart != null)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF006064).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF006064),
                            width: 2,
                          ),
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
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      floatingActionButton: _cart.isNotEmpty
          ? ScaleTransition(
              scale: _scaleAnimation,
              child: Stack(
                children: [
                  FloatingActionButton.extended(
                    onPressed: _showCheckoutDialog,
                    backgroundColor: const Color(0xFF006064),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    icon: Icon(
                      Icons.shopping_cart_checkout,
                      size: screenWidth * 0.06,
                    ),
                    label: Text(
                      'Panier (${_cart.length})',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_showCartBadge)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.015),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: screenWidth * 0.03,
                        ),
                      ),
                    ),
                ],
              ),
            )
          : null,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar élégant
          SliverAppBar(
            expandedHeight: screenHeight * 0.25,
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
                        SizedBox(height: screenHeight * 0.05),
                        Icon(
                          Icons.cleaning_services_rounded,
                          color: Colors.white,
                          size: screenWidth * 0.15,
                        ),
                        SizedBox(height: screenHeight * 0.01),
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
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          'Cliquez sur un produit pour l\'ajouter au panier',
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

          // Grille de produits
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isTablet ? 3 : 2,
                      mainAxisSpacing: screenWidth * 0.03,
                      crossAxisSpacing: screenWidth * 0.03,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final doc = items[index];
                      final product = doc.data() as Map<String, dynamic>;
                      return _buildProductCard(
                        id: doc.id,
                        product: product,
                        context: context,
                      );
                    }, childCount: items.length),
                  ),
                );
              },
            ),
          ),
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
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.01,
      ),
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
