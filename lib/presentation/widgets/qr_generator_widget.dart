import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class QrGeneratorWidget extends StatelessWidget {
  final String shareLink;
  final double amount;
  const QrGeneratorWidget(
      {super.key, required this.shareLink, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: 100.sw,
        padding: const EdgeInsets.only(top: 40, left: 15, right: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton.outlined(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 350,
                child: PrettyQrView.data(
                  data: shareLink,
                  decoration: PrettyQrDecoration(
                    image: PrettyQrDecorationImage(
                      image: Assets.images.melaLogo.provider(),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  TextWidget(
                    text: '\$${NumberFormat('##,###.##').format(amount)}',
                    fontSize: 64,
                    color: ColorName.primaryColor,
                    weight: FontWeight.w700,
                  ),
                  const TextWidget(
                    text: 'Requested payment via link',
                    color: ColorName.grey,
                    fontSize: 20,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      SizedBox(
                        width: 114,
                        height: 40,
                        child: ButtonWidget(
                            verticalPadding: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  Assets.images.svgs.share,
                                  width: 16,
                                  height: 16,
                                ),
                                const SizedBox(width: 7),
                                const TextWidget(
                                  text: 'Share',
                                  color: Colors.white,
                                  type: TextType.small,
                                ),
                              ],
                            ),
                            onPressed: () {
                              Share.share(
                                shareLink,
                              );
                            }),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 114,
                        height: 40,
                        child: ButtonWidget(
                          color: const Color(0xFFF0F7FF),
                          elevation: 0,
                          verticalPadding: 0,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.close,
                                size: 16,
                                color: ColorName.primaryColor,
                              ),
                              SizedBox(width: 7),
                              TextWidget(
                                text: 'Cancel',
                                color: ColorName.primaryColor,
                                type: TextType.small,
                              ),
                            ],
                          ),
                          onPressed: () {
                            context.pop();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  CardWidget(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    width: 100.sw,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF0F7FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.link),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                            child: TextWidget(
                          text: shareLink,
                          type: TextType.small,
                          color: ColorName.primaryColor,
                        )),
                        const SizedBox(width: 15),
                        IconButton(
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: shareLink,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.copy_rounded,
                            color: ColorName.primaryColor,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
