import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'app_bar_styles.dart';

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
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(url),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(32),
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
