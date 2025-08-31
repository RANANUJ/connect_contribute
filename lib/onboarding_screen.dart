import 'package:flutter/material.dart';
import 'screens/auth_welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Welcome to Connect &\nContribute',
      description: 'Bridge the gap between donors,\nvolunteers, and NGOs in your\ncommunity.',
      imagePath: 'assets/images/onboard1.png', // You'll need to add this image
    ),
    OnboardingData(
      title: 'Donate & Volunteer',
      description: 'Find opportunities to donate items or\nvolunteer your time for local causes.',
      imagePath: 'assets/images/onboard2.png', // You'll need to add this image
    ),
    OnboardingData(
      title: 'Track Your Impact',
      description: 'See your contribution history and\ncelebrate your milestones!',
      imagePath: 'assets/images/onboard3.png', // You'll need to add this image
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipToHome,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            
            // PageView for onboarding screens
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.hasClients && _pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                      }
                      return Transform.scale(
                        scale: Curves.easeOut.transform(value),
                        child: Opacity(
                          opacity: value,
                          child: _buildOnboardingPage(_onboardingData[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => _buildPageIndicator(index),
              ),
            ),
            const SizedBox(height: 40),
            
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B2CBF), // Purple color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image placeholder - you'll need to add the actual images
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: data.imagePath.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      data.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder(data.title);
                      },
                    ),
                  )
                : _buildImagePlaceholder(data.title),
          ),
          const SizedBox(height: 60),
          
          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),
          
          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(String title) {
    IconData icon;
    Color color;
    
    if (title.contains('Welcome')) {
      icon = Icons.public;
      color = Colors.green;
    } else if (title.contains('Donate')) {
      icon = Icons.volunteer_activism;
      color = Colors.blue;
    } else {
      icon = Icons.analytics;
      color = Colors.orange;
    }
    
    return Center(
      child: Icon(
        icon,
        size: 120,
        color: color,
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    double animationValue = 1.0;
    double width = 8.0;
    
    if (_pageController.hasClients && _pageController.position.haveDimensions) {
      double currentPage = _pageController.page ?? 0.0;
      if (index == _currentPage) {
        // Current page indicator
        width = 24.0;
        animationValue = 1.0;
      } else if (index == currentPage.floor() || index == currentPage.ceil()) {
        // Adjacent page indicators during transition
        double distance = (currentPage - index).abs();
        animationValue = (1.0 - distance).clamp(0.0, 1.0);
        width = 8.0 + (16.0 * animationValue);
      }
    } else if (index == _currentPage) {
      width = 24.0;
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: index == _currentPage 
            ? const Color(0xFF7B2CBF) 
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToHome();
    }
  }

  void _skipToHome() {
    _goToHome();
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AuthWelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

// Placeholder home screen - replace this with your actual home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect & Contribute'),
        backgroundColor: const Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Connect & Contribute!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You have successfully completed the onboarding.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
