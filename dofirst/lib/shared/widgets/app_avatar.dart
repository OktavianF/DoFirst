import 'dart:convert';

import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.source,
    required this.fallbackText,
    required this.size,
    this.borderWidth = 4,
    this.borderColor = const Color(0xFFE2DFFF),
    this.fallbackBackgroundColor = const Color(0xFFE2DFFF),
    this.fallbackTextColor = const Color(0xFF0F0069),
  });

  final String? source;
  final String fallbackText;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final Color fallbackBackgroundColor;
  final Color fallbackTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: ClipOval(
        child: _buildImageOrFallback(),
      ),
    );
  }

  Widget _buildImageOrFallback() {
    final value = source?.trim();
    if (value == null || value.isEmpty) {
      return _buildFallback();
    }

    if (value.startsWith('data:image/')) {
      try {
        final base64Part = value.split(',').last;
        final bytes = base64Decode(base64Part);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: size,
          height: size,
        );
      } catch (_) {
        return _buildFallback();
      }
    }

    return Image.network(
      value,
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: fallbackBackgroundColor,
      alignment: Alignment.center,
      child: Text(
        fallbackText,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.bold,
          color: fallbackTextColor,
        ),
      ),
    );
  }
}
