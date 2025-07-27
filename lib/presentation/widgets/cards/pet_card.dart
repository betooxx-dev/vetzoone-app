import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/image_utils.dart';
import '../../../domain/entities/pet.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;
  final bool isHorizontal;

  const PetCard({
    super.key,
    required this.pet,
    this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalCard();
    }
    return _buildVerticalCard();
  }

  Widget _buildVerticalCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: AppSizes.spaceM),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          gradient: _getGradientByType(),
          boxShadow: [
            BoxShadow(
              color: _getGradientByType().colors.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Stack(
            children: [
              // Imagen de fondo
              Positioned.fill(
                child: _buildPetImage(),
              ),
              
              // Overlay gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Status badge
              Positioned(
                top: AppSizes.spaceM,
                right: AppSizes.spaceM,
                child: _buildStatusBadge(),
              ),
              
              // Información inferior
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.spaceXS),
                      Text(
                        '${pet.breed} • ${_getAgeText()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.spaceM),
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagen circular
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                gradient: _getGradientByType(),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                child: _buildPetImage(),
              ),
            ),
            
            const SizedBox(width: AppSizes.spaceM),
            
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceXS),
                  Text(
                    '${pet.breed} • ${_getAgeText()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSizes.spaceXS),
                  Text(
                    pet.type.name,
                    style: TextStyle(
                      fontSize: 11,
                      color: _getGradientByType().colors.first,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetImage() {
    if (pet.imageUrl != null && 
        pet.imageUrl!.isNotEmpty && 
        ImageUtils.isValidImageUrl(pet.imageUrl!)) {
      return Image.network(
        pet.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading pet image: $error');
          return _buildDefaultIcon();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: _getGradientByType().colors.first,
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / 
                    loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      color: _getGradientByType().colors.first.withOpacity(0.1),
      child: Icon(
        _getTypeIcon(),
        color: _getGradientByType().colors.first,
        size: isHorizontal ? 24 : 40,
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (pet.status == null) return const SizedBox();

    Color color;
    String text;
    IconData icon;
    
    switch (pet.status!) {
      case PetStatus.HEALTHY:
        color = const Color(0xFF10B981);
        text = 'Saludable';
        icon = Icons.favorite;
        break;
      case PetStatus.TREATMENT:
        color = const Color(0xFF3B82F6);
        text = 'Tratamiento';
        icon = Icons.medical_services;
        break;
      case PetStatus.ATTENTION:
        color = const Color(0xFFF59E0B);
        text = 'Atención';
        icon = Icons.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceS,
        vertical: AppSizes.spaceXS,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.white,
          ),
          if (!isHorizontal) ...[
            const SizedBox(width: AppSizes.spaceXS),
            Text(
              text,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  LinearGradient _getGradientByType() {
    switch (pet.type) {
      case PetType.DOG:
        return const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PetType.CAT:
        return const LinearGradient(
          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PetType.BIRD:
        return const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PetType.RABBIT:
        return const LinearGradient(
          colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getTypeIcon() {
    switch (pet.type) {
      case PetType.DOG:
        return Icons.pets;
      case PetType.CAT:
        return Icons.pets;
      case PetType.BIRD:
        return Icons.flutter_dash;
      case PetType.RABBIT:
        return Icons.cruelty_free;
      default:
        return Icons.pets;
    }
  }

  String _getAgeText() {
    final age = DateTime.now().difference(pet.birthDate).inDays ~/ 365;
    return age == 0 ? '< 1 año' : '$age año${age > 1 ? 's' : ''}';
  }
}