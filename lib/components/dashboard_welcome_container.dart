// Import Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardWelcomeContainer extends StatelessWidget {
  const DashboardWelcomeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // Stream Firestore pour récupérer les pubs, la dernière en premier
    final Stream<QuerySnapshot> adsStream = FirebaseFirestore.instance
        .collection('ads')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: adsStream,
      builder: (context, snapshot) {
        // Texte par défaut si aucune pub
        String title =
            "Moi c'est ARA, votre assistant personnel pour tous vos besoins de nettoyage, couture et service à domicile.";
        String subtitle = "Votre partenaire pour un quotidien impeccable";
        String description = "(Nettoyer, coudre, servir)";

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final doc = snapshot.data!.docs.first;
          title = doc['title'] ?? title;
          subtitle = doc['description'] ?? subtitle;
          // Tu peux ajouter un champ supplémentaire dans Firestore si tu veux un texte de description distinct
        }

        return Container(
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
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
