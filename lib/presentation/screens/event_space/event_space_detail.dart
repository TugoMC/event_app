import 'package:carousel_slider/carousel_slider.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventSpaceDetailScreen extends StatefulWidget {
  final EventSpace eventSpace;

  const EventSpaceDetailScreen({super.key, required this.eventSpace});

  @override
  State<EventSpaceDetailScreen> createState() => _EventSpaceDetailScreenState();
}

class _EventSpaceDetailScreenState extends State<EventSpaceDetailScreen> {
  int _currentPage = 0;

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Custom App Bar with back button and title
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                toolbarHeight: 100, // Increased height for better spacing
                pinned: true, // Changed from floating to pinned
                title: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.black, size: 20),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Details',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                centerTitle: false,
              ),

              // Add fixed padding after AppBar
              const SliverPadding(
                padding: EdgeInsets.only(top: 20),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: Colors.grey[300],
                              ),
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  height: 200,
                                  viewportFraction: 1,
                                  enableInfiniteScroll: true,
                                  autoPlay: false,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentPage = index;
                                    });
                                  },
                                ),
                                items: widget.eventSpace.photos.map((photo) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      image: DecorationImage(
                                        image: NetworkImage(photo),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            Positioned(
                              right: 16,
                              top: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.favorite_border,
                                      color: Colors.black, size: 20),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  widget.eventSpace.photos.length,
                                  (index) => _buildDot(index),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Rest of the content with padding
                    Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 100,
                        top: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            widget.eventSpace.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Rating, Hours and Price row
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.star,
                                color: Color(0xFF8773F8),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.eventSpace
                                    .getAverageRating()
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                CupertinoIcons.clock,
                                size: 16,
                                color: Color(0xFF8773F8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.eventSpace.hours,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF8773F8).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${widget.eventSpace.price.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF8773F8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            widget.eventSpace.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              height: 1.4,
                            ),
                          ),

                          // Phone section
                          const SizedBox(height: 24),
                          const Text(
                            'Téléphone',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '+225 01 02 03 04 05',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          // Activities section
                          const SizedBox(height: 24),
                          const Text(
                            'Activités',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                                widget.eventSpace.activities.map((activity) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: const Color(0xFF8773F8)
                                          .withOpacity(0.2),
                                      child: Icon(activity.icon,
                                          color: const Color(0xFF8773F8)),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      activity.type,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Fixed bottom buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 245,
                      height: 62,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8773F8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'APPELER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8773F8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.location_on,
                          color: Color(0xFF8773F8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
