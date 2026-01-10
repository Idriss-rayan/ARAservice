import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class PressingPage extends StatefulWidget {
  final String categoryName;
  const PressingPage({super.key, required this.categoryName});

  @override
  State<PressingPage> createState() => _PressingAdminPageState();
}

class _PressingAdminPageState extends State<PressingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  String? _userName;

  int _selectedServiceIndex = 0;
  final Map<String, int> _cart = {};
  bool _showPromo = true;

  List<String> _subcategories = [];
  Map<String, List<Map<String, dynamic>>> _services = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadServices();
  }

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = _auth.currentUser;
      if (_currentUser != null) {
        _userName = _currentUser!.displayName;
        setState(() {});
        print('Nom utilisateur récupéré: $_userName');
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }

  Future<void> _loadServices() async {
    try {
      final servicesSnapshot = await _firestore
          .collection('categories')
          .doc(widget.categoryName)
          .collection('services')
          .get();

      _subcategories = servicesSnapshot.docs.map((e) => e.id).toList();

      _services = {};
      for (final serviceName in _subcategories) {
        final itemsSnapshot = await _firestore
            .collection('categories')
            .doc(widget.categoryName)
            .collection('services')
            .doc(serviceName)
            .collection('items')
            .get();

        _services[serviceName] = itemsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'name': data['name'] ?? 'Sans nom',
            'price': (data['price'] as num?)?.toDouble() ?? 0.0,
            'duration': data['duration'] ?? 'Non spécifié',
            'id': doc.id,
          };
        }).toList();
      }

      setState(() {});
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      _subcategories = ['Nettoyage à sec', 'Repassage', 'Retouches'];
      _services = {
        'Nettoyage à sec': [
          {'name': 'Costume complet', 'price': 25.99, 'duration': '24h'},
          {'name': 'Robe de soirée', 'price': 34.99, 'duration': '48h'},
        ],
        'Repassage': [
          {'name': 'Chemise homme', 'price': 5.99, 'duration': '12h'},
          {'name': 'Pantalon droit', 'price': 6.99, 'duration': '12h'},
        ],
        'Retouches': [
          {'name': 'Ourlet pantalon', 'price': 9.99, 'duration': '48h'},
          {'name': 'Fermeture éclair', 'price': 14.99, 'duration': '24h'},
        ],
      };
      setState(() {});
    }
  }

  Future<void> _sendToWhatsApp() async {
    try {
      String userName = _userName ?? 'Client';

      String message = '🛒 *COMMANDE PRESSING* 🛒\n\n';
      message += '*Client:* $userName\n';
      message += '*Date:* ${DateTime.now().toString().split(' ')[0]}\n';
      message += '*Service:* ${widget.categoryName}\n\n';
      message += '*📋 Détails de la commande:*\n';

      double total = 0;
      int itemCount = 0;

      for (var entry in _cart.entries) {
        final parts = entry.key.split(' - ');
        final serviceName = parts[0];
        final itemName = parts[1];

        final item = _services[serviceName]?.firstWhere(
          (item) => item['name'] == itemName,
          orElse: () => {'price': 0.0, 'duration': ''},
        );

        double price = (item?['price'] ?? 0.0) as double;
        double itemTotal = price * entry.value;
        total += itemTotal;
        itemCount += entry.value;

        message += '• ${entry.value}x $itemName\n';
        message += '  Prix unitaire: ${price} fr\n';
        message += '  Durée: ${item?['duration']}\n';
        message += '  Sous-total: ${itemTotal.toStringAsFixed(2)} fr\n\n';
      }

      message += '*📊 Récapitulatif:*\n';
      message += 'Articles: $itemCount\n';
      message += 'Total: ${total.toStringAsFixed(2)} fr\n';

      if (_showPromo) {
        double promoPrice = total * 0.8;
        message += 'Promotion -20%: ${promoPrice.toStringAsFixed(2)} fr\n';
        message += '*💰 Prix final: ${promoPrice.toStringAsFixed(2)} fr*';
      } else {
        message += '*💰 Prix final: ${total.toStringAsFixed(2)} fr*';
      }

      message += '\n\n📍 *Informations de livraison:*\n';
      message += '• Collecte à domicile sous 24h\n';
      message += '• Livraison en 24-48h\n';
      message += '• Paiement à la livraison\n\n';
      message += 'Merci pour votre confiance ! 🎉';

      print('Message WhatsApp prêt à être envoyé:\n$message');

      await Share.share(
        message,
        subject: 'Commande Pressing - $userName',
        sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
      );

      print('Message partagé avec succès!');
    } catch (e) {
      print('Erreur lors de l\'envoi vers WhatsApp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur d\'envoi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _validateOrder(BuildContext context) {
    _sendToWhatsApp()
        .then((_) {
          _showConfirmationDialog(context);
        })
        .catchError((error) {
          print('Erreur WhatsApp mais confirmation montrée: $error');
          _showConfirmationDialog(context);
        });
  }

  void _showConfirmationDialog(BuildContext context) {
    String userName = _userName ?? 'Client';

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.05),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [Color(0xFF00695C), Color(0xFF4DB6AC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: screenWidth * 0.1,
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                Text(
                  'Commande confirmée !',
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenWidth * 0.03),
                Text(
                  'Merci $userName ! Votre commande a été envoyée sur WhatsApp.\n\nVotre pressing sera collecté sous 24h.',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenWidth * 0.04),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone,
                        color: const Color(0xFF25D366),
                        size: screenWidth * 0.06,
                      ),
                      SizedBox(width: screenWidth * 0.025),
                      Text(
                        'Commande envoyée sur WhatsApp',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _cart.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00695C),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenWidth * 0.04,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Parfait !',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addToCart(String serviceName, String itemName, double price) {
    setState(() {
      final key = '$serviceName - $itemName';
      _cart[key] = (_cart[key] ?? 0) + 1;
    });
  }

  void _removeFromCart(String key) {
    setState(() {
      if (_cart[key] != null && _cart[key]! > 1) {
        _cart[key] = _cart[key]! - 1;
      } else {
        _cart.remove(key);
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    for (var entry in _cart.entries) {
      final parts = entry.key.split(' - ');
      final serviceName = parts[0];
      final itemName = parts[1];

      final item = _services[serviceName]?.firstWhere(
        (item) => item['name'] == itemName,
        orElse: () => {'price': 0.0},
      );

      total += ((item?['price'] ?? 0.0) as double) * entry.value;
    }
    return total;
  }

  int _getTotalItems() {
    return _cart.values.fold(0, (sum, count) => sum + count);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;

    if (_subcategories.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FDFF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF00695C),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                'Chargement des services...',
                style: TextStyle(
                  color: const Color(0xFF00695C),
                  fontSize: screenWidth * 0.045,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentService = _subcategories[_selectedServiceIndex];
    final items = _services[currentService] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFF),
      body: Column(
        children: [
          Container(
            height: screenHeight * 0.28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color(0xFF00695C),
                  Color(0xFF00796B),
                  Color(0xFF4DB6AC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00695C).withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -screenWidth * 0.1,
                  right: -screenWidth * 0.08,
                  child: Container(
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),

                Positioned(
                  bottom: -screenWidth * 0.08,
                  left: -screenWidth * 0.05,
                  child: Container(
                    width: screenWidth * 0.25,
                    height: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.06,
                    left: screenWidth * 0.05,
                    right: screenWidth * 0.05,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              width: screenWidth * 0.11,
                              height: screenWidth * 0.11,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: screenWidth * 0.05,
                              ),
                            ),
                          ).animate().scale(duration: 300.ms),

                          if (_showPromo)
                            GestureDetector(
                                  onTap: () =>
                                      setState(() => _showPromo = false),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04,
                                      vertical: screenWidth * 0.025,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFFF9800),
                                          const Color(0xFFFF5722),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFFF5722,
                                          ).withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.local_offer_rounded,
                                          color: Colors.white,
                                          size: screenWidth * 0.04,
                                        ),
                                        SizedBox(width: screenWidth * 0.015),
                                        Text(
                                          '-20%',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: screenWidth * 0.035,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        Text(
                                          '1ère commande',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontSize: screenWidth * 0.03,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .animate()
                                .slideX(begin: 0.3, duration: 500.ms)
                                .fadeIn(),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.025),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.categoryName,
                            style: TextStyle(
                              fontSize: screenWidth * 0.08,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: screenHeight * 0.1,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.015,
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _subcategories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedServiceIndex == index;
                  final serviceName = _subcategories[index];

                  return Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.03),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedServiceIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: 300.ms,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.012,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: const [
                                    Color(0xFF00796B),
                                    Color(0xFF4DB6AC),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(25),
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.grey.shade300),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00796C,
                                    ).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getServiceIcon(serviceName),
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF00796C),
                              size: screenWidth * 0.05,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              serviceName,
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('🎯', 'Livraison\n24/48h'),
                        _buildStatCard('⭐', '4.9/5\nClients'),
                        _buildStatCard('🌿', 'Écologique\n& Bio'),
                        _buildStatCard('🏠', 'Collecte\nà domicile'),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentService,
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF00695C),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.007,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${items.length} options',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF00796B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cleaning_services_rounded,
                                  size: screenWidth * 0.15,
                                  color: Colors.grey.shade300,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  'Aucun article disponible',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final itemKey =
                                  '$currentService - ${item['name']}';
                              final quantity = _cart[itemKey] ?? 0;

                              return Container(
                                margin: EdgeInsets.only(
                                  bottom: screenHeight * 0.015,
                                ),
                                child: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.all(screenWidth * 0.04),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: screenWidth * 0.15,
                                          height: screenWidth * 0.15,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF00695C),
                                                const Color(0xFF4DB6AC),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF00695C,
                                                ).withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            _getItemIcon(item['name']),
                                            color: Colors.white,
                                            size: screenWidth * 0.07,
                                          ),
                                        ),

                                        SizedBox(width: screenWidth * 0.04),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['name'],
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(
                                                    0xFF00695C,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: screenHeight * 0.005,
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.timer_rounded,
                                                    size: screenWidth * 0.035,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth * 0.01,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      item['duration'],
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.03,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${item['price']} fr',
                                                    style: TextStyle(
                                                      fontSize:
                                                          screenWidth * 0.045,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(width: screenWidth * 0.03),

                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: quantity > 0
                                                ? LinearGradient(
                                                    colors: [
                                                      const Color(0xFF00695C),
                                                      const Color(0xFF4DB6AC),
                                                    ],
                                                  )
                                                : null,
                                            color: quantity > 0
                                                ? null
                                                : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              screenWidth * 0.06,
                                            ),
                                            border: Border.all(
                                              color: quantity > 0
                                                  ? Colors.transparent
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                          child: quantity > 0
                                              ? Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () =>
                                                          _removeFromCart(
                                                            itemKey,
                                                          ),
                                                      icon: Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                        size:
                                                            screenWidth * 0.05,
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          BoxConstraints(
                                                            minWidth:
                                                                screenWidth *
                                                                0.1,
                                                            minHeight:
                                                                screenWidth *
                                                                0.1,
                                                          ),
                                                    ),
                                                    Text(
                                                      '$quantity',
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () =>
                                                          _addToCart(
                                                            currentService,
                                                            item['name'],
                                                            item['price']
                                                                as double,
                                                          ),
                                                      icon: Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size:
                                                            screenWidth * 0.05,
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          BoxConstraints(
                                                            minWidth:
                                                                screenWidth *
                                                                0.1,
                                                            minHeight:
                                                                screenWidth *
                                                                0.1,
                                                          ),
                                                    ),
                                                  ],
                                                )
                                              : IconButton(
                                                  onPressed: () => _addToCart(
                                                    currentService,
                                                    item['name'],
                                                    item['price'] as double,
                                                  ),
                                                  icon: Icon(
                                                    Icons
                                                        .add_shopping_cart_rounded,
                                                    color: const Color(
                                                      0xFF00695C,
                                                    ),
                                                    size: screenWidth * 0.05,
                                                  ),
                                                  constraints: BoxConstraints(
                                                    minWidth: screenWidth * 0.1,
                                                    minHeight:
                                                        screenWidth * 0.1,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).animate().fadeIn(delay: (index * 100 + 400).ms),
                              );
                            },
                          ),
                  ),

                  if (_cart.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(
                        top: screenHeight * 0.015,
                        bottom: screenHeight * 0.02,
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: const [Color(0xFF00695C), Color(0xFF00796B)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00695C).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
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
                                    '${_getTotalItems()} article${_getTotalItems() > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${_calculateTotal().toStringAsFixed(2)} fr',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.07,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (_showPromo)
                                    Text(
                                      'Avec promo: ${(_calculateTotal() * 0.8).toStringAsFixed(2)} fr',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _showOrderSummary(context),
                                icon: Icon(
                                  Icons.shopping_bag_rounded,
                                  size: screenWidth * 0.05,
                                ),
                                label: Text(
                                  'Commander',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF00695C),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.05,
                                    vertical: screenHeight * 0.015,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                            ],
                          ),
                          if (screenWidth < 400) // Pour les très petits écrans
                            SizedBox(height: screenHeight * 0.01),
                        ],
                      ),
                    ).animate().slideY(begin: 0.5, duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String text) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: screenWidth * 0.06)),
        SizedBox(height: screenWidth * 0.01),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth * 0.028,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF00695C),
          ),
        ),
      ],
    );
  }

  IconData _getServiceIcon(String serviceName) {
    if (serviceName.contains('Nettoyage') ||
        serviceName.contains('nettoyage')) {
      return Icons.cleaning_services_rounded;
    }
    if (serviceName.contains('Repassage') ||
        serviceName.contains('repassage')) {
      return Icons.iron_rounded;
    }
    if (serviceName.contains('Retouch') || serviceName.contains('retouch')) {
      return Icons.content_cut_rounded;
    }
    return Icons.local_laundry_service_rounded;
  }

  IconData _getItemIcon(String itemName) {
    if (itemName.contains('Costume') || itemName.contains('costume')) {
      return Icons.work_rounded;
    }
    if (itemName.contains('Robe') || itemName.contains('robe')) {
      return Icons.checkroom_rounded;
    }
    if (itemName.contains('Manteau') || itemName.contains('manteau')) {
      return Icons.ac_unit_rounded;
    }
    if (itemName.contains('Chemise') || itemName.contains('chemise')) {
      return Icons.man_rounded;
    }
    if (itemName.contains('Pantalon') || itemName.contains('pantalon')) {
      return Icons.dry_cleaning_rounded;
    }
    if (itemName.contains('Nappe') || itemName.contains('nappe')) {
      return Icons.restaurant_rounded;
    }
    return Icons.local_laundry_service_rounded;
  }

  void _showOrderSummary(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                width: screenWidth * 0.1,
                height: screenHeight * 0.005,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Column(
                  children: [
                    Text(
                      'Récapitulatif',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF00695C),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    ..._cart.entries.map((entry) {
                      final parts = entry.key.split(' - ');
                      final serviceName = parts[0];
                      final itemName = parts[1];

                      final item = _services[serviceName]?.firstWhere(
                        (item) => item['name'] == itemName,
                      );

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: screenWidth * 0.1,
                          height: screenWidth * 0.1,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getItemIcon(itemName),
                            color: const Color(0xFF00695C),
                            size: screenWidth * 0.05,
                          ),
                        ),
                        title: Text(
                          itemName,
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                        subtitle: Text(
                          '${item?['duration']} • ${item?['price']} fr/unité',
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ),
                        trailing: Text(
                          '${entry.value} × ${item?['price']} fr',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00695C),
                          ),
                        ),
                      );
                    }),

                    Divider(height: screenHeight * 0.03),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_calculateTotal().toStringAsFixed(2)} fr',
                              style: TextStyle(
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF00695C),
                              ),
                            ),
                            if (_showPromo)
                              Text(
                                'Promo: ${(_calculateTotal() * 0.8).toStringAsFixed(2)} fr',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF00695C)),
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Continuer',
                              style: TextStyle(
                                color: const Color(0xFF00695C),
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _validateOrder(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00695C),
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              'Valider & Envoyer',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF25D366).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFF25D366),
                            size: screenWidth * 0.045,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: Text(
                              'La commande sera envoyée sur WhatsApp',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: const Color(0xFF25D366),
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
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }
}
