import 'package:flutter/material.dart';

/// Opaque pinned header used for TabBar / Filter-Sort sticky sections.
class PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  PinnedHeaderDelegate({
    required this.child,
    required this.height,
    this.backgroundColor,
    this.elevation = 0.1,
  });

  final Widget child;
  final double height;
  final Color? backgroundColor;
  final double elevation;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final bg = backgroundColor ?? Theme.of(context).colorScheme.surface;
    return Material(
      color: bg,
      elevation: overlapsContent || shrinkOffset > 0 ? elevation : 0,
      child: SizedBox(height: height, width: double.infinity, child: child),
    );
  }

  @override
  bool shouldRebuild(covariant PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.child != child ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.elevation != elevation;
  }
}
