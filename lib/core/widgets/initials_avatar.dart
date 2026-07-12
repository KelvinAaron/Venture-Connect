import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// a colored circle avatar showing a name's initials
 
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const InitialsAvatar({super.key, required this.name, this.radius = 22});

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  Color get _color {
    final index = name.trim().isEmpty
        ? 0
        : name.codeUnits.fold<int>(0, (sum, c) => sum + c) %
            AppColors.avatarPalette.length;
    return AppColors.avatarPalette[index];
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _color.withValues(alpha: 0.15),
      child: Text(
        _initials,
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
