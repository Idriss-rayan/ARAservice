import 'package:araservice/services/firebase_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ModeConfectionPage extends StatefulWidget {
  final List<String> subcategories;
  const ModeConfectionPage({super.key, required this.subcategories});

  @override
  State<ModeConfectionPage> createState() => _ModeConfectionPageState();
}

class _ModeConfectionPageState extends State<ModeConfectionPage> {
  int _selectedCategoryIndex = 0;
  final Map<String, dynamic> _formData = {};
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  String _whatsappNumber = "8801894689397";

  // Pour gérer le scroll
  final ScrollController _scrollController = ScrollController();

  // Modèles de vêtements populaires
  final List<Map<String, dynamic>> _popularModels = [
    {
      'name': 'Boubou homme brodé',
      'category': 'Homme',
      'image': '👘',
      'description': 'Boubou traditionnel avec broderies artisanales',
      'price': '149.99€',
      'time': '10 jours',
    },
    {
      'name': 'Petit boubou',
      'category': 'Homme',
      'image': '👔',
      'description': 'Boubou léger pour occasions décontractées',
      'price': '89.99€',
      'time': '7 jours',
    },
    {
      'name': 'Ensemble tunique + pantalon',
      'category': 'Femme',
      'image': '👗',
      'description': 'Ensemble élégant en tissu wax',
      'price': '129.99€',
      'time': '8 jours',
    },
    {
      'name': 'Chemise wax + pantalon uni',
      'category': 'Homme',
      'image': '👕',
      'description': 'Tenue moderne mixant wax et tissu uni',
      'price': '119.99€',
      'time': '7 jours',
    },
    {
      'name': 'Tenue bazin homme',
      'category': 'Homme',
      'image': '🎩',
      'description': 'Tenue de cérémonie en bazin riche',
      'price': '199.99€',
      'time': '12 jours',
    },
    {
      'name': 'Costume africain modernisé',
      'category': 'Homme',
      'image': '🤵',
      'description': 'Costume mixant coupes modernes et tissus africains',
      'price': '229.99€',
      'time': '14 jours',
    },
    {
      'name': 'Robe longue wax',
      'category': 'Femme',
      'image': '💃',
      'description': 'Robe élégante en wax imprimé',
      'price': '139.99€',
      'time': '9 jours',
    },
    {
      'name': 'Robe pagne ajustée',
      'category': 'Femme',
      'image': '👚',
      'description': 'Robe ajustée mettant en valeur la silhouette',
      'price': '119.99€',
      'time': '8 jours',
    },
    {
      'name': 'Kaba (classique)',
      'category': 'Femme',
      'image': '🧥',
      'description': 'Kaba traditionnel avec motifs africains',
      'price': '159.99€',
      'time': '10 jours',
    },
    {
      'name': 'Kaba modernisée',
      'category': 'Femme',
      'image': '👘',
      'description': 'Kaba revisité avec coupes contemporaines',
      'price': '169.99€',
      'time': '11 jours',
    },
  ];

