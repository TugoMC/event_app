import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.1, 0.3, 0.5, 0.7, 0.9],
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[50]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              transform: GradientRotation(_animation.value),
            ),
          ),
        );
      },
    );
  }
}

class ShimmerFavoriteCard extends StatelessWidget {
  const ShimmerFavoriteCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          ShimmerLoading(
            width: 60,
            height: 60,
            borderRadius: 12,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  width: 120,
                  height: 16,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                ShimmerLoading(
                  width: 160,
                  height: 14,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ShimmerLoading(
            width: 24,
            height: 24,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}

class ShimmerReviewCard extends StatelessWidget {
  const ShimmerReviewCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ShimmerLoading(
                  width: 150,
                  height: 16,
                  borderRadius: 4,
                ),
              ),
              ShimmerLoading(
                width: 50,
                height: 24,
                borderRadius: 12,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ShimmerLoading(
            width: double.infinity,
            height: 60,
            borderRadius: 4,
          ),
          const SizedBox(height: 12),
          ShimmerLoading(
            width: 100,
            height: 12,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}
