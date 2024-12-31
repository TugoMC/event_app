import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'app_bar_styles.dart';
import 'package:flutter/cupertino.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> photoUrls;

  const ImageCarousel({Key? key, required this.photoUrls}) : super(key: key);

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentPage = 0;

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 5, top: 5),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF8773F8)
            : const Color(0xFFC3B9FB),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  void _openLightbox(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageLightbox(
          images: widget.photoUrls,
          initialIndex: index,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppBarStyles.horizontalPadding),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 250,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentPage = index;
                });
              },
            ),
            items: widget.photoUrls.map((url) {
              return GestureDetector(
                onTap: () =>
                    _openLightbox(context, widget.photoUrls.indexOf(url)),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppBarStyles.horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                widget.photoUrls.length, (index) => _buildDot(index)),
          ),
        ),
      ],
    );
  }
}

class ImageLightbox extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final Function() onClose;

  const ImageLightbox({
    Key? key,
    required this.images,
    required this.initialIndex,
    required this.onClose,
  }) : super(key: key);

  @override
  _ImageLightboxState createState() => _ImageLightboxState();
}

class _ImageLightboxState extends State<ImageLightbox> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  widget.images[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularButton(
                  icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
                  onPressed: widget.onClose,
                ),
                Text(
                  '${_currentIndex + 1}/${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.black26,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
