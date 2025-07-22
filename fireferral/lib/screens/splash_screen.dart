import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../themes/app_themes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _scaleController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        _fadeController.forward();
        _rotateController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.modernGradient,
            stops: const [0.0, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(20, (index) => _buildFloatingParticle(index)),
            
            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return _buildAnimatedLogo(themeProvider);
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // App Title with gradient text
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, Color(0xFFE3F2FD)],
                          ).createShader(bounds),
                          child: Text(
                            themeProvider.getAppTitle(),
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 42,
                              letterSpacing: 2,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle with typewriter effect
                    Text(
                      'Telecom Referral Tracking',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 60),
                    
                    // Custom loading indicator
                    _buildCustomLoader(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(ThemeProvider themeProvider) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8F9FA)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating background circle
          RotationTransition(
            turns: _rotateAnimation,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: AppColors.vibrantGradient,
                ),
              ),
            ),
          ),
          // Main logo
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Image.asset(
              'assets/images/fireferral_logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF00A8E6), Color(0xFF0066CC)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'F',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomLoader() {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          // Outer ring
          RotationTransition(
            turns: _rotateAnimation,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
            ),
          ),
          // Inner spinning indicator
          RotationTransition(
            turns: Tween<double>(begin: 0.0, end: 2.0).animate(_rotateController),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = (index * 1234567) % 1000;
    final size = 4.0 + (random % 8);
    final left = (random % 100) / 100.0;
    final top = ((random * 7) % 100) / 100.0;
    final duration = 3000 + (random % 2000);
    
    return Positioned(
      left: MediaQuery.of(context).size.width * left,
      top: MediaQuery.of(context).size.height * top,
      child: AnimatedBuilder(
        animation: _rotateController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              20 * (_rotateAnimation.value * 2 - 1),
              10 * (_rotateAnimation.value * 2 - 1),
            ),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1 + (random % 30) / 100),
              ),
            ),
          );
        },
      ),
    );
  }
}