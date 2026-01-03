import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardCarousel extends StatefulWidget {
  const DashboardCarousel({super.key});

  @override
  State<DashboardCarousel> createState() => _DashboardCarouselState();
}

class _DashboardCarouselState extends State<DashboardCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.95);
  int _currentPage = 0;
  Timer? _timer;
  List<DocumentSnapshot> _ads = [];

  @override
  void initState() {
    super.initState();

    // Auto-slide toutes les 3 secondes
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_ads.isEmpty) return;

      _currentPage++;
      if (_currentPage >= _ads.length) _currentPage = 0;

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 700),
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

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> adsStream = FirebaseFirestore.instance
        .collection('ads')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: adsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox(
            height: MediaQuery.of(context).size.width * 0.55,
            child: const Center(child: Text("Aucune publicité")),
          );
        }

        _ads = snapshot.data!.docs;

        return SizedBox(
          height: MediaQuery.of(context).size.width * 0.55, // Plus grand
          child: PageView.builder(
            controller: _pageController,
            itemCount: _ads.length,
            itemBuilder: (context, index) {
              final doc = _ads[index];
              final title = doc['title'] ?? 'Titre par défaut';
              final description =
                  doc['description'] ?? 'Description par défaut';

              return AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00695C), Color(0xFF4DB6AC)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00695C).withOpacity(0.3),
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.spa_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Texte du titre plus gros et lisible
                        Flexible(
                          child: Text(
                            title.toUpperCase(),
                            style: const TextStyle(
                              color: Color.fromARGB(124, 255, 255, 255),
                              fontSize: 20, // plus gros
                              fontWeight: FontWeight.w800, // plus lourd
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
