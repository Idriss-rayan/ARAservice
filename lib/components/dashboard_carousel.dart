import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class DashboardCarousel extends StatefulWidget {
  const DashboardCarousel({super.key});

  @override
  State<DashboardCarousel> createState() => _DashboardCarouselState();
}

class _DashboardCarouselState extends State<DashboardCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;
  Timer? _timer;
  List<DocumentSnapshot> _ads = [];

  // Couleurs modernes et élégantes
  final List<Color> _cardColors = [
    const Color.fromARGB(255, 56, 118, 181),
    const Color.fromARGB(255, 105, 105, 232),
    const Color.fromARGB(191, 17, 142, 219),
    const Color.fromARGB(255, 100, 5, 144),
    const Color.fromARGB(255, 3, 143, 164),
  ];

  final List<Color> _highlightColors = [
    const Color.fromARGB(255, 115, 233, 60),
    const Color.fromARGB(255, 52, 152, 219),
    const Color(0xFF2ECC71),
    const Color(0xFFF39C12),
    const Color(0xFF9B59B6),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_ads.isEmpty || !_pageController.hasClients) return;

      int nextPage = _currentPage + 1;
      if (nextPage >= _ads.length) nextPage = 0;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _getField(DocumentSnapshot doc, String field, String defaultValue) {
    try {
      return doc.get(field)?.toString() ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  bool _getBoolField(DocumentSnapshot doc, String field, bool defaultValue) {
    try {
      return doc.get(field) ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showDescriptionDialog(
    BuildContext context,
    String title,
    String description,
    Color color,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(
          isSmallPhone
              ? 12
              : isTablet
              ? 30
              : 20,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: isTablet ? 500 : double.infinity,
          ),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50),
                    borderRadius: BorderRadius.circular(isSmallPhone ? 20 : 24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          isSmallPhone
                              ? 16
                              : isTablet
                              ? 28
                              : 24,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isSmallPhone ? 20 : 24),
                            topRight: Radius.circular(isSmallPhone ? 20 : 24),
                          ),
                          border: Border.all(
                            color: color.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallPhone ? 12 : 16,
                                    vertical: isSmallPhone ? 6 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'DÉTAILS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallPhone ? 10 : 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      isSmallPhone ? 6 : 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: isSmallPhone ? 16 : 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallPhone ? 12 : 16),
                            Text(
                              title.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallPhone
                                    ? 18
                                    : isTablet
                                    ? 24
                                    : 22,
                                fontWeight: FontWeight.w900,
                                height: 1.3,
                                letterSpacing: 0.8,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(
                          isSmallPhone
                              ? 16
                              : isTablet
                              ? 24
                              : 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(
                                  bottom: isSmallPhone ? 16 : 20,
                                ),
                                padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      color.withOpacity(0.8),
                                      color.withOpacity(0.4),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.description_rounded,
                                  color: Colors.white,
                                  size: isSmallPhone ? 24 : 32,
                                ),
                              ),
                            ),
                            Container(
                              height: 1,
                              margin: EdgeInsets.symmetric(
                                vertical: isSmallPhone ? 12 : 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    color.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              description,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallPhone
                                    ? 14
                                    : isTablet
                                    ? 18
                                    : 16,
                                fontWeight: FontWeight.w400,
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: isSmallPhone ? 16 : 24),
                            Container(
                              padding: EdgeInsets.all(isSmallPhone ? 12 : 16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                  isSmallPhone ? 12 : 16,
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: color,
                                    size: isSmallPhone ? 16 : 20,
                                  ),
                                  SizedBox(width: isSmallPhone ? 8 : 12),
                                  Expanded(
                                    child: Text(
                                      'Cette annonce est valide pour une durée limitée.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: isSmallPhone ? 12 : 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(isSmallPhone ? 16 : 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(isSmallPhone ? 20 : 24),
                            bottomRight: Radius.circular(
                              isSmallPhone ? 20 : 24,
                            ),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: isSmallPhone
                            ? Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showContactDialog(context, title, color);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(double.infinity, 48),
                                      backgroundColor: color,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                      shadowColor: color.withOpacity(0.5),
                                    ),
                                    child: Text(
                                      'En savoir plus',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      minimumSize: Size(double.infinity, 48),
                                      backgroundColor: Colors.white.withOpacity(
                                        0.1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Fermer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      backgroundColor: Colors.white.withOpacity(
                                        0.1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Fermer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showContactDialog(context, title, color);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      backgroundColor: color,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                      shadowColor: color.withOpacity(0.5),
                                    ),
                                    child: Text(
                                      'En savoir plus',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                if (!isSmallPhone) SizedBox(height: 20),
                if (!isSmallPhone)
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(isTablet ? 16 : 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: Colors.white,
                        size: isTablet ? 28 : 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context, String title, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallPhone = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    // Fonction pour envoyer un message WhatsApp
    Future<void> _sendWhatsAppMessage() async {
      // Numéro de téléphone (à configurer)
      final String phoneNumber = '+33612345678';

      // Message avec l'annonce
      final String message =
          "Bonjour, je suis intéressé par votre annonce :\n\n"
          "*${title.toUpperCase()}*\n\n" // En gras + majuscules
          "Pouvez-vous me donner plus d'informations ?";

      // URL WhatsApp
      final String url =
          "https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}";

      try {
        // Utilisation de share_plus pour partager
        await Share.share(message, subject: 'Information sur : $title');
      } catch (e) {
        // Fallback : message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(
          isSmallPhone
              ? 12
              : isTablet
              ? 30
              : 20,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 400 : double.infinity,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50),
            borderRadius: BorderRadius.circular(isSmallPhone ? 16 : 20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallPhone ? 16 : 24),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isSmallPhone ? 16 : 20),
                    topRight: Radius.circular(isSmallPhone ? 16 : 20),
                  ),
                ),
                child: Center(
                  child: Text(
                    'CONTACTEZ-NOUS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallPhone
                          ? 14
                          : isTablet
                          ? 20
                          : 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isSmallPhone ? 16 : 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.phone_in_talk_rounded,
                      color: Colors.white,
                      size: isSmallPhone
                          ? 36
                          : isTablet
                          ? 56
                          : 48,
                    ),
                    SizedBox(height: isSmallPhone ? 12 : 16),
                    Text(
                      'Pour plus d\'informations sur :',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: isSmallPhone ? 12 : 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallPhone
                            ? 14
                            : isTablet
                            ? 18
                            : 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmallPhone ? 20 : 24),
                    isSmallPhone
                        ? Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 48),
                                  backgroundColor: color,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Appeler',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: _sendWhatsAppMessage, // ← CHANGÉ ICI
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 48),
                                  side: BorderSide(color: color),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Message WhatsApp', // ← TEXTE MODIFIÉ
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ElevatedButton(
                              //   onPressed: () {},
                              //   style: ElevatedButton.styleFrom(
                              //     padding: EdgeInsets.symmetric(
                              //       horizontal: 24,
                              //       vertical: 12,
                              //     ),
                              //     backgroundColor: color,
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(10),
                              //     ),
                              //   ),
                              //   child: Text(
                              //     'Appeler',
                              //     style: TextStyle(
                              //       fontSize: 14,
                              //       fontWeight: FontWeight.w600,
                              //     ),
                              //   ),
                              // ),
                              SizedBox(width: isTablet ? 16 : 12),
                              OutlinedButton(
                                onPressed: _sendWhatsAppMessage, // ← CHANGÉ ICI
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  side: BorderSide(color: color),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Message WhatsApp', // ← TEXTE MODIFIÉ
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;
    final isMediumPhone = screenWidth >= 360 && screenWidth < 400;
    final isLargePhone = screenWidth >= 400 && screenWidth < 600;
    final isTablet = screenWidth >= 600;

    // DIMENSIONS OPTIMISÉES - HAUTEUR RÉDUITE AU MAXIMUM
    double carouselHeight;
    double viewportFraction;
    EdgeInsets cardPadding;
    double fontSizeTitle;
    double fontSizeDescription;
    double iconSize;
    EdgeInsets cardMargin;
    double borderRadius;

    if (isSmallPhone) {
      carouselHeight = screenHeight * 0.18; // Hauteur minimale
      viewportFraction = 0.82;
      cardPadding = const EdgeInsets.all(8); // Padding réduit
      fontSizeTitle = 12; // Police plus petite
      fontSizeDescription = 9;
      iconSize = 14;
      cardMargin = const EdgeInsets.symmetric(horizontal: 4);
      borderRadius = 12;
    } else if (isMediumPhone) {
      carouselHeight = screenHeight * 0.20;
      viewportFraction = 0.85;
      cardPadding = const EdgeInsets.all(10);
      fontSizeTitle = 14;
      fontSizeDescription = 10;
      iconSize = 16;
      cardMargin = const EdgeInsets.symmetric(horizontal: 5);
      borderRadius = 14;
    } else if (isLargePhone) {
      carouselHeight = screenHeight * 0.22;
      viewportFraction = 0.88;
      cardPadding = const EdgeInsets.all(12);
      fontSizeTitle = 15;
      fontSizeDescription = 11;
      iconSize = 18;
      cardMargin = const EdgeInsets.symmetric(horizontal: 6);
      borderRadius = 16;
    } else {
      // Tablet
      carouselHeight = screenHeight * 0.24;
      viewportFraction = 0.88;
      cardPadding = const EdgeInsets.all(14);
      fontSizeTitle = isTablet ? 18 : 16;
      fontSizeDescription = isTablet ? 13 : 12;
      iconSize = isTablet ? 22 : 20;
      cardMargin = const EdgeInsets.symmetric(horizontal: 7);
      borderRadius = isTablet ? 18 : 16;
    }

    final Stream<QuerySnapshot> adsStream = FirebaseFirestore.instance
        .collection('ads')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: adsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: carouselHeight,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(_highlightColors[0]),
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return _buildEmptyPlaceholder(carouselHeight);
        }

        _ads = snapshot.data!.docs;

        return Column(
          children: [
            SizedBox(
              height: carouselHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _ads.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final doc = _ads[index];
                  final title = _getField(doc, 'title', 'Offre spéciale');
                  final description = _getField(
                    doc,
                    'description',
                    'Découvrez cette opportunité unique',
                  );
                  final isFeatured = _getBoolField(doc, 'featured', false);
                  final highlightColor =
                      _highlightColors[index % _highlightColors.length];
                  final cardColor = _cardColors[index % _cardColors.length];

                  return Container(
                    margin: cardMargin,
                    child: GestureDetector(
                      onTap: () => _showDescriptionDialog(
                        context,
                        title,
                        description,
                        highlightColor,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(borderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header compact
                            Padding(
                              padding: cardPadding,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isFeatured)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            child: _buildBadge(
                                              'MIS EN AVANT',
                                              highlightColor,
                                            ),
                                          ),
                                        Text(
                                          title.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: fontSizeTitle,
                                            fontWeight: FontWeight.w800,
                                            height: 1.2,
                                            letterSpacing: 0.8,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.open_in_new_rounded,
                                              color: highlightColor,
                                              size: fontSizeDescription,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'Appuyez pour voir les détails',
                                                style: TextStyle(
                                                  color: highlightColor,
                                                  fontSize: fontSizeDescription,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(iconSize * 0.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                        borderRadius,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.visibility_rounded,
                                      color: highlightColor,
                                      size: iconSize,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Separator
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: cardPadding.left,
                              ),
                              child: Divider(
                                color: Colors.white.withOpacity(0.1),
                                height: 1,
                                thickness: 1,
                              ),
                            ),
                            // Description compacte
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(cardPadding.left),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _truncateDescription(
                                        description,
                                        isSmallPhone ? 60 : 80,
                                      ),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: fontSizeDescription,
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Footer compact
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: cardPadding.left,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(borderRadius),
                                  bottomRight: Radius.circular(borderRadius),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        color: Colors.white.withOpacity(0.6),
                                        size: fontSizeDescription,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'PUBLIÉ AUJOURD\'HUI',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: fontSizeDescription - 2,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${index + 1}/${_ads.length}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: fontSizeDescription,
                                      fontWeight: FontWeight.w500,
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
                },
              ),
            ),
            // Indicateurs compacts
            Container(
              height: 16,
              margin: EdgeInsets.only(top: isSmallPhone ? 8 : 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: _ads.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: _currentPage == index
                        ? (isSmallPhone
                              ? 8
                              : isTablet
                              ? 12
                              : 10)
                        : (isSmallPhone
                              ? 4
                              : isTablet
                              ? 8
                              : 6),
                    height: _currentPage == index
                        ? (isSmallPhone
                              ? 8
                              : isTablet
                              ? 12
                              : 10)
                        : (isSmallPhone
                              ? 4
                              : isTablet
                              ? 8
                              : 6),
                    margin: EdgeInsets.symmetric(
                      horizontal: isSmallPhone ? 2 : 3,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? _highlightColors[index % _highlightColors.length]
                          : Colors.grey.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _truncateDescription(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildEmptyPlaceholder(double height) {
    return SizedBox(
      height: height,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColors[0],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune annonce active',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Les nouvelles annonces apparaîtront ici',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
