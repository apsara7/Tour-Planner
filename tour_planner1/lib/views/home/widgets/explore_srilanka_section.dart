import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'plan_trip_section.dart';
import '../../hotels/hotels_list_view.dart';

class ExploreSriLankaSection extends StatefulWidget {
  const ExploreSriLankaSection({super.key});

  @override
  State<ExploreSriLankaSection> createState() => _ExploreSriLankaSectionState();
}

class _ExploreSriLankaSectionState extends State<ExploreSriLankaSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < sliderData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  final List<Map<String, String>> sliderData = [
    {
      "image": "assets/images/srilanka1.png",
      "title": "Welcome to Sri Lanka!",
      "subtitle":
          "Get ready to explore the wonders of Sri Lanka, where every journey is an adventure."
    },
    {
      "image": "assets/images/surf.png",
      "title": "Surf the Best Waves",
      "subtitle":
          "From the south coast to the east, Sri Lanka offers surf spots for beginners and pros alike!"
    },
    {
      "image": "assets/images/safari.png",
      "title": "Go on a Thrilling Safari",
      "subtitle":
          "See majestic leopards, elephants, and diverse birdlife in their natural habitat."
    },
    {
      "image": "assets/images/elephant.png",
      "title": "See Elephants in the Wild",
      "subtitle":
          "Discover one of the largest elephant gatherings in the world!"
    },
    {
      "image": "assets/images/heritage.png",
      "title": "Explore Ancient Heritage",
      "subtitle":
          "Step back in time and visit ancient temples, rock fortresses, and UNESCO heritage sites."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: sliderData.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final item = sliderData[index];
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(item["image"]!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"]!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item["subtitle"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                context.go('/plan-trip');
                              },
                              child: const Text(
                                "Explore Sri Lanka",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // --- Dots Indicator ---
        Positioned(
          bottom: 15,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              sliderData.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 12 : 8,
                height: _currentPage == index ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.white : Colors.white54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
