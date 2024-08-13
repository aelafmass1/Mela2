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
    case 'Dashen Bank':
      return Assets.images.dashnBankLogo.path;
    case 'Zemen Bank':
      return Assets.images.zemenBankLogo.path;
    case 'Hibret Bank':
      return Assets.images.hibretBankLogo.path;
    case 'Oromia Bank':
      return Assets.images.oromiaBankLogo.path;
    case 'Enat Bank':
      return Assets.images.enatBankLogo.path;
    case 'NIB Bank':
      return Assets.images.nibBankLogo.path;
    case 'Wegagen Bank':
      return Assets.images.wegagenBankLogo.path;
    case 'Sinqe Bank':
      return Assets.images.sinqeBankLogo.path;
    case 'Tsehay Bank':
      return Assets.images.tsehayBankLogo.path;
    case 'Birhan Bank':
      return Assets.images.birhanBankLogo.path;
    case 'Abay Bank':
      return Assets.images.abayBankLogo.path;
    case 'Gadda Bank':
      return Assets.images.gedaBankLogo.path;
    case 'Tsedey Bank':
      return Assets.images.tsedeyBankLogo.path;
    case 'Global Bank':
      return Assets.images.globalBankLogo.path;
    case 'Hijra Bank':
      return Assets.images.hijraBankLogo.path;
    default:
      return Assets.images.cbeLogo.path;
  }
}
