import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/pet.dart';

class PetAvatar extends StatelessWidget {
  final Pet? pet;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;

  const PetAvatar({
    super.key,
    this.pet,
    this.radius = 20,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = pet?.imageUrl;
    final effectiveBackgroundColor = backgroundColor ?? AppColors.secondary.withOpacity(0.1);
    final effectiveIconColor = iconColor ?? AppColors.secondary;

    return CircleAvatar(
      backgroundColor: effectiveBackgroundColor,
      radius: radius,
      backgroundImage: imageUrl != null && imageUrl.isNotEmpty
          ? NetworkImage(imageUrl)
          : null,
      child: imageUrl == null || imageUrl.isEmpty
          ? Icon(
              _getPetIcon(pet?.type),
              color: effectiveIconColor,
              size: radius * 0.8,
            )
          : null,
    );
  }

  IconData _getPetIcon(PetType? type) {
    switch (type) {
      case PetType.DOG:
        return Icons.pets;
      case PetType.CAT:
        return Icons.pets;
      case PetType.BIRD:
        return Icons.flutter_dash;
      case PetType.RABBIT:
        return Icons.cruelty_free;
      case PetType.FISH:
        return Icons.set_meal;
      case PetType.REPTILE:
        return Icons.pets;
      case PetType.HAMSTER:
        return Icons.pets;
      case PetType.OTHER:
      default:
        return Icons.pets;
    }
  }
}

class PetInfo extends StatelessWidget {
  final Pet? pet;
  final String? fallbackName;
  final TextStyle? nameStyle;
  final TextStyle? breedStyle;
  final bool showAge;
  final bool showGender;

  const PetInfo({
    super.key,
    this.pet,
    this.fallbackName,
    this.nameStyle,
    this.breedStyle,
    this.showAge = false,
    this.showGender = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = pet?.name ?? fallbackName ?? 'Mascota';
    final breed = pet?.breed ?? 'Raza no especificada';
    final type = pet != null ? _getPetTypeString(pet!.type) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: nameStyle ?? const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          type != null ? '$type • $breed' : breed,
          style: breedStyle ?? const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        if (showAge && pet != null) ...[
          Text(
            _getAgeString(pet!.birthDate),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
        if (showGender && pet != null) ...[
          Text(
            _getGenderString(pet!.gender),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  String _getPetTypeString(PetType type) {
    switch (type) {
      case PetType.DOG:
        return 'Perro';
      case PetType.CAT:
        return 'Gato';
      case PetType.BIRD:
        return 'Ave';
      case PetType.RABBIT:
        return 'Conejo';
      case PetType.FISH:
        return 'Pez';
      case PetType.REPTILE:
        return 'Reptil';
      case PetType.HAMSTER:
        return 'Hámster';
      case PetType.OTHER:
        return 'Otro';
    }
  }

  String _getGenderString(PetGender gender) {
    switch (gender) {
      case PetGender.MALE:
        return '♂ Macho';
      case PetGender.FEMALE:
        return '♀ Hembra';
      case PetGender.UNKNOWN:
        return 'Género no especificado';
    }
  }

  String _getAgeString(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.difference(birthDate);
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;

    if (years > 0) {
      if (months > 0) {
        return '$years años, $months meses';
      } else {
        return years == 1 ? '1 año' : '$years años';
      }
    } else if (months > 0) {
      return months == 1 ? '1 mes' : '$months meses';
    } else {
      final days = age.inDays;
      return days == 1 ? '1 día' : '$days días';
    }
  }
} 