// const baseUrl = 'https://1573-196-188-33-62.ngrok-free.app';

// 'https://607c-71-114-98-63.ngrok-free.app';

// [base url] for the API
// this is the dev environment
// const baseUrl = 'https://607c-71-114-98-63.ngrok-free.app';
const baseUrl =
    'http://mela-finance-api-dev-env-1.eba-qq2r7pm5.us-east-2.elasticbeanstalk.com';
const requestTimeOut = 5; // in seconds
const responseTimeOut = 3; // in seconds

// Notifications related urls
const String fetchNotificationsUrl = "/api/notifications/all";
const String deleteFcmTokenUrl = "/user/me/devices";
const String saveFcmTokenUrl = "/user/me/devices";

// money request related urls
const String rejectRequestMoneyUrl = "/api/wallet/request-money/reject/";
const String fetchRequestMoneyDetailUrl = "/api/wallet/request-money/get/";
const String requestMoneyUrl = "/api/wallet/request-money";
