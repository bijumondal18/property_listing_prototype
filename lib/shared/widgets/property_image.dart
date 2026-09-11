import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PropertyImage extends StatelessWidget {
  const PropertyImage({
    super.key,
    required this.imageUrl,
    this.localImagePath,
    this.height,
    this.width,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final String? localImagePath;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);
    final localPath = localImagePath?.trim();

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: localPath != null && localPath.isNotEmpty
            ? Image.file(
                File(localPath),
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return _networkOrPlaceholder(context);
                },
              )
            : _networkOrPlaceholder(context),
      ),
    );
  }

  Widget _networkOrPlaceholder(BuildContext context) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        placeholder: (context, url) => _Placeholder(
          height: height,
          isLoading: true,
        ),
        errorWidget: (context, url, error) => _Placeholder(
          height: height,
          isLoading: false,
        ),
      );
    }
    return _Placeholder(height: height, isLoading: false);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.height, required this.isLoading});

  final double? height;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: height ?? 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.15),
            colorScheme.secondary.withValues(alpha: 0.25),
            colorScheme.primary.withValues(alpha: 0.35),
          ],
        ),
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colorScheme.primary.withValues(alpha: 0.6),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.apartment_rounded,
                    size: 48,
                    color: colorScheme.primary.withValues(alpha: 0.55),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Property Image',
                    style: TextStyle(
                      color: colorScheme.primary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
