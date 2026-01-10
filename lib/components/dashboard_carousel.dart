import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    const Color.fromARGB(255, 56, 118, 181), // Bleu nuit
    const Color.fromARGB(255, 105, 105, 232), // Bleu ardoise
    const Color.fromARGB(191, 17, 142, 219), // Bleu royal
    const Color.fromARGB(255, 100, 5, 144), // Bleu ciel profond
    const Color.fromARGB(255, 3, 143, 164), // Gris bleuté
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
        duration: const Duration(milliseconds: 3000),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
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
                // Carte du dialogue
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
                      // En-tête du dialogue
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
                      // Corps du dialogue
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
                            // Icône décorative
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
                            // Séparateur
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
                            // Description complète
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
                            // Informations complémentaires
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
                      // Pied du dialogue
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
                // Bouton de fermeture extérieur
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
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 48),
                                  side: BorderSide(color: color),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Message',
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
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
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
                              SizedBox(width: isTablet ? 16 : 12),
                              OutlinedButton(
                                onPressed: () {},
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
                                  'Message',
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

    // Calcul dynamique de la hauteur du carousel
    double carouselHeight;
    double viewportFraction;
    EdgeInsets cardPadding;
    double fontSizeTitle;
    double fontSizeDescription;
    double iconSize;

    if (isSmallPhone) {
      carouselHeight = screenHeight * 0.25;
      viewportFraction = 0.82;
      cardPadding = const EdgeInsets.all(12);
      fontSizeTitle = 14;
      fontSizeDescription = 11;
      iconSize = 16;
    } else if (isMediumPhone) {
      carouselHeight = screenHeight * 0.28;
      viewportFraction = 0.85;
      cardPadding = const EdgeInsets.all(14);
      fontSizeTitle = 16;
      fontSizeDescription = 12;
      iconSize = 18;
    } else if (isLargePhone) {
      carouselHeight = screenHeight * 0.30;
      viewportFraction = 0.88;
      cardPadding = const EdgeInsets.all(16);
      fontSizeTitle = 17;
      fontSizeDescription = 13;
      iconSize = 20;
    } else {
      // Tablet
      carouselHeight = screenHeight * 0.32;
      viewportFraction = 0.88;
      cardPadding = const EdgeInsets.all(20);
      fontSizeTitle = isTablet ? 22 : 18;
      fontSizeDescription = isTablet ? 16 : 14;
      iconSize = isTablet ? 28 : 24;
    }

    // Ajuster le viewport fraction si nécessaire

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

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallPhone ? 6.0 : 8.0,
                    ),
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
                          borderRadius: BorderRadius.circular(
                            isSmallPhone ? 14 : 16,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: isSmallPhone ? 15 : 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // En-tête
                            Padding(
                              padding: cardPadding,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isFeatured)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              bottom: isSmallPhone ? 6 : 8,
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
                                        SizedBox(height: isSmallPhone ? 6 : 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.open_in_new_rounded,
                                              color: highlightColor,
                                              size: isSmallPhone ? 12 : 14,
                                            ),
                                            SizedBox(
                                              width: isSmallPhone ? 4 : 6,
                                            ),
                                            Flexible(
                                              child: Text(
                                                'Appuyez pour voir les détails',
                                                style: TextStyle(
                                                  color: highlightColor,
                                                  fontSize: isSmallPhone
                                                      ? 10
                                                      : 12,
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
                                  SizedBox(width: isSmallPhone ? 8 : 12),
                                  Container(
                                    padding: EdgeInsets.all(
                                      isSmallPhone ? 8 : 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                        isSmallPhone ? 8 : 12,
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
                            // Séparateur
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: cardPadding.horizontal / 2,
                              ),
                              child: Divider(
                                color: Colors.white.withOpacity(0.1),
                                height: 1,
                              ),
                            ),
                            // Description
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(cardPadding.left),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: SingleChildScrollView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        child: Text(
                                          _truncateDescription(
                                            description,
                                            isSmallPhone ? 80 : 100,
                                          ),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontSize: fontSizeDescription,
                                            fontWeight: FontWeight.w400,
                                            height: 1.5,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Pied de carte
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: cardPadding.left,
                                vertical: isSmallPhone ? 8 : 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(
                                    isSmallPhone ? 14 : 16,
                                  ),
                                  bottomRight: Radius.circular(
                                    isSmallPhone ? 14 : 16,
                                  ),
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
                                        size: isSmallPhone ? 12 : 16,
                                      ),
                                      SizedBox(width: isSmallPhone ? 4 : 6),
                                      Text(
                                        'PUBLIÉ AUJOURD\'HUI',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: isSmallPhone ? 8 : 10,
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
                                      fontSize: isSmallPhone ? 10 : 12,
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
            SizedBox(height: isSmallPhone ? 16 : 20),
            // Indicateurs de points adaptatifs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _ads.length,
                  (index) => Container(
                    width: _currentPage == index
                        ? (isSmallPhone
                              ? 10
                              : isTablet
                              ? 14
                              : 12)
                        : (isSmallPhone
                              ? 6
                              : isTablet
                              ? 10
                              : 8),
                    height: _currentPage == index
                        ? (isSmallPhone
                              ? 10
                              : isTablet
                              ? 14
                              : 12)
                        : (isSmallPhone
                              ? 6
                              : isTablet
                              ? 10
                              : 8),
                    margin: EdgeInsets.symmetric(
                      horizontal: isSmallPhone ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? _highlightColors[index % _highlightColors.length]
                          : Colors.grey.withOpacity(0.5),
                      boxShadow: _currentPage == index
                          ? [
                              BoxShadow(
                                color:
                                    _highlightColors[index %
                                            _highlightColors.length]
                                        .withOpacity(0.5),
                                blurRadius: isSmallPhone ? 4 : 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
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
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _cardColors[0],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
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
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune annonce active',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les nouvelles annonces apparaîtront ici',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
