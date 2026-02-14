import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String geminiApiKey = 'AIzaSyBgp9pydM2MBaJIqW6bKdraWi6m1-cq00Q';
const String geminiModel = 'gemini-2.0-flash-lite';

void main() {
  runApp(const DukoApp());
}

class DukoApp extends StatelessWidget {
  const DukoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'duko',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF253A82)),
        useMaterial3: true,
      ),
      home: const AnimatedSplashScreen(
        nextScreen: SplashRouter(),
      ),
    );
  }
}

// ─── ANIMATED SPLASH SCREEN ───
class AnimatedSplashScreen extends StatefulWidget {
  final Widget nextScreen;
  
  const AnimatedSplashScreen({super.key, required this.nextScreen});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.black,
      end: const Color(0xFF6366F1), // BRIGHTER BLUE - more poppy!
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const DiscoverScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _colorAnimation.value,
          body: Center(
            child: Opacity(
              opacity: _textOpacity.value,
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'SF Pro',
                    letterSpacing: -1,
                  ),
                  children: [
                    TextSpan(
                      text: 'd',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'u',
                      style: TextStyle(color: Color(0xFFC3D946)), // GREEN
                    ),
                    TextSpan(
                      text: 'ko',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── DISCOVER SCREEN (after splash) ───
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const SplashRouter(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6366F1), // BRIGHT BLUE
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Rediscover',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'what you see',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Router ───
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final interests = prefs.getStringList('interests');

    if (!mounted) return;

    if (interests != null && interests.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(interests: interests),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InterestsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}

// ─── Interests Selection Screen ───
class InterestsScreen extends StatefulWidget {
  final bool isEditingFromSettings; // NEW: track if user came from settings
  
  const InterestsScreen({super.key, this.isEditingFromSettings = false});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final List<Map<String, String>> _allInterests = [
    {'name': 'Science', 'emoji': '🔬'},
    {'name': 'Art', 'emoji': '🎨'},
    {'name': 'Sports', 'emoji': '⚽'},
    {'name': 'Nature', 'emoji': '🌿'},
    {'name': 'History', 'emoji': '🏛️'},
    {'name': 'Music', 'emoji': '🎵'},
    {'name': 'Space', 'emoji': '🚀'},
    {'name': 'Food', 'emoji': '🍜'},
    {'name': 'Technology', 'emoji': '💻'},
    {'name': 'Animals', 'emoji': '🐾'},
    {'name': 'Movies', 'emoji': '🎬'},
    {'name': 'Literature', 'emoji': '📚'},
    {'name': 'Psychology', 'emoji': '🧠'},
    {'name': 'Architecture', 'emoji': '🏗️'},
    {'name': 'Ocean', 'emoji': '🌊'},
    {'name': 'Math', 'emoji': '🔢'},
  ];

  final List<String> _selected = [];
  
  final List<Color> _brandColors = const [
    Color(0xFFC3D946),
    Color(0xFFB8A0F0),
    Color(0xFF6366F1),
  ];

  Future<void> _saveAndContinue() async {
    if (_selected.length < 3) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('interests', _selected);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(interests: _selected),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    return _brandColors[index % _brandColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // duko logo on LEFT (not centered!)
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Pro',
                  ),
                  children: [
                    TextSpan(
                      text: 'd',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'u',
                      style: TextStyle(color: Color(0xFFC3D946)),
                    ),
                    TextSpan(
                      text: 'ko',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "What makes you\ncurious?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This helps us connect facts to things\nyou actually care about',
                style: TextStyle(
                  color: Color(0xFFB0B0B0), // Brighter gray
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select at least 3',
                style: TextStyle(
                  color: Color(0xFF909090), // Brighter gray
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _allInterests.map((interest) {
                      final isSelected = _selected.contains(interest['name']);
                      final selectedIndex = _selected.indexOf(interest['name']!);
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selected.remove(interest['name']);
                            } else {
                              _selected.add(interest['name']!);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _getColorForIndex(selectedIndex)
                                : Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: isSelected
                                  ? _getColorForIndex(selectedIndex)
                                  : Colors.white.withOpacity(0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                interest['emoji']!,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                interest['name']!,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : const Color(0xFFD0D0D0), // Brighter white
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 16),
                child: Column(
                  children: [
                    // Main action button
                    GestureDetector(
                      onTap: _selected.length >= 3 ? _saveAndContinue : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _selected.length >= 3
                              ? const Color(0xFF253A82)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            _selected.length >= 3
                                ? "Let's go"
                                : 'Select ${3 - _selected.length} more',
                            style: TextStyle(
                              color: _selected.length >= 3
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Cancel button (only when editing from settings)
                    if (widget.isEditingFromSettings) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          // Get saved interests and go back to home
                          final prefs = await SharedPreferences.getInstance();
                          final savedInterests = prefs.getStringList('interests') ?? ['Science', 'Art', 'Nature'];
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HomeScreen(interests: savedInterests),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Home Screen ───
class HomeScreen extends StatelessWidget {
  final List<String> interests;

  const HomeScreen({super.key, required this.interests});

  // Cycle through brand colors for interest tags
  Color _getTagColor(int index) {
    final colors = [
      const Color(0xFF6366F1), // Blue
      const Color(0xFFB8A0F0), // Violet
      const Color(0xFFC3D946), // Green
    ];
    return colors[index % colors.length];
  }

  Future<void> _takePicture(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    XFile? image;
    try {
      image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
    } catch (e) {
      debugPrint('Camera failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera unavailable on simulator. Use gallery instead!'),
          ),
        );
      }
      return;
    }

    if (image != null && context.mounted) {
      final String path = image.path;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoadingScreen(imagePath: path, interests: interests),
        ),
      );
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (image != null && context.mounted) {
        final String path = image.path;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoadingScreen(imagePath: path, interests: interests),
          ),
        );
      }
    } catch (e) {
      debugPrint('Gallery failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not access gallery'),
          ),
        );
      }
    }
  }

  void _showTextInput(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.65,
            decoration: BoxDecoration(
              color: const Color(0xFF9333EA), // VIBRANT VIOLET
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9333EA).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                const Text(
                  'What did you spot?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'Type anything you see around you',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 40),
                // Text field
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. a pigeon, traffic light...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 19,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 22,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoadingScreen(
                            textQuery: value.trim(),
                            interests: interests,
                          ),
                        ),
                      );
                    }
                  },
                ),
                const Spacer(),
                // Buttons row
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Go button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final value = controller.text;
                          if (value.trim().isNotEmpty) {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoadingScreen(
                                  textQuery: value.trim(),
                                  interests: interests,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(
                            child: Text(
                              'Go',
                              style: TextStyle(
                                color: Color(0xFF9333EA), // Match violet
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // duko logo on LEFT
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'SF Pro',
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'd',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'u',
                          style: TextStyle(color: Color(0xFFC3D946)),
                        ),
                        TextSpan(
                          text: 'ko',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // Settings icon in GREEN
                  GestureDetector(
                    onTap: () async {
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InterestsScreen(isEditingFromSettings: true),
                          ),
                        );
                      }
                    },
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFFC3D946),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              children: [
                // Big camera icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 56,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 32),
                // Main title
                const Text(
                  'Tap to discover',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                Text(
                  'Turn everyday moments into\nmind-blowing facts',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // Interest tags
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: interests
                        .asMap()
                        .entries
                        .map((entry) {
                          final index = entry.key;
                          final interest = entry.value;
                          final tagColor = _getTagColor(index);
                          
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: tagColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: tagColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              interest,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gallery - Green
                  GestureDetector(
                    onTap: () => _pickFromGallery(context),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFC3D946).withOpacity(0.2),
                        border: Border.all(
                          color: const Color(0xFFC3D946),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_library_outlined,
                        color: Color(0xFFC3D946),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  // Camera - White
                  GestureDetector(
                    onTap: () => _takePicture(context),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  // Type - Green
                  GestureDetector(
                    onTap: () => _showTextInput(context),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFC3D946).withOpacity(0.2),
                        border: Border.all(
                          color: const Color(0xFFC3D946),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.keyboard_alt_outlined,
                        color: Color(0xFFC3D946),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading Screen ───
class LoadingScreen extends StatefulWidget {
  final String? imagePath;
  final String? textQuery;
  final List<String> interests;

  const LoadingScreen({
    super.key,
    this.imagePath,
    this.textQuery,
    required this.interests,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _generateCards();
  }

  String _cleanJsonResponse(String raw) {
    String cleaned = raw.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```[a-zA-Z]*\n?'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'\n?```$'), '');
      cleaned = cleaned.trim();
    }
    return cleaned;
  }

  Future<void> _generateCards() async {
    try {
      final interestsStr = widget.interests.join(', ');

      const String systemPrompt =
          'You are the cool friend who makes EVERYTHING fascinating. Your superpower: finding real facts that make people go "wait WHAT?!" and seeing genuine connections between things. Make learning feel like discovering secrets about the world. Every fact should make someone want to tell their friends at dinner.';

      List<Map<String, dynamic>> parts = [];

      if (widget.imagePath != null) {
        final bytes = await File(widget.imagePath!).readAsBytes();
        final base64Image = base64Encode(bytes);
        parts.add({
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': base64Image,
          }
        });
        parts.add({
          'text':
              '''$systemPrompt

User interests: $interestsStr

Identify what's in this image and create 3 discovery cards.

YOUR MISSION: Make them say "WHOA I had no idea!"

CARD STRUCTURE:

Card 1: HOOK THEM IMMEDIATELY
- Start with "In this photo..." OR "This [object]..." OR "The [thing] you spotted..."
- Lead with the MOST unexpected fact
- Make it impossible to scroll away
- 35-40 words MAX

Card 2: BLOW THEIR MIND FURTHER
- Find connections to their interests (ONLY if genuinely relevant - don't force it)
- Use specific numbers, dates, measurements (makes it feel more "real")
- Make them think "everything is connected"
- If no real connection to interests → just give another insane fact
- 35-40 words MAX

Card 3: THE "I NEED TO TELL SOMEONE" MOMENT
- The fact they'll share at dinner
- Big picture connection (evolution, universe, time, ecosystems)
- Should reframe how they see this thing forever
- 35-40 words MAX

WRITING VIBE:
- Talk like a curious friend who just learned something cool, not a textbook
- Use "you/your" to make it personal (lowercase only)
- 70% concrete facts (numbers make it real)
- 30% relatability/scale for perspective
- Every fact should be shareable

WHAT MAKES A FACT "SHAREABLE":
✅ Unexpected numbers ("16 septillion molecules")
✅ Weird evolution stories ("cats domesticated themselves")
✅ Hidden connections ("purring heals bones")
✅ Time scale mind-benders ("water from dinosaurs")
✅ Things that sound fake but are real

RULES:
1. First card MUST hook them (acknowledge the photo)
2. Every fact must pass the "would I tell this to a friend?" test
3. Only connect to interests if it's genuinely mind-blowing
4. Make them see something familiar in a completely new way
5. Numbers and scale are your friends (make abstract concrete)

Return ONLY valid JSON:
{"cards":[{"title":"3-4 word punchy title","content":"Mind-blowing fact","color":"#hexcolor"},{"title":"...","content":"...","color":"..."},{"title":"...","content":"...","color":"..."}]}

CRITICAL: Do NOT include color codes, hex codes, hashtags (#), or ANY codes in the title or content text. Color codes belong ONLY in the "color" field.

Colors to choose from (use ONLY in the "color" field, NOT in content): #4A90E2, #E74C3C, #2ECC71, #9B59B6, #F39C12, #1ABC9C, #E91E63, #FF6B35'''
        });
      } else if (widget.textQuery != null) {
        parts.add({
          'text':
              '''$systemPrompt

User spotted: "${widget.textQuery}"
User interests: $interestsStr

Create 3 discovery cards showing real connections.

YOUR MISSION: Make them say "WHOA I had no idea!"

[Same instructions as image version...]

Return ONLY valid JSON:
{"cards":[{"title":"3-4 word punchy title","content":"Mind-blowing fact","color":"#hexcolor"},{"title":"...","content":"...","color":"..."},{"title":"...","content":"...","color":"..."}]}

CRITICAL: Do NOT include color codes, hex codes, hashtags (#), or ANY codes in the title or content text. Color codes belong ONLY in the "color" field.

Colors to choose from (use ONLY in the "color" field, NOT in content): #4A90E2, #E74C3C, #2ECC71, #9B59B6, #F39C12, #1ABC9C, #E91E63, #FF6B35'''
        });
      }

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': parts,
            }
          ],
          'generationConfig': {
            'temperature': 0.8,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        final cleanedContent = _cleanJsonResponse(content);
        final cardsData = jsonDecode(cleanedContent);

        final List<DiscoveryCard> cards = (cardsData['cards'] as List)
            .map((card) => DiscoveryCard(
                  title: card['title'] ?? 'Discovery',
                  content: card['content'] ?? '',
                  color: card['color'] != null
                      ? _parseColor(card['color'].toString())
                      : const Color(0xFF4A90E2),
                  emoji: '✨',
                ))
            .toList();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CardsScreen(cards: cards),
            ),
          );
        }
      } else {
        throw Exception(
            'API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error generating cards: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16));
    }
    return const Color(0xFF4A90E2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)), // BLUE
            ),
            const SizedBox(height: 24),
            const Text(
              'Discovering...',
              style: TextStyle(
                color: Color(0xFF6366F1), // BLUE
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cards Screen ───
class CardsScreen extends StatefulWidget {
  final List<DiscoveryCard> cards;

  const CardsScreen({super.key, required this.cards});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.cards.length,
            itemBuilder: (context, index) {
              return _buildCard(widget.cards[index]);
            },
          ),
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.cards.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    width: 6,
                    height: _currentPage == index ? 24 : 6,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(DiscoveryCard card) {
    return Container(
      color: card.color,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                card.content,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.85),
                  fontSize: 18,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Model ───
class DiscoveryCard {
  final String title;
  final String content;
  final Color color;
  final String emoji;

  DiscoveryCard({
    required this.title,
    required this.content,
    required this.color,
    required this.emoji,
  });
}