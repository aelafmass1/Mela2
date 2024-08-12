import 'package:transaction_mobile_app/gen/assets.gen.dart';

String getBankImagePath(String bankName) {
  switch (bankName) {
    case 'Awash Bank':
      return Assets.images.awashBank.path;
    case 'COOP Bank':
      return Assets.images.bankOfOromo.path;
    case 'Amhara Bank':
      return Assets.images.amaraBankLogo.path;
    case 'Ahadu Bank':
      return Assets.images.ahaduLogo.path;
    case 'CBE':
      return Assets.images.cbeLogo.path;
    case 'BOA':
      return Assets.images.abysiniaLogo.path;
  }
  return Assets.images.cbeLogo.path;
}
