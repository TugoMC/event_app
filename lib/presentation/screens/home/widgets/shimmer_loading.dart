import 'package:flutter/material.dart';

class ShimmerEffect extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerEffect({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
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
              colors: const [
                Color(0xFFEEEEEE),
                Color(0xFFF5F5F5),
                Color(0xFFEEEEEE),
              ],
              stops: [
                0.0,
                _animation.value.abs() / 2 + 0.5,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}

class LocationCardShimmer extends StatelessWidget {
  const LocationCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerEffect(
            width: double.infinity,
            height: 160,
            borderRadius: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerEffect(width: 200, height: 24),
                const SizedBox(height: 8),
                const ShimmerEffect(width: 150, height: 16),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    ShimmerEffect(width: 80, height: 16),
                    SizedBox(width: 16),
                    ShimmerEffect(width: 80, height: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CityCardShimmer extends StatelessWidget {
  const CityCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 95,
      child: Column(
        children: const [
          ShimmerEffect(
            width: 80,
            height: 70,
            borderRadius: 12,
          ),
          SizedBox(height: 4),
          ShimmerEffect(
            width: 60,
            height: 16,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}

class CommuneCardShimmer extends StatelessWidget {
  const CommuneCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 95,
      child: Column(
        children: const [
          ShimmerEffect(
            width: 80,
            height: 70,
            borderRadius: 12,
          ),
          SizedBox(height: 4),
          ShimmerEffect(
            width: 60,
            height: 16,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}
