import 'package:araservice/auth/login_page.dart';
import 'package:araservice/main_navigation_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback? onRegisterSuccess;
  final VoidCallback? onNavigateToLogin;

  const RegisterPage({
    super.key,
    this.onRegisterSuccess,
    this.onNavigateToLogin,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<void> _registerWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user == null) return;

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      final doc = await userRef.get();

      if (!doc.exists) {
        // 🆕 Création du nouvel utilisateur
        await userRef.set({
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': user.displayName ?? 'Utilisateur',
          'photoURL': user.photoURL ?? '',
          'phoneNumber': user.phoneNumber ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'orderCount': 0,
          'totalSpent': 0.0,
        });
      } else {
        // ⚠️ Cas rare : compte déjà existant
        await userRef.update({
          'lastLogin': FieldValue.serverTimestamp(),
          'displayName':
              user.displayName ?? doc.data()?['displayName'] ?? 'Utilisateur',
          'photoURL': user.photoURL ?? doc.data()?['photoURL'] ?? '',
          'email': user.email ?? doc.data()?['email'] ?? '',
        });
      }

      if (!mounted) return;

      // Animation / feedback succès
      _showSuccessDialog(googleUser);

      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (_) => false,
      );

      widget.onRegisterSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(GoogleSignInAccount user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00695C), Color(0xFF4DB6AC)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/success.json', width: 140),
                const SizedBox(height: 16),
                Text(
                  'Bienvenue ${user.displayName ?? 'chez ARA'} !',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Votre compte a été créé avec succès',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Navigation automatique après 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    });
  }

  void _showErrorSnackbar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade600,
        content: Text(error, maxLines: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: constraints.maxHeight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  /// HEADER
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF00695C), Color(0xFF4DB6AC)],
                              ),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          )
                          .animate()
                          // Apparition douce
                          .fadeIn(duration: 400.ms)
                          // Zoom progressif
                          .scale(
                            begin: const Offset(0.6, 0.6),
                            end: const Offset(1.0, 1.0),
                            duration: 5.seconds,
                            curve: Curves.easeInOut,
                          )
                          // Rotation complète
                          .rotate(
                            begin: 0,
                            end: 1, // 360°
                            duration: 2.seconds,
                            curve: Curves.easeInOut,
                          ),

                      const SizedBox(height: 8),
                      const Text(
                        'Rejoignez la famille\nARA Service',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00695C),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Créez votre compte en un clic et profitez de tous nos services',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  /// LOTTIE
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Lottie.asset(
                        'assets/animations/welcome.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  /// GOOGLE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: _isLoading ? null : _registerWithGoogle,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                          ),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Image.asset('assets/google.png'),
                                    ),
                                    const SizedBox(width: 16),
                                    const Text(
                                      'S\'inscrire avec Google',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// FEATURES
                  Column(
                    children: [
                      _buildFeature(
                        icon: Icons.bolt_rounded,
                        text: 'Accès immédiat à tous nos services',
                      ),
                      _buildFeature(
                        icon: Icons.security_rounded,
                        text: 'Sécurité Google garantie',
                      ),
                      _buildFeature(
                        icon: Icons.star_rounded,
                        text: 'Expérience personnalisée',
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// LOGIN
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: 'Déjà un compte ? ',
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: 'Se connecter',
                            style: TextStyle(
                              color: Color(0xFF00695C),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// FOOTER
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                              Icons.verified_user_rounded,
                              color: Color(0xFF00695C),
                            )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideX(begin: -0.2)
                            .then()
                            .shakeY(amount: 2),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Vos données sont protégées et ne seront jamais partagées.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeature({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8F5F4),
            ),
            child: Icon(icon, color: const Color(0xFF00695C), size: 20)
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(curve: Curves.easeOutBack)
                .then()
                .shakeX(amount: 2),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
