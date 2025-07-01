import 'package:flutter/material.dart';

class VeterinarianCard extends StatelessWidget {
  final String veterinarianName;
  final String specialty;
  final String clinic;
  final String experience;
  final double rating;
  final String? imagePath;
  final VoidCallback? onTap;
  final bool showDistance;
  final String? distance;

  const VeterinarianCard({
    super.key,
    required this.veterinarianName,
    required this.specialty,
    required this.clinic,
    required this.experience,
    required this.rating,
    this.imagePath,
    this.onTap,
    this.showDistance = false,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  _buildVeterinarianAvatar(),
                  const SizedBox(width: 16),
                  _buildVeterinarianInfo(),
                  _buildFavoriteButton(),
                ],
              ),
              const SizedBox(height: 16),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVeterinarianAvatar() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: const Color(0xFF81D4FA).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          imagePath != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildDefaultIcon(),
                ),
              )
              : _buildDefaultIcon(),
    );
  }

  Widget _buildDefaultIcon() {
    return const Icon(Icons.person_rounded, size: 32, color: Colors.white);
  }

  Widget _buildVeterinarianInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            veterinarianName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: const Color(0xFF81D4FA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              specialty,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF81D4FA),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.local_hospital_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  clinic,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: () {
          // Implementar favoritos
        },
        icon: Icon(
          Icons.favorite_border_rounded,
          color: Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Row(
      children: [
        _buildRatingSection(),
        const Spacer(),
        _buildExperienceChip(),
        if (showDistance && distance != null) ...[
          const SizedBox(width: 8),
          _buildDistanceChip(),
        ],
      ],
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: const Color(0xFFFF7043).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 14,
            color: const Color(0xFFFF7043),
          ),
          const SizedBox(width: 4),
          Text(
            experience,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF7043),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            distance!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
