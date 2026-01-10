import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ModeConfectionPage extends StatefulWidget {
  final List<String> subcategories;
  const ModeConfectionPage({super.key, required this.subcategories});

  @override
  State<ModeConfectionPage> createState() => _ModeConfectionPageState();
}

class _ModeConfectionPageState extends State<ModeConfectionPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  int selectedCategoryIndex = 0;
  int selectedServiceIndex = 0;
  List<String> services = [];
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool _isExpanded = false;
  final ScrollController _scrollController = ScrollController();

  // Contrôleurs pour le formulaire
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quartierController = TextEditingController();
  final TextEditingController villeController = TextEditingController();
  final TextEditingController tailleController = TextEditingController();
  final TextEditingController poitrineController = TextEditingController();
  final TextEditingController tailleHancheController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  // Gestion des images
  List<XFile> _selectedImages = [];
  List<String> _selectedProductIds = [];

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
    _animationController.forward();
    _loadServices();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    final snapshot = await _firestore
        .collection('fashion')
        .doc(widget.subcategories[selectedCategoryIndex])
        .collection('services')
        .get();

    setState(() {
      services = snapshot.docs.map((e) => e.id).toList();
      selectedServiceIndex = 0;
    });
  }

  Stream<QuerySnapshot> _itemsStream() {
    if (services.isEmpty) return const Stream.empty();
    return _firestore
        .collection('fashion')
        .doc(widget.subcategories[selectedCategoryIndex])
        .collection('services')
        .doc(services[selectedServiceIndex])
        .collection('items')
        .snapshots();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedImages);
        });
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la sélection des images');
    }
  }

  void _toggleProductSelection(String productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
      }
    });
  }

  bool _isProductSelected(String productId) {
    return _selectedProductIds.contains(productId);
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _sendWhatsApp() {
    if (_selectedProductIds.isEmpty && _selectedImages.isEmpty) {
      _showSnackBar(
        'Veuillez sélectionner au moins un produit ou ajouter une image',
      );
      return;
    }

    if (nameController.text.isEmpty || villeController.text.isEmpty) {
      _showSnackBar('Veuillez remplir les informations personnelles');
      return;
    }

    final String message =
        """
Bonjour, je souhaite commander un vêtement sur mesure.

📦 **Produits sélectionnés:** ${_selectedProductIds.length} produit(s)

👤 **Informations personnelles:**
- Nom: ${nameController.text}
- Quartier: ${quartierController.text}
- Ville: ${villeController.text}

📏 **Mesures:**
- Taille: ${tailleController.text}
- Poitrine: ${poitrineController.text}
- Taille/Hanche: ${tailleHancheController.text}

📝 **Détails supplémentaires:**
${detailsController.text.isNotEmpty ? detailsController.text : "Aucun détail supplémentaire"}

🖼️ **Images jointes:** ${_selectedImages.length} image(s)

🎯 **Service:** ${services[selectedServiceIndex]}
📁 **Catégorie:** ${widget.subcategories[selectedCategoryIndex]}
""";

    Share.share(message);

    // Réinitialiser la sélection après l'envoi
    setState(() {
      _selectedProductIds.clear();
      _selectedImages.clear();
      detailsController.clear();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF004D40),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleForm() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // AppBar avec dégradé vert élégant
          SliverAppBar(
            expandedHeight: 180,
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
                      const Color(0xFF004D40),
                      const Color(0xFF00695C),
                      const Color(0xFF00897B),
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
                        const SizedBox(height: 40),
                        Text(
                          'MODE & CONFECTION',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 3,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Créations sur mesure',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.95),
                            letterSpacing: 2,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Indicateur de sélection
          if (_selectedProductIds.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF004D40), const Color(0xFF00796B)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF004D40).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${_selectedProductIds.length} produit(s) sélectionné(s)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedProductIds.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedProductIds.clear();
                          });
                        },
                        icon: const Icon(Icons.clear, color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),

          // Catégories en vert
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Container(
                height: 80,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF004D40).withOpacity(0.1),
                      blurRadius: 25,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: widget.subcategories.length,
                  itemBuilder: (context, index) {
                    final selected = index == selectedCategoryIndex;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 5,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? LinearGradient(
                                  colors: [
                                    const Color(0xFF004D40),
                                    const Color(0xFF00796B),
                                  ],
                                )
                              : null,
                          color: selected ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: selected
                                ? Colors.transparent
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF004D40,
                                    ).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ]
                              : null,
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedCategoryIndex = index;
                            });
                            _loadServices();
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Center(
                            child: Text(
                              widget.subcategories[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Services en vert
          if (services.isNotEmpty)
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final selected = index == selectedServiceIndex;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF004D40,
                                      ).withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ]
                                : null,
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF004D40)
                                  : Colors.grey.shade300,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () =>
                                setState(() => selectedServiceIndex = index),
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Text(
                                services[index],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: selected
                                      ? const Color(0xFF004D40)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          // Grille d'articles avec animations en cascade
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: StreamBuilder<QuerySnapshot>(
              stream: _itemsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(
                    child: Center(
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(
                            const Color(0xFF004D40),
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
                            size: 60,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Erreur de chargement',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
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
                            Icons.inventory_outlined,
                            color: Colors.grey.shade300,
                            size: 80,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Aucun article disponible',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 18,
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
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 0.75,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = items[index].data() as Map<String, dynamic>;
                      final itemId = items[index].id;
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        columnCount: 2,
                        child: ScaleAnimation(
                          scale: 0.5,
                          child: FadeInAnimation(
                            child: _buildProductCard(item, itemId),
                          ),
                        ),
                      );
                    }, childCount: items.length),
                  ),
                );
              },
            ),
          ),

          // Bouton flottant pour le formulaire en vert
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                height: _isExpanded ? null : 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF004D40).withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Bouton d'expansion en vert
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF004D40),
                            const Color(0xFF00796B),
                            const Color(0xFF00897B),
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
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.monitor_weight,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Commande sur mesure',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                AnimatedRotation(
                                  duration: const Duration(milliseconds: 400),
                                  turns: _isExpanded ? 0.5 : 0,
                                  child: const Icon(
                                    Icons.expand_more,
                                    color: Colors.white,
                                    size: 28,
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
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          children: [
                            // Section Images téléchargées
                            _buildFormSection(
                              title: 'Images de référence',
                              icon: Icons.photo_library,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        onPressed: _pickImages,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFE0F2F1,
                                          ),
                                          foregroundColor: const Color(
                                            0xFF004D40,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        icon: const Icon(
                                          Icons.add_photo_alternate,
                                          size: 22,
                                        ),
                                        label: const Text(
                                          'Ajouter des images',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    if (_selectedImages.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_selectedImages.length} image(s) sélectionnée(s)',
                                            style: const TextStyle(
                                              color: Color(0xFF004D40),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            height: 100,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: _selectedImages.length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 10,
                                                      ),
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        width: 100,
                                                        height: 100,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          border: Border.all(
                                                            color: const Color(
                                                              0xFF004D40,
                                                            ),
                                                            width: 2,
                                                          ),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          child: Image.file(
                                                            File(
                                                              _selectedImages[index]
                                                                  .path,
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 5,
                                                        right: 5,
                                                        child: GestureDetector(
                                                          onTap: () =>
                                                              _removeImage(
                                                                index,
                                                              ),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                                  color: Colors
                                                                      .red,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                ),
                                                            child: const Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.white,
                                                              size: 18,
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
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            // Section Informations personnelles
                            _buildFormSection(
                              title: 'Informations personnelles',
                              icon: Icons.person_outline,
                              children: [
                                _buildInputField(
                                  controller: nameController,
                                  label: 'Nom complet',
                                  icon: Icons.person,
                                ),
                                const SizedBox(height: 12),
                                _buildInputField(
                                  controller: quartierController,
                                  label: 'Quartier',
                                  icon: Icons.location_city,
                                ),
                                const SizedBox(height: 12),
                                _buildInputField(
                                  controller: villeController,
                                  label: 'Ville',
                                  icon: Icons.place,
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            // Section Mesures personnelles
                            _buildFormSection(
                              title: 'Mesures personnelles',
                              icon: Icons.straighten,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildInputField(
                                      controller: tailleController,
                                      label: 'Taille (M, L, 38)',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInputField(
                                      controller: poitrineController,
                                      label: 'Poitrine (cm)',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInputField(
                                      controller: tailleHancheController,
                                      label: 'Taille/Hanche (cm)',
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            // Section Détails supplémentaires
                            _buildFormSection(
                              title: 'Détails supplémentaires',
                              icon: Icons.description,
                              children: [
                                TextField(
                                  controller: detailsController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Décrivez vos besoins spécifiques...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE0F2F1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF004D40),
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // Bouton WhatsApp avec compteurs
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: const Color(0xFF25D366).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: const Color(
                                    0xFF25D366,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildCounterItem(
                                        'Produits',
                                        _selectedProductIds.length,
                                      ),
                                      _buildCounterItem(
                                        'Images',
                                        _selectedImages.length,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: _sendWhatsApp,
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
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.phone, size: 24),
                                          SizedBox(width: 12),
                                          Text(
                                            'commander',
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

  Widget _buildProductCard(Map<String, dynamic> item, String itemId) {
    final isSelected = _isProductSelected(itemId);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _toggleProductSelection(itemId),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF004D40).withOpacity(0.3)
                    : const Color(0xFF004D40).withOpacity(0.1),
                blurRadius: isSelected ? 25 : 20,
                spreadRadius: isSelected ? 3 : 2,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: isSelected ? const Color(0xFF004D40) : Colors.transparent,
              width: isSelected ? 3 : 0,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image avec effet de superposition
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(17),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            color: const Color(0xFFF5F7F9),
                            child: item['imageUrl'] != null
                                ? Image.network(
                                    item['imageUrl'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
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
                                              color: const Color(0xFF004D40),
                                            ),
                                          );
                                        },
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.photo_camera_back,
                                      color: Colors.grey.shade400,
                                      size: 40,
                                    ),
                                  ),
                          ),
                          // Overlay gradient vert
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  const Color(0xFF004D40).withOpacity(0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Badge de prix en vert
                          Positioned(
                            top: 15,
                            right: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF004D40),
                                    const Color(0xFF00796B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF004D40,
                                    ).withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Text(
                                '${item['price'] ?? 0}€',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF004D40)
                                : const Color(0xFF004D40),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF004D40)
                                : const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF004D40)
                                  : const Color(0xFFB2DFDB),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            isSelected ? '✓ Sélectionné' : 'Sélectionner',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF004D40),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Badge de sélection
              if (isSelected)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF004D40),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF004D40).withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0F2F1), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF004D40), size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF004D40),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0F2F1)),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF004D40),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF004D40), size: 20)
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF004D40),
          fontWeight: FontWeight.w500,
        ),
        cursorColor: const Color(0xFF004D40),
      ),
    );
  }

  Widget _buildCounterItem(String label, int count) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: count > 0 ? const Color(0xFF004D40) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: count > 0 ? Colors.white : Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
