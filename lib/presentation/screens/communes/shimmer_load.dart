import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerEffect({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class CommuneListItemShimmer extends StatelessWidget {
  const CommuneListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const ShimmerEffect(
            width: 80,
            height: 70,
            borderRadius: 8,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ShimmerEffect(
              height: 20,
              width: MediaQuery.of(context).size.width * 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class LocationCardShimmer extends StatelessWidget {
  const LocationCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerEffect(
            height: 200,
            borderRadius: 8,
          ),
          const SizedBox(height: 12),
          ShimmerEffect(
            height: 24,
            width: MediaQuery.of(context).size.width * 0.6,
          ),
          const SizedBox(height: 8),
          ShimmerEffect(
            height: 16,
            width: MediaQuery.of(context).size.width * 0.8,
          ),
          const SizedBox(height: 8),
          ShimmerEffect(
            height: 16,
            width: MediaQuery.of(context).size.width * 0.4,
          ),
        ],
      ),
    );
  }
}