  // Vêtements prêt-à-porter
  final List<Map<String, dynamic>> _readyToWear = [
    {
      'name': 'Robe évasée (princesse)',
      'category': 'Femme',
      'image': '👗',
      'size': ['S', 'M', 'L', 'XL'],
      'price': '89.99€',
      'stock': 'En stock',
      'description':
          'Robe évasée avec coupe princesse, idéale pour les occasions spéciales',
    },
    {
      'name': 'Robe sirène',
      'category': 'Femme',
      'image': '🧜‍♀️',
      'size': ['S', 'M', 'L'],
      'price': '99.99€',
      'stock': 'En stock',
      'description':
          'Robe sirène élégante qui épouse parfaitement la silhouette',
    },
    {
      'name': 'Robe droite simple',
      'category': 'Femme',
      'image': '👚',
      'size': ['XS', 'S', 'M', 'L', 'XL'],
      'price': '69.99€',
      'stock': 'En stock',
      'description': 'Robe droite classique, parfaite pour le quotidien',
    },
    {
      'name': 'Robe wax fendue',
      'category': 'Femme',
      'image': '💃',
      'size': ['M', 'L', 'XL'],
      'price': '119.99€',
      'stock': 'En stock',
      'description': 'Robe en wax avec fente latérale élégante',
    },
    {
      'name': 'Ensemble deux-pièces wax',
      'category': 'Femme',
      'image': '👚👖',
      'size': ['S', 'M', 'L'],
      'price': '129.99€',
      'stock': 'En stock',
      'description': 'Ensemble coordonné en wax de qualité',
    },
    {
      'name': 'Robe manche bouffante',
      'category': 'Femme',
      'image': '👗',
      'size': ['S', 'M'],
      'price': '109.99€',
      'stock': 'En stock',
      'description': 'Robe romantique avec manches bouffantes',
    },
    {
      'name': 'Robe africaine de cérémonie',
      'category': 'Femme',
      'image': '👘',
      'size': ['M', 'L', 'XL'],
      'price': '179.99€',
      'stock': 'En stock',
      'description': 'Robe de cérémonie avec broderies traditionnelles',
    },
    {
      'name': 'Tenue mixte wax + tissu uni',
      'category': 'Mixte',
      'image': '👕👖',
      'size': ['S', 'M', 'L', 'XL'],
      'price': '149.99€',
      'stock': 'En stock',
      'description': 'Tenue élégante combinant wax et tissu uni',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialisation des données de mesure
    _formData['measurements'] = {
      'bust': '',
      'waist': '',
      'hips': '',
      'shoulder': '',
      'arm_length': '',
      'leg_length': '',
      'height': '',
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((file) => File(file.path)).toList());
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _sendToWhatsApp() async {
    final message = _generateWhatsAppMessage();

    try {
      // 1️⃣ CRÉER LA COMMANDE DANS FIRESTORE
      final orderService = OrderService();

      await orderService.createOrder(
        formData: _formData,
        categoryIndex: _selectedCategoryIndex,
        categories: widget.subcategories,
        imagesCount: _selectedImages.length,
        whatsappMessage: message,
      );

      // 2️⃣ OUVRIR WHATSAPP
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = "https://wa.me/$_whatsappNumber?text=$encodedMessage";

      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );

      // 3️⃣ RESET DU FORMULAIRE
      setState(() {
        _selectedImages.clear();
        _formData.clear();
        _formData['measurements'] = {
          'bust': '',
          'waist': '',
          'hips': '',
          'shoulder': '',
          'arm_length': '',
          'leg_length': '',
          'height': '',
        };
      });

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog("Erreur lors de l'envoi de la commande");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        title: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF25D366),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Message préparé !',
              style: TextStyle(
                color: Color(0xFF004D40),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'WhatsApp va s\'ouvrir avec votre message pré-rempli.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Étapes:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF004D40),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    const [
                          Text('1. Vérifiez le message dans WhatsApp'),
                          Text('2. Appuyez sur "Envoyer"'),
                          Text('3. Notre équipe vous contactera'),
                        ]
                        .map(
                          (text) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Text('• '),
                                Expanded(child: text),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Erreur',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _generateWhatsAppMessage() {
    final String category = widget.subcategories[_selectedCategoryIndex];
    String message = "📋 NOUVELLE DEMANDE - MODE & CONFECTION 📋\n\n";
    message += "📍 Catégorie: $category\n";
    message += "📅 Date: ${DateTime.now().toLocal()}\n\n";

    if (_selectedCategoryIndex == 0) {
      // Confection sur mesure
      message += "👕 MODÈLE CHOISI:\n";
      if (_formData['selected_model'] != null) {
        message += "• ${_formData['selected_model']['name']}\n";
        message +=
            "• Description: ${_formData['selected_model']['description']}\n";
      }
      message += "\n📏 MESURES DU CLIENT:\n";
      final measurements = _formData['measurements'] as Map<String, String>;
      measurements.forEach((key, value) {
        if (value.isNotEmpty) {
          message += "• ${_getMeasurementLabel(key)}: $value cm\n";
        }
      });
      if (_formData['additional_notes'] != null &&
          _formData['additional_notes'].isNotEmpty) {
        message +=
            "\n📝 NOTES SUPPLÉMENTAIRES:\n${_formData['additional_notes']}\n";
      }
    } else if (_selectedCategoryIndex == 1) {
      // Retouches
      message += "✂️ INFORMATIONS RETOUCHES:\n";
      if (_formData['clothing_type'] != null &&
          _formData['clothing_type'].isNotEmpty) {
        message += "• Type de vêtement: ${_formData['clothing_type']}\n";
      }
      if (_formData['modification_details'] != null &&
          _formData['modification_details'].isNotEmpty) {
        message +=
            "• Détails des modifications: ${_formData['modification_details']}\n";
      }
      if (_formData['urgency'] != null && _formData['urgency'].isNotEmpty) {
        message += "• Urgence: ${_formData['urgency']}\n";
      }
      if (_formData['additional_notes'] != null &&
          _formData['additional_notes'].isNotEmpty) {
        message +=
            "\n📝 NOTES SUPPLÉMENTAIRES:\n${_formData['additional_notes']}\n";
      }
      message += "\n🖼️ NOMBRE DE PHOTOS: ${_selectedImages.length}\n";
    } else {
      // Prêt-à-porter
      message += "🛒 COMMANDE PRÊT-À-PORTER:\n";
      if (_formData['selected_item'] != null) {
        message += "• Article: ${_formData['selected_item']['name']}\n";
        message += "• Taille: ${_formData['selected_size']}\n";
        message += "• Prix: ${_formData['selected_item']['price']}\n";
        message +=
            "• Description: ${_formData['selected_item']['description']}\n";
      }
      if (_formData['delivery_address'] != null &&
          _formData['delivery_address'].isNotEmpty) {
        message +=
            "\n🏠 ADRESSE DE LIVRAISON:\n${_formData['delivery_address']}\n";
      }
    }

    message += "\n📞 COORDONNÉES CLIENT:\n";
    if (_formData['customer_name'] != null &&
        _formData['customer_name'].isNotEmpty) {
      message += "• Nom: ${_formData['customer_name']}\n";
    }
    if (_formData['customer_phone'] != null &&
        _formData['customer_phone'].isNotEmpty) {
      message += "• Téléphone: ${_formData['customer_phone']}\n";
    }
    if (_formData['customer_email'] != null &&
        _formData['customer_email'].isNotEmpty) {
      message += "• Email: ${_formData['customer_email']}\n";
    }

    return message;
  }

  String _getMeasurementLabel(String key) {
    final labels = {
      'bust': 'Tour de poitrine',
      'waist': 'Tour de taille',
      'hips': 'Tour de hanches',
      'shoulder': 'Largeur d\'épaules',
      'arm_length': 'Longueur de bras',
      'leg_length': 'Longueur de jambe',
      'height': 'Taille',
    };
    return labels[key] ?? key;
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        title: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF004D40).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF004D40),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Demande envoyée !',
              style: TextStyle(
                color: Color(0xFF004D40),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'Votre demande a été préparée pour WhatsApp. '
          'Ouvrez WhatsApp pour l\'envoyer à notre atelier.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFF),
      body: Column(
        children: [
          // Header animé
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color(0xFF004D40),
                  Color(0xFF00695C),
                  Color(0xFF4DB6AC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004D40).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Effets de bulles
                ...List.generate(5, (index) {
                  return Positioned(
                    left: 20 + (index * 70) % screenWidth,
                    top: 50 + (index * 20) % 100,
                    child: Container(
                      width: 40 + index * 10,
                      height: 40 + index * 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 200).ms);
                }),

                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'WhatsApp',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Atelier de Couture',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 28 : 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Onglets de navigation
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.subcategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final isSelected = _selectedCategoryIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                          _selectedImages.clear();
                        });
                      },
                      child: AnimatedContainer(
                        duration: 300.ms,
                        constraints: BoxConstraints(
                          minWidth: isSmallScreen ? 100 : 120,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF004D40),
                                    Color(0xFF00695C),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Contenu principal avec SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(8),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight - 350),
                child: _buildContent(screenWidth),
              ),
            ),
          ),

          // Bouton d'action
          if (_formData.isNotEmpty || _selectedImages.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sendToWhatsApp,
                  icon: const Icon(Icons.phone, size: 24),
                  label: const Text(
                    'Envoyer sur WhatsApp',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(double screenWidth) {
    switch (_selectedCategoryIndex) {
      case 0:
        return _buildCustomTailoring(screenWidth);
      case 1:
        return _buildRepairs(screenWidth);
      case 2:
        return _buildReadyToWear(screenWidth);
      default:
        return Container();
    }
  }

  Widget _buildCustomTailoring(double screenWidth) {
    final isSmallScreen = screenWidth < 360;
    final crossAxisCount = isSmallScreen ? 2 : (screenWidth < 600 ? 3 : 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section modèles populaires
        const Text(
          'Modèles populaires',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF004D40),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Choisissez un modèle pour la confection sur mesure',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),

        // Grille des modèles adaptative
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: _popularModels.length,
          itemBuilder: (context, index) {
            final model = _popularModels[index];
            final isSelected = _formData['selected_model'] == model;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _formData['selected_model'] = model;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF004D40)
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            model['image'],
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        model['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        model['price'],
                        style: const TextStyle(
                          color: Color(0xFF004D40),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model['time'],
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      // if (isSelected) ...[
                      //   const SizedBox(height: 8),
                      //   Container(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 8,
                      //       vertical: 4,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       color: const Color(0xFF004D40).withOpacity(0.1),
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     child: const Icon(
                      //       Icons.check_rounded,
                      //       color: Color(0xFF004D40),
                      //       size: 16,
                      //     ),
                      //   ),
                      // ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Section mesures
        const Text(
          'Vos mesures (en cm)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF004D40),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Renseignez vos mesures pour une confection parfaite',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),

        // Grille de mesures adaptative
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
          ),
          itemCount: _getMeasurementFields().length,
          itemBuilder: (context, index) {
            final field = _getMeasurementFields()[index];
            final key = field['key'] ?? '';
            final label = field['label'] ?? '';
            return _buildMeasurementField(key, label);
          },
        ),

        const SizedBox(height: 24),

        // Section informations personnelles
        const Text(
          'Informations personnelles',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF004D40),
          ),
        ),
        const SizedBox(height: 12),
        _buildPersonalInfoSection(),
      ],
    );
  }

  List<Map<String, String>> _getMeasurementFields() {
    return [
      {'key': 'height', 'label': 'Taille'},
      {'key': 'bust', 'label': 'Poitrine'},
      {'key': 'waist', 'label': 'Taille'},
      {'key': 'hips', 'label': 'Hanches'},
      {'key': 'shoulder', 'label': 'Épaules'},
      {'key': 'arm_length', 'label': 'Bras'},
      {'key': 'leg_length', 'label': 'Jambes'},
    ];
  }

  Widget _buildMeasurementField(String field, String label) {
    final measurements = _formData['measurements'] as Map<String, String>;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            suffixText: 'cm',
            suffixStyle: const TextStyle(
              color: Color(0xFF004D40),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: (value) {
            setState(() {
              measurements[field] = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        _buildTextField('customer_name', 'Nom complet'),
        const SizedBox(height: 12),
        _buildTextField(
          'customer_phone',
          'Numéro de téléphone',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'customer_email',
          'Email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                border: InputBorder.none,
                labelText: 'Notes supplémentaires',
                alignLabelWithHint: true,
              ),
              onChanged: (value) {
                setState(() {
                  _formData['additional_notes'] = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String field,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: (value) {
            setState(() {
              _formData[field] = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildRepairs(double screenWidth) {
    final isSmallScreen = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos du vêtement',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF004D40),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ajoutez plusieurs photos sous différents angles',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),

        // Galerie d'images
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(_selectedImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 2),
                              ],
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 16),

        // Bouton ajouter photos
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF004D40).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 40,
                  color: const Color(0xFF004D40).withOpacity(0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajouter des photos',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: const Color(0xFF004D40),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cliquez pour sélectionner',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: const Color(0xFF004D40).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Informations sur les retouches
        const Text(
          'Détails des retouches',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF004D40),
          ),
        ),
        const SizedBox(height: 12),

        Column(
          children: [
            _buildRepairField('clothing_type', 'Type de vêtement'),
            const SizedBox(height: 12),
            _buildRepairField(
              'modification_details',
              'Détails des modifications souhaitées',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _buildRepairField('urgency', 'Urgence (ex: pour quand ?)'),
            const SizedBox(height: 12),
            _buildPersonalInfoSection(),
          ],
        ),
      ],
    );
  }

  Widget _buildRepairField(String field, String label, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            alignLabelWithHint: maxLines > 1,
            labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          style: const TextStyle(fontSize: 16),
          onChanged: (value) {
            setState(() {
              _formData[field] = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildReadyToWear(double screenWidth) {
    final isSmallScreen = screenWidth < 360;
    final crossAxisCount = isSmallScreen ? 2 : (screenWidth < 600 ? 2 : 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Collection prêt-à-porter',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF004D40),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Vêtements disponibles immédiatement',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),

        // Grille des vêtements adaptative
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: _readyToWear.length,
          itemBuilder: (context, index) {
            final item = _readyToWear[index];
            final isSelected = _formData['selected_item'] == item;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _formData['selected_item'] = item;
                  _showItemDetails(item);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF004D40)
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item['image'],
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF004D40,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item['category'],
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: const Color(0xFF004D40),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item['stock'],
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['price'],
                                style: const TextStyle(
                                  color: Color(0xFF004D40),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF004D40),
                                  size: 18,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Section commande si article sélectionné
        if (_formData['selected_item'] != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0F2F1)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Détails de la commande',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF004D40),
                  ),
                ),
                const SizedBox(height: 12),

                // Sélection de la taille
                const Text(
                  'Choisissez votre taille:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_formData['selected_item']['size'] as List<String>)
                      .map((size) {
                        final isSelected = _formData['selected_size'] == size;
                        return ChoiceChip(
                          label: Text(size),
                          selected: isSelected,
                          selectedColor: const Color(0xFF004D40),
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _formData['selected_size'] = size;
                            });
                          },
                        );
                      })
                      .toList(),
                ),

                const SizedBox(height: 20),

                // Adresse de livraison
                const Text(
                  'Adresse de livraison:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Adresse complète',
                        alignLabelWithHint: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _formData['delivery_address'] = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                _buildPersonalInfoSection(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          item['image'],
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF004D40),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF004D40).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['category'],
                          style: const TextStyle(
                            color: Color(0xFF004D40),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['stock'],
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item['price'],
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF004D40),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tailles disponibles:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (item['size'] as List<String>).map((size) {
                      return Chip(
                        label: Text(size),
                        backgroundColor: const Color(0xFFE0F2F1),
                        labelStyle: const TextStyle(
                          color: Color(0xFF004D40),
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Sélectionner cet article',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
