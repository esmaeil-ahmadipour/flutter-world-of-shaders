import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_world_of_shaders/effects/pincushion_distortion.dart';
import 'package:flutter_world_of_shaders/gallery/widgets/gallery_grid.dart';
import 'package:flutter_world_of_shaders/gallery/widgets/interactive_grid.dart';

class InteractiveGallery extends StatefulWidget {
  const InteractiveGallery({
    super.key,
    this.children = const [],
    this.enableSnapping = true,
    this.enableDistortion = true,
    this.size = 2,
  });

  final List<Widget> children;
  final int size;
  final bool enableSnapping;
  final bool enableDistortion;

  int get maxItemsPerViewport => (children.length / (size * size)).floor();

  @override
  State<InteractiveGallery> createState() => _InteractiveGalleryState();
}

class _InteractiveGalleryState extends State<InteractiveGallery>
    with SingleTickerProviderStateMixin {
  final _distortionAmountNotifier = ValueNotifier<double>(0);
  late List<Widget> viewports;

  List<Widget> _generateViewports() {
    final slicedChildren =
        widget.children.slices(widget.maxItemsPerViewport).toList();

    return List.generate(
      slicedChildren.length,
      (urlsSliceIndex) {
        final childrenSlice = slicedChildren[urlsSliceIndex];

        return GalleryGrid(
          index: urlsSliceIndex,
          children: childrenSlice.toList(),
        );
      },
    );
  }

  @override
  void initState() {
    viewports = _generateViewports();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant InteractiveGallery oldWidget) {
    if (oldWidget.size != widget.size) {
      viewports = _generateViewports();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final grid = InteractiveGrid(
      viewportWidth: screenSize.width,
      viewportHeight: screenSize.height,
      crossAxisCount: widget.size,
      enableSnapping: widget.enableSnapping,
      onScrollStart: () {
        _distortionAmountNotifier.value = 0.9;
      },
      onScrollEnd: () {
        _distortionAmountNotifier.value = 0.0;
      },
      children: viewports,
    );

    return ValueListenableBuilder(
      valueListenable: _distortionAmountNotifier,
      builder: (context, double distortionAmount, Widget? child) {
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: distortionAmount),
          curve: Curves.easeOutSine,
          duration: const Duration(milliseconds: 700),
          builder: (context, double distortionAmount, Widget? child) {
            return PincushionDistortion(
              enabled: widget.enableDistortion,
              distortionAmount: distortionAmount,
              child: child!,
            );
          },
          child: child,
        );
      },
      child: grid,
    );
  }
}
