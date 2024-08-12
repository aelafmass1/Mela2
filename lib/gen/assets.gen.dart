/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/abysinia_logo.png
  AssetGenImage get abysiniaLogo =>
      const AssetGenImage('assets/images/abysinia_logo.png');

  /// File path: assets/images/ahadu_logo.png
  AssetGenImage get ahaduLogo =>
      const AssetGenImage('assets/images/ahadu_logo.png');

  /// File path: assets/images/amara_bank_logo.png
  AssetGenImage get amaraBankLogo =>
      const AssetGenImage('assets/images/amara_bank_logo.png');

  /// File path: assets/images/awash_bank.png
  AssetGenImage get awashBank =>
      const AssetGenImage('assets/images/awash_bank.png');

  /// File path: assets/images/back_arrow.png
  AssetGenImage get backArrow =>
      const AssetGenImage('assets/images/back_arrow.png');

  /// File path: assets/images/bank_of_oromo.png
  AssetGenImage get bankOfOromo =>
      const AssetGenImage('assets/images/bank_of_oromo.png');

  /// File path: assets/images/buna_bank.png
  AssetGenImage get bunaBank =>
      const AssetGenImage('assets/images/buna_bank.png');

  /// File path: assets/images/cbe_logo.png
  AssetGenImage get cbeLogo =>
      const AssetGenImage('assets/images/cbe_logo.png');

  /// File path: assets/images/checked_logo.png
  AssetGenImage get checkedLogo =>
      const AssetGenImage('assets/images/checked_logo.png');

  /// File path: assets/images/dollar.png
  AssetGenImage get dollar => const AssetGenImage('assets/images/dollar.png');

  /// File path: assets/images/ethiopian_flag.png
  AssetGenImage get ethiopianFlag =>
      const AssetGenImage('assets/images/ethiopian_flag.png');

  /// File path: assets/images/news_background.png
  AssetGenImage get newsBackground =>
      const AssetGenImage('assets/images/news_background.png');

  /// File path: assets/images/next_arrow.png
  AssetGenImage get nextArrow =>
      const AssetGenImage('assets/images/next_arrow.png');

  /// File path: assets/images/profile_image.png
  AssetGenImage get profileImage =>
      const AssetGenImage('assets/images/profile_image.png');

  /// File path: assets/images/splash_logo.png
  AssetGenImage get splashLogo =>
      const AssetGenImage('assets/images/splash_logo.png');

  /// File path: assets/images/usa_flag.png
  AssetGenImage get usaFlag =>
      const AssetGenImage('assets/images/usa_flag.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        abysiniaLogo,
        ahaduLogo,
        amaraBankLogo,
        awashBank,
        backArrow,
        bankOfOromo,
        bunaBank,
        cbeLogo,
        checkedLogo,
        dollar,
        ethiopianFlag,
        newsBackground,
        nextArrow,
        profileImage,
        splashLogo,
        usaFlag
      ];
}

class Assets {
  Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}