import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {

  final bool isSourceNetwork;
  final List<String> images;
  final double imageHeight;
  final double? imageWidth;

  const ImageCarousel({
    super.key,
    required this.images,
    required this.isSourceNetwork,
    this.imageHeight = 200,
    this.imageWidth
  });
  
  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}


class _ImageCarouselState extends State<ImageCarousel> {

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: widget.images.length,
      pageSnapping: true,
      controller: _pageController,
      itemBuilder: (context, pagePosition) {

        final image = widget.images[pagePosition];

        return Container(
          margin: EdgeInsets.all(10),
          child: widget.isSourceNetwork
            ? Image.network(
              image,
              fit: BoxFit.cover,
              height: widget.imageHeight,
              width: widget.imageWidth,
            )
            : Image.asset(
              image,
              fit: BoxFit.cover,
              height: widget.imageHeight,
              width: widget.imageWidth,
            )
        );
      }
    );
  }
}