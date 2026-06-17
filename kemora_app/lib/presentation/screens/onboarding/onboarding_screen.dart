import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              _buildPage1(),
              _buildPage2(),
              _buildPage3(),
            ],
          ),
          
          // Skip Button
          Positioned(
            top: 60,
            right: 24,
            child: GestureDetector(
              onTap: _finishOnboarding,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('SKIP', style: AppTypography.labelSmall),
              ),
            ),
          ),

          // Dots
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isActive = _currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.surfaceContainerHigh,
          child: const Center(child: Icon(Icons.image, size: 100, color: AppColors.outlineVariant)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DISCOVER THE NILE', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryFixedDim)),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppTypography.displayMedium.copyWith(color: Colors.white),
                  children: const [
                    TextSpan(text: 'Your Odyssey\n'),
                    TextSpan(text: 'Begins Here.', style: TextStyle(color: AppColors.primaryContainer)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Step into an editorial journey through the sands of time. Curated experiences for the modern archivist.',
                style: AppTypography.bodyLarge.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                child: const Text('Start Exploration'),
              ),
              const SizedBox(height: 60), // padding for dots
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPage2() {
    return Padding(
      padding: const EdgeInsets.all(32).copyWith(top: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CURATED ARCHIVES', style: AppTypography.headlineSmall.copyWith(color: AppColors.primaryContainer)),
          const SizedBox(height: 8),
          Text('Three pillars of the Kemora experience.', style: AppTypography.bodyMedium),
          const SizedBox(height: 48),
          
          _buildFeatureCard(Icons.account_balance, 'Hidden Temples', 'Access exclusive guides to lesser-known archaeological sites across the Valley of the Kings.', AppColors.secondaryFixed),
          const SizedBox(height: 24),
          _buildFeatureCard(Icons.article, 'Editorial Stories', 'Deep-dive long-form articles written by leading Egyptologists and local curators.', AppColors.secondaryFixedDim),
          const SizedBox(height: 24),
          _buildFeatureCard(Icons.auto_awesome, 'AI-Scribe', 'Translate hieroglyphs in real-time and discover the lore behind every inscription.', AppColors.primaryFixed),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.onSurface),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                Text(desc, style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return Padding(
      padding: const EdgeInsets.all(32).copyWith(top: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Tailor Your\nExperience', style: AppTypography.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            'To provide a truly personalized odyssey, we need a few permissions.',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.location_on, color: AppColors.primaryContainer),
                ),
                const SizedBox(height: 16),
                Text('Near Me', style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Find historical landmarks and cultural gems relative to your current position.',
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.onSurface,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Allow Location'),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          ElevatedButton(
            onPressed: _finishOnboarding,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
            child: const Text('Complete Setup'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _finishOnboarding,
            child: Text("I'll do this later in Settings", style: AppTypography.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
