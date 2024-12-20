import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../gen/colors.gen.dart';

String defaultPicPath = 'assets/images/placeholder.png';

class ImageBuilder extends StatelessWidget {
  const ImageBuilder({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
    required this.height,
    this.width,
    this.circle = false,
    this.blured = false,
    this.file = false,
    this.addBorder = false,
    this.roundness,
  });

  final bool addBorder;
  final bool blured;
  final bool circle;
  final bool file;
  final BoxFit fit;
  final double height;
  final String image;
  final double? width;
  final double? roundness;

  bool _isUrl(String? string) {
    if (string == null) return false;
    final RegExp urlExp = RegExp(
      r'^((ftp|http|https)://|(www))[a-z0-9-]+(.[a-z0-9-]+)+(:[0-9]{1,5})?(/.*)?$',
    );
    return urlExp.hasMatch(string);
  }

  bool _isSvg(String path) {
    return path.endsWith('.svg');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        border: addBorder ? Border.all() : null,
        borderRadius:
            circle ? null : BorderRadius.all(Radius.circular(roundness ?? 8)),
      ),
      height: height,
      width: width ?? height,
      child: _isSvg(image) // Check if the image is an SVG
          ? SvgPicture.asset(
              image != '' ? image : defaultPicPath,
              fit: fit,
            )
          : !_isUrl(image) && file // If it's a local file
              ? Image.file(
                  File(image),
                  fit: fit,
                  height: height,
                  width: width ?? height,
                )
              : _isUrl(image) // If it's a URL
                  ? CachedNetworkImage(
                      imageUrl: image,
                      height: height,
                      width: width,
                      fit: fit,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: circle
                              ? null
                              : const BorderRadius.all(Radius.circular(10)),
                          image:
                              DecorationImage(image: imageProvider, fit: fit),
                          shape: circle ? BoxShape.circle : BoxShape.rectangle,
                        ),
                      ),
                      placeholder: (context, url) => Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: circle
                                  ? null
                                  : const BorderRadius.all(Radius.circular(10)),
                              shape:
                                  circle ? BoxShape.circle : BoxShape.rectangle,
                              image: DecorationImage(
                                  image: AssetImage(defaultPicPath), fit: fit),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                color: ColorName.grey.withOpacity(0.5)),
                            child: const CircularProgressIndicator(
                                color: ColorName.white),
                          ),
                        ],
                      ),
                      errorWidget: (context, url, error) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            image: DecorationImage(
                                image: AssetImage(defaultPicPath), fit: fit),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      image != '' ? image : defaultPicPath,
                      fit: fit,
                      height: height,
                      width: width ?? height,
                    ),
    );
  }
}
