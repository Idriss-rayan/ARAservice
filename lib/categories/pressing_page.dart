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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Commande confirmée !',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Merci $userName ! Votre commande a été envoyée sur WhatsApp.\n\nVotre pressing sera collecté sous 24h.',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone,
                        color: Color(0xFF25D366),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Commande envoyée sur WhatsApp',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Parfait !',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
              const SizedBox(height: 20),
              Text(
                'Chargement des services...',
                style: TextStyle(color: const Color(0xFF00695C), fontSize: 16),
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
            height: 220,
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
                  top: -40,
                  right: -30,
                  child: Container(
                    width: 120,
                    height: 120,
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
                  bottom: -30,
                  left: -20,
                  child: Container(
                    width: 100,
                    height: 100,
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
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ).animate().scale(duration: 300.ms),

                          if (_showPromo)
                            GestureDetector(
                                  onTap: () =>
                                      setState(() => _showPromo = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
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
                                        const Icon(
                                          Icons.local_offer_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          '-20%',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '1ère commande',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontSize: 12,
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

                      const SizedBox(height: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.categoryName,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ).animate().fadeIn(delay: 200.ms),

                          const SizedBox(height: 6),

                          Text(
                            'Nettoyage professionnel & retouches expertes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ).animate().fadeIn(delay: 400.ms),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _subcategories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedServiceIndex == index;
                final serviceName = _subcategories[index];

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedServiceIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: 300.ms,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
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
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            serviceName,
                            style: TextStyle(
                              fontSize: 14,
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

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
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
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentService,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00695C),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${items.length} options',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00796B),
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
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aucun article disponible',
                                  style: TextStyle(
                                    fontSize: 16,
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
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Material(
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
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
                                            size: 28,
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['name'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF00695C),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.timer_rounded,
                                                    size: 14,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    item['duration'],
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    '${item['price']} fr',
                                                    style: const TextStyle(
                                                      fontSize: 20,
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

                                        const SizedBox(width: 12),

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
                                              25,
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
                                                      icon: const Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                    Text(
                                                      '$quantity',
                                                      style: const TextStyle(
                                                        fontSize: 16,
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
                                                      icon: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      padding: EdgeInsets.zero,
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
                                                    size: 20,
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
                      margin: const EdgeInsets.only(top: 16, bottom: 20),
                      padding: const EdgeInsets.all(20),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getTotalItems()} article${_getTotalItems() > 1 ? 's' : ''}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${_calculateTotal().toStringAsFixed(2)} fr',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              if (_showPromo)
                                Text(
                                  'Avec promo: ${(_calculateTotal() * 0.8).toStringAsFixed(2)} fr',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showOrderSummary(context),
                            icon: const Icon(
                              Icons.shopping_bag_rounded,
                              size: 20,
                            ),
                            label: const Text(
                              'Commander',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF00695C),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                          ),
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
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00695C),
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
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Récapitulatif',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00695C),
                      ),
                    ),

                    const SizedBox(height: 20),

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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getItemIcon(itemName),
                            color: const Color(0xFF00695C),
                            size: 20,
                          ),
                        ),
                        title: Text(itemName),
                        subtitle: Text(
                          '${item?['duration']} • ${item?['price']} fr/unité',
                        ),
                        trailing: Text(
                          '${entry.value} × ${item?['price']} fr',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF00695C),
                          ),
                        ),
                      );
                    }),

                    const Divider(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_calculateTotal().toStringAsFixed(2)} fr',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF00695C),
                              ),
                            ),
                            if (_showPromo)
                              Text(
                                'Promo: ${(_calculateTotal() * 0.8).toStringAsFixed(2)} fr',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF00695C)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Continuer',
                              style: TextStyle(
                                color: Color(0xFF00695C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _validateOrder(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00695C),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Valider & Envoyer',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF25D366).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF25D366),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'La commande sera envoyée sur WhatsApp',
                              style: TextStyle(
                                fontSize: 12,
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
            ],
          ),
        );
      },
    );
  }
}
