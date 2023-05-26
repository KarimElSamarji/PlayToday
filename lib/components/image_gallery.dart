import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageGallery extends StatefulWidget {
  final List<String> imageUrls;

  const ImageGallery(this.imageUrls, {super.key});

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 150,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 18 / 9,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        pauseAutoPlayOnTouch: true,
        scrollDirection: Axis.horizontal,
      ),
      items: widget.imageUrls.map((imageUrl) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.8,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.fill,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
