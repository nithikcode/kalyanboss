
class AppUrl {
  // static const String url = "http://10.0.10.151:7002"; // LOCAL Pushpendra
  // static const String url = "http://10.5.1.150:7001"; // LOCAL Daksh
  static const String url = 'http://192.168.0.21:2552';  // live Api v1
  static const String baseUrl = '$url/api/v1';
  // static const String php = 'http://10.0.10.226/woodenstreet-web/index.php?route=api/api_flutter29';  // LOCAL Himanshu PHP
  static const String php = 'https://beta.woodenstreet.com/index.php?route=api/api_flutter_node';  // live php beta PHP
// static const String php = 'http://10.4.1.9/testws/index.php?route=api/api_flutter29';  // testing PHP
}

class AppLogos {

  static const String appIcon = 'assets/images/app_icon.png';

}

class AppStrings {
  // --- API dependent, mutable (will be updated after first API call) ---
  // static String base_Images = "https://images.woodenstreet.de/image/";
  // static String base_Images_Static = "https://d2emch4msrhe87.cloudfront.net/wsnew2024/static-webmedia";
  static String baseImages = "https://images.woodenstreet.de/image/";
  static String baseImagesStatic = "https://d2emch4msrhe87.cloudfront.net/wsnew2024/static-webmedia";
  static String bannerUrl = "$baseImagesStatic/images/offer/mobile-mid-banner.jpg";
  static String whatsAppNumber = "919660096011";
  static String wsNumber = "9314444747";
  static String appUpdate = "A new Update is Available";
  static String storeWhatsAppMessage = "Share Google Maps link for WoodenStreet,";
  static String couponCode = "WEDDING25";
  static String storeOfferText = "";
  static String defaultWhatsAppMessage = "Hi, I would like to discuss about the furniture and other details. Kindly assist!";
  static String url = 'https://woodenstreet.com';
  static String showDeleteAccountButton = 'false';
  static String appName = 'KalyanBoss';


  // --- Other constants ---

  static const String signUP = 'SIGN UP';
  static const String similarProductSheetTitle = 'Available Color & Finish';
  static const String addToWishList = 'Add To Wishlist';
  static const String inYourWishList = 'In Your Wishlist';
  static const String bestSellerTag = 'Best Seller';
  static const String login = 'LOGIN';
  static const String forgotPassword = 'FORGOT PASSWORD';
  static const String verifyOTP = 'Please Enter your OTP';
  static const String resetPassword = 'Please Reset your Password';
  static const String search = 'Search Products, Colors & more...';
  static const String what_help = 'What Can We help you with?';
  static const String new_customer = 'New Customer';
  static const String existingCustomer = 'Existing Order';
  static const String myOrdersTitle = 'My Orders';
  static const String myOrdersSubTitle = 'Manage and track your order here';
  static const String addressBookTitle = 'Address Book';
  static const String addressBookSubTitle = 'Manage your delivery address here';
  static const String wishListTitle = 'Wishlist';
  static const String wishListSubTitle = 'Check your wishlist product';
  static const String helpDeskTitle = 'HelpDesk';
  static const String helpDeskSubTitle = 'Contact us for support';
  static const String walletTitle = 'Wallet';
  static const String walletSubTitle = 'View your wallet balance';
  static const String editAccount = 'Edit Account';
  static const String logout = 'Log Out';
  static const String delete = 'Delete My Account';


  // --- Update function ---
  // static void updateFromConfig(AppConfigEntity config) {
  //   if (config.baseImages != null && config.baseImages!.isNotEmpty) {
  //     baseImages = config.baseImages!;
  //   }
  //   if (config.baseStatic != null && config.baseStatic!.isNotEmpty) {
  //     baseImagesStatic = config.baseStatic!;
  //   }
  //   if (config.bannerUrl != null && config.bannerUrl!.isNotEmpty) {
  //     bannerUrl = config.bannerUrl!;
  //   }
  //   if (config.whatsAppNumber != null && config.whatsAppNumber!.isNotEmpty) {
  //     whatsAppNumber = config.whatsAppNumber!;
  //   }
  //   if (config.wsMobileNumber != null && config.wsMobileNumber!.isNotEmpty) {
  //     wsNumber = config.wsMobileNumber!;
  //   }
  //   if(config.defaultWhatsAppMessage != null && config.defaultWhatsAppMessage!.isNotEmpty) {
  //     defaultWhatsAppMessage = config.defaultWhatsAppMessage!;
  //   }
  //   if(config.storeWhatsAppMessage != null && config.storeWhatsAppMessage!.isNotEmpty) {
  //     storeWhatsAppMessage = config.storeWhatsAppMessage!;
  //   }
  //   if(config.couponCode != null && config.couponCode!.isNotEmpty) {
  //     couponCode = config.couponCode!;
  //   }
  //   if(config.storeOfferText != null && config.storeOfferText!.isNotEmpty) {
  //     storeOfferText = config.storeOfferText!;
  //   }
  //   if(config.url != null && config.url!.isNotEmpty) {
  //     url = config.url!;
  //   }
  //   if(config.showDeleteAccountButton != null && config.showDeleteAccountButton!.isNotEmpty) {
  //     showDeleteAccountButton = config.showDeleteAccountButton!;
  //   }
  // }
}


