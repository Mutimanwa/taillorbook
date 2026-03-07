import 'package:flutter/material.dart';

class ProductGalleryScreen extends StatefulWidget {
  const ProductGalleryScreen({super.key});

  @override
  State<ProductGalleryScreen> createState() => _ProductGalleryScreenState();
}

class _ProductGalleryScreenState extends State<ProductGalleryScreen> {
  final PageController _pageController = PageController();
  final List<String> _images = [
    'https://images.pexels.com/photos/6347547/pexels-photo-6347547.jpeg',
    'https://images.pexels.com/photos/6347548/pexels-photo-6347548.jpeg',
    'https://images.pexels.com/photos/6347549/pexels-photo-6347549.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(_images[index], fit: BoxFit.contain),
                ),
              );
            },
          ),
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _images.length,
                (index) => AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double selected = 0;
                    if (_pageController.hasClients) {
                      selected = (_pageController.page ?? 0);
                    }
                    bool isActive = selected.round() == index;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      width: isActive ? 24 : 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
