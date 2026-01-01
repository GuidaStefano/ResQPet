import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {

  final bool isSourceNetwork;
  final List<String> images;
  final double height;
  final double? imageWidth;

  const ImageCarousel({
    super.key,
    required this.images,
    required this.isSourceNetwork,
    this.height = 250,
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
    return SizedBox(
      height: widget.height, 
      child: PageView.builder(
        itemCount: widget.images.length,
        pageSnapping: true,
        controller: _pageController,
        itemBuilder: (context, pagePosition) {

          final image = widget.images[pagePosition];

          return Container(
            margin: EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: widget.isSourceNetwork
                ? Image.network(
                  image,
                  fit: BoxFit.cover,
                  width: widget.imageWidth,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text('Immagine non disponibile')
                    ),
                  )
                ) 
                : Image.asset(
                  image,
                  width: widget.imageWidth,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text('Immagine non disponibile')
                    ),
                  ),
                ),
            ) 
          );
        }
      )
    );
  }
}