// const baseUrl = 'https://1573-196-188-33-62.ngrok-free.app';

// 'https://607c-71-114-98-63.ngrok-free.app';

// [base url] for the API
// this is the dev environment
// const baseUrl = 'https://607c-71-114-98-63.ngrok-free.app';
const baseUrl =
    'http://mela-finance-api-dev-env-1.eba-qq2r7pm5.us-east-2.elasticbeanstalk.com';

// Notifications related urls
const String fetchNotificationsUrl = "$baseUrl/api/notifications/all";
const String deleteFcmTokenUrl = "$baseUrl/user/me/devices";
const String saveFcmTokenUrl = "$baseUrl/user/me/devices";

// money request related urls
const String rejectRequestMoneyUrl =
    "$baseUrl/api/wallet/request-money/reject/";
const String fetchRequestMoneyDetailUrl =
    "$baseUrl/api/wallet/request-money/get/";
const String  requestMoneyUrl= "$baseUrl/api/wallet/request-money";
